# Dynamic Dashboard Setup Guide

This guide will help you set up the dynamic dashboard that runs real R model analysis with different class imbalance settings.

## Prerequisites

1. **Python 3.7+** installed
2. **R** installed with the following packages:
   - MASS
   - caret
   - pROC
   - jsonlite
   - DMwR (optional, for SMOTE)

## Installation Steps

### Option A: Using Virtual Environment (Recommended)

```bash
cd /Users/mayanksharma/Desktop/ASDS_5303_Final_Presentation_Grp_7
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Option B: Using Conda (If you're using Anaconda/Miniconda)

```bash
cd /Users/mayanksharma/Desktop/ASDS_5303_Final_Presentation_Grp_7
conda install flask flask-cors -c conda-forge
# OR
pip install --user flask flask-cors
```

### Option C: Manual Installation

If you get "externally-managed-environment" error, use:
```bash
pip install --user flask flask-cors
```

### 2. Install R Packages (if not already installed)

Open R and run:
```r
install.packages(c("MASS", "caret", "pROC", "jsonlite", "DMwR"))
```

### 3. Verify File Paths

Make sure the paths in `model_analysis.R` match your system:
- Line 21: Dataset path should point to your CSV file
- Currently set to: `/Users/mayanksharma/Desktop/5303 fall/diabetes 2.csv`

## Running the System

### Quick Start (Automated)

**Option 1: Using Virtual Environment**
```bash
./start_server.sh
```

**Option 2: Using Conda**
```bash
./start_server_conda.sh
```

### Manual Start

**Step 1: Activate your environment**

If using virtual environment:
```bash
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

If using conda, make sure you're in your conda environment:
```bash
conda activate base  # or your environment name
```

**Step 2: Start the API Server**

In a terminal, run:
```bash
cd /Users/mayanksharma/Desktop/ASDS_5303_Final_Presentation_Grp_7
python api_server.py
```

You should see:
```
Starting Diabetes Model Analysis API Server...
R Script Path: /Users/mayanksharma/Desktop/ASDS_5303_Final_Presentation_Grp_7/model_analysis.R
R Script Exists: True
 * Running on http://0.0.0.0:5000
```

### Step 2: Start the Web Server (in another terminal)

```bash
cd /Users/mayanksharma/Desktop/ASDS_5303_Final_Presentation_Grp_7
python -m http.server 8000
```

### Step 3: Open the Dashboard

Open your browser and go to:
```
http://localhost:8000/dashboard.html
```

## How It Works

1. **User adjusts controls** (class ratio slider or SMOTE toggle)
2. **Dashboard sends API request** to `http://localhost:5000/analyze`
3. **API server executes R script** with the specified parameters
4. **R script**:
   - Loads and preprocesses the data
   - Adjusts class imbalance if needed
   - Applies SMOTE if enabled
   - Trains LDA and QDA models
   - Calculates metrics
   - Returns JSON results
5. **Dashboard updates** with real model performance metrics

## API Endpoints

### POST `/analyze`
Analyzes models with given parameters.

**Request:**
```json
{
  "no_diabetes_pct": 50,
  "use_smote": true
}
```

**Response:**
```json
{
  "lda": {
    "accuracy": 0.78,
    "sensitivity": 0.85,
    "specificity": 0.72,
    "precision": 0.75,
    "f1": 0.80,
    "auc": 0.85
  },
  "qda": {
    "accuracy": 0.73,
    "sensitivity": 0.82,
    "specificity": 0.65,
    "precision": 0.70,
    "f1": 0.75,
    "auc": 0.81
  },
  "class_distribution": {
    "no_diabetes_pct": 50.0,
    "diabetes_pct": 50.0,
    "total": 768
  },
  "metadata": {
    "execution_time": 12.5,
    "parameters": {
      "no_diabetes_pct": 50,
      "use_smote": true
    }
  }
}
```

### GET `/health`
Health check endpoint.

### GET `/baseline`
Get baseline results (65/35, no SMOTE).

## Troubleshooting

### API Server Won't Start
- Check if port 5000 is already in use
- Verify R is installed: `which Rscript`
- Check R script path is correct

### R Script Errors
- Verify all R packages are installed
- Check dataset file path is correct
- Look at API server console for error messages

### Dashboard Shows "Failed to fetch"
- Make sure API server is running on port 5000
- Check browser console for CORS errors
- Verify API_BASE_URL in dashboard.html matches your setup

### Slow Performance
- Model training takes 30-60 seconds per request
- Use debouncing on slider (already implemented)
- Consider caching results for common configurations

## Notes

- Each model analysis takes 30-60 seconds
- The slider is debounced (500ms delay) to avoid too many requests
- SMOTE toggle triggers immediate analysis
- Results are cached in the browser to avoid redundant API calls
- If API fails, dashboard falls back to cached results

## File Structure

```
ASDS_5303_Final_Presentation_Grp_7/
├── dashboard.html          # Main dashboard (updated with API calls)
├── api_server.py           # Flask API server
├── model_analysis.R        # Parameterized R script
├── requirements.txt        # Python dependencies
└── README_DYNAMIC_SETUP.md # This file
```

