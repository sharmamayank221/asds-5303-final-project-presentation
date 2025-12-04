# Quick Start Guide

Since you're using Conda, here's the fastest way to get started:

## Step 1: Install Dependencies (if needed)

Flask should already be installed in your conda environment. If not:
```bash
pip install --user flask flask-cors
```

## Step 2: Start the API Server

In one terminal:
```bash
cd /Users/mayanksharma/Desktop/ASDS_5303_Final_Presentation_Grp_7
python api_server.py
```

You should see:
```
Starting Diabetes Model Analysis API Server...
 * Running on http://0.0.0.0:5001
```

**Note:** We use port 5001 instead of 5000 because macOS AirPlay uses port 5000.

## Step 3: Start the Web Server

In another terminal:
```bash
cd /Users/mayanksharma/Desktop/ASDS_5303_Final_Presentation_Grp_7
python -m http.server 8000
```

## Step 4: Open Dashboard

Open your browser and go to:
```
http://localhost:8000/dashboard.html
```

## Troubleshooting

### If API server fails to start:
1. Check if R is installed: `which Rscript`
2. Verify the dataset path in `model_analysis.R` (line 21)
3. Check if R packages are installed:
   ```r
   install.packages(c("MASS", "caret", "pROC", "jsonlite"))
   ```

### If you see "ModuleNotFoundError: No module named 'flask'":
```bash
pip install --user flask flask-cors
```

### If ports are already in use:

**Quick fix - kill existing processes:**
```bash
./kill_ports.sh
```

**Or manually:**
```bash
# Kill process on port 5000
lsof -ti:5000 | xargs kill

# Kill process on port 8000
lsof -ti:8000 | xargs kill
```

**Note:** Port 5001 is used (instead of 5000) because macOS AirPlay uses port 5000. If you need to change it, edit both `api_server.py` and `dashboard.html`.

## Using the Dashboard

1. **Adjust Class Ratio**: Move the slider to change the No Diabetes / Diabetes ratio (40-60%)
2. **Enable SMOTE**: Toggle the SMOTE switch to enable synthetic oversampling
3. **Wait for Results**: Each analysis takes 30-60 seconds
4. **View Metrics**: See real LDA and QDA performance metrics update in real-time

The dashboard will show a loading spinner while the R models are being trained.

