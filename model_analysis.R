# Parameterized R Script for Dynamic Model Analysis
# Accepts command-line arguments for class imbalance and SMOTE

# Parse command-line arguments
args <- commandArgs(trailingOnly = TRUE)
no_diabetes_pct <- as.numeric(args[1])  # Percentage for No Diabetes class
use_smote <- as.logical(args[2])         # Whether to use SMOTE
output_file <- args[3]                   # Output JSON file path

# Load required libraries
suppressPackageStartupMessages({
  library(MASS)
  library(caret)
  library(pROC)
  library(jsonlite)
})

# Load the dataset
# Try multiple paths for local vs cloud deployment
csv_paths <- c(
  "/Users/mayanksharma/Desktop/5303 fall/diabetes 2.csv",  # Local path
  "data/diabetes_2.csv",                                    # Cloud path (in repo)
  "diabetes_2.csv"                                          # Fallback
)

csv_path <- NULL
for (path in csv_paths) {
  if (file.exists(path)) {
    csv_path <- path
    break
  }
}

if (is.null(csv_path)) {
  stop("CSV file not found. Please ensure diabetes_2.csv is in the data/ folder or update the path.")
}

diabetes <- read.csv(csv_path, header = TRUE)

# Convert Outcome to factor
diabetes$Outcome <- as.factor(diabetes$Outcome)
levels(diabetes$Outcome) <- c("No_Diabetes", "Diabetes")

# Data Preprocessing
vars_with_zeros <- c("Glucose", "BloodPressure", "SkinThickness", "BMI", "Insulin")
diabetes[vars_with_zeros] <- lapply(diabetes[vars_with_zeros], function(x) ifelse(x == 0, NA, x))

# Impute Missing Values
for (col in vars_with_zeros) {
  median_value <- median(diabetes[,col], na.rm = TRUE)
  diabetes[is.na(diabetes[,col]), col] <- median_value
}

# Adjust class imbalance if needed
if (no_diabetes_pct != 65) {
  # Calculate target counts
  total <- nrow(diabetes)
  no_diabetes_count <- round(total * no_diabetes_pct / 100)
  diabetes_count <- total - no_diabetes_count
  
  # Get current counts
  current_no_diabetes <- sum(diabetes$Outcome == "No_Diabetes")
  current_diabetes <- sum(diabetes$Outcome == "Diabetes")
  
  # Resample to achieve target distribution
  set.seed(123)
  
  no_diabetes_data <- diabetes[diabetes$Outcome == "No_Diabetes", ]
  diabetes_data <- diabetes[diabetes$Outcome == "Diabetes", ]
  
  # Sample with replacement if needed
  if (no_diabetes_count > current_no_diabetes) {
    no_diabetes_data <- no_diabetes_data[sample(1:nrow(no_diabetes_data), no_diabetes_count, replace = TRUE), ]
  } else {
    no_diabetes_data <- no_diabetes_data[sample(1:nrow(no_diabetes_data), no_diabetes_count, replace = FALSE), ]
  }
  
  if (diabetes_count > current_diabetes) {
    diabetes_data <- diabetes_data[sample(1:nrow(diabetes_data), diabetes_count, replace = TRUE), ]
  } else {
    diabetes_data <- diabetes_data[sample(1:nrow(diabetes_data), diabetes_count, replace = FALSE), ]
  }
  
  # Combine
  diabetes <- rbind(no_diabetes_data, diabetes_data)
  diabetes <- diabetes[sample(1:nrow(diabetes)), ]  # Shuffle
}

# Apply SMOTE if requested
if (use_smote) {
  set.seed(123)
  diabetes_data <- diabetes[diabetes$Outcome == "Diabetes", ]
  no_diabetes_data <- diabetes[diabetes$Outcome == "No_Diabetes", ]
  
  # Determine minority class
  if (nrow(diabetes_data) < nrow(no_diabetes_data)) {
    # Diabetes is minority - oversample it
    target_size <- nrow(no_diabetes_data)
    current_size <- nrow(diabetes_data)
    needed <- target_size - current_size
    
    if (needed > 0) {
      additional <- diabetes_data[sample(1:nrow(diabetes_data), needed, replace = TRUE), ]
      diabetes <- rbind(diabetes, additional)
    }
  } else {
    # No_Diabetes is minority - oversample it
    target_size <- nrow(diabetes_data)
    current_size <- nrow(no_diabetes_data)
    needed <- target_size - current_size
    
    if (needed > 0) {
      additional <- no_diabetes_data[sample(1:nrow(no_diabetes_data), needed, replace = TRUE), ]
      diabetes <- rbind(diabetes, additional)
    }
  }
  
  # Shuffle
  diabetes <- diabetes[sample(1:nrow(diabetes)), ]
}

# Stratified Split
set.seed(123)
trainIndex <- createDataPartition(diabetes$Outcome, p = 0.7, list = FALSE)
train_data <- diabetes[trainIndex, ]
test_data <- diabetes[-trainIndex, ]

# Train LDA
lda_model <- lda(Outcome ~ ., data = train_data)
lda_pred <- predict(lda_model, test_data)
lda_cm <- confusionMatrix(lda_pred$class, test_data$Outcome)

# Train QDA
qda_model <- qda(Outcome ~ ., data = train_data)
qda_pred <- predict(qda_model, test_data)
qda_cm <- confusionMatrix(qda_pred$class, test_data$Outcome)

# Calculate ROC and AUC
lda_probs <- as.numeric(lda_pred$posterior[, "Diabetes"])
qda_probs <- as.numeric(qda_pred$posterior[, "Diabetes"])
test_outcome_numeric <- ifelse(test_data$Outcome == "Diabetes", 1, 0)

lda_roc <- roc(test_outcome_numeric, lda_probs, quiet = TRUE)
qda_roc <- roc(test_outcome_numeric, qda_probs, quiet = TRUE)

# Extract ROC curve coordinates
lda_roc_coords <- coords(lda_roc, "all", ret = c("threshold", "sensitivity", "specificity"), transpose = FALSE)
qda_roc_coords <- coords(qda_roc, "all", ret = c("threshold", "sensitivity", "specificity"), transpose = FALSE)

# Prepare ROC curve data (FPR = 1 - Specificity, TPR = Sensitivity)
lda_roc_curve <- data.frame(
  fpr = 1 - lda_roc_coords$specificity,
  tpr = lda_roc_coords$sensitivity
)
qda_roc_curve <- data.frame(
  fpr = 1 - qda_roc_coords$specificity,
  tpr = qda_roc_coords$sensitivity
)

# Sort by FPR for smooth plotting
lda_roc_curve <- lda_roc_curve[order(lda_roc_curve$fpr), ]
qda_roc_curve <- qda_roc_curve[order(qda_roc_curve$fpr), ]

# Convert to numeric vectors for JSON (remove any NA or Inf values)
lda_fpr <- as.numeric(lda_roc_curve$fpr)
lda_tpr <- as.numeric(lda_roc_curve$tpr)
qda_fpr <- as.numeric(qda_roc_curve$fpr)
qda_tpr <- as.numeric(qda_roc_curve$tpr)

# Remove any invalid values
lda_fpr <- lda_fpr[is.finite(lda_fpr) & !is.na(lda_fpr)]
lda_tpr <- lda_tpr[is.finite(lda_tpr) & !is.na(lda_tpr)]
qda_fpr <- qda_fpr[is.finite(qda_fpr) & !is.na(qda_fpr)]
qda_tpr <- qda_tpr[is.finite(qda_tpr) & !is.na(qda_tpr)]

# Ensure matching lengths
min_len_lda <- min(length(lda_fpr), length(lda_tpr))
min_len_qda <- min(length(qda_fpr), length(qda_tpr))
lda_fpr <- lda_fpr[1:min_len_lda]
lda_tpr <- lda_tpr[1:min_len_lda]
qda_fpr <- qda_fpr[1:min_len_qda]
qda_tpr <- qda_tpr[1:min_len_qda]

# Prepare results - ensure all values are simple scalars/vectors (not nested lists)
# Use unlist() to convert single-element vectors to scalars for jsonlite
results <- list(
  lda = list(
    accuracy = unlist(as.numeric(lda_cm$overall["Accuracy"]))[1],
    sensitivity = unlist(as.numeric(lda_cm$byClass["Sensitivity"]))[1],
    specificity = unlist(as.numeric(lda_cm$byClass["Specificity"]))[1],
    precision = unlist(as.numeric(lda_cm$byClass["Precision"]))[1],
    f1 = unlist(as.numeric(lda_cm$byClass["F1"]))[1],
    auc = unlist(as.numeric(auc(lda_roc)))[1],
    roc_curve = list(
      fpr = as.numeric(lda_fpr),
      tpr = as.numeric(lda_tpr)
    )
  ),
  qda = list(
    accuracy = unlist(as.numeric(qda_cm$overall["Accuracy"]))[1],
    sensitivity = unlist(as.numeric(qda_cm$byClass["Sensitivity"]))[1],
    specificity = unlist(as.numeric(qda_cm$byClass["Specificity"]))[1],
    precision = unlist(as.numeric(qda_cm$byClass["Precision"]))[1],
    f1 = unlist(as.numeric(qda_cm$byClass["F1"]))[1],
    auc = unlist(as.numeric(auc(qda_roc)))[1],
    roc_curve = list(
      fpr = as.numeric(qda_fpr),
      tpr = as.numeric(qda_tpr)
    )
  ),
  class_distribution = list(
    no_diabetes_pct = unlist(round(100 * sum(diabetes$Outcome == "No_Diabetes") / nrow(diabetes), 2))[1],
    diabetes_pct = unlist(round(100 * sum(diabetes$Outcome == "Diabetes") / nrow(diabetes), 2))[1],
    total = unlist(nrow(diabetes))[1]
  )
)

# Write results to JSON
# Use auto_unbox = TRUE to convert single-element vectors to scalars
write_json(results, output_file, pretty = TRUE, auto_unbox = TRUE)

