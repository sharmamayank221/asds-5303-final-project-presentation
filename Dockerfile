# Dockerfile for deploying the dashboard API
FROM rocker/r-ver:4.3.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c('MASS', 'caret', 'pROC', 'jsonlite', 'ROSE'), repos='https://cran.rstudio.com/')"

# Set working directory
WORKDIR /app

# Create data directory
RUN mkdir -p /app/data

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy application files
COPY api_server.py .
COPY model_analysis.R .

# Copy CSV file (if it exists in repo)
# If CSV is not in repo, you'll need to upload it separately or use a URL
COPY data/*.csv /app/data/ 2>/dev/null || true

# Expose port (will be overridden by cloud platform)
EXPOSE 5001

# Run the application
CMD ["python3", "api_server.py"]

