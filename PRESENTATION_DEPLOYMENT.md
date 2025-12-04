# Presentation Deployment Guide

## Quick Start for Presentation

### Option 1: One-Command Start (Recommended)

Simply run:
```bash
./start_server.sh
```

Then open: **http://localhost:8000/dashboard.html**

### Option 2: Manual Start (If script doesn't work)

**Terminal 1 - API Server:**
```bash
cd /Users/mayanksharma/Desktop/ASDS_5303_Final_Presentation_Grp_7
python api_server.py
```

**Terminal 2 - Web Server:**
```bash
cd /Users/mayanksharma/Desktop/ASDS_5303_Final_Presentation_Grp_7
python -m http.server 8000
```

Then open: **http://localhost:8000/dashboard.html**

---

## Pre-Presentation Checklist

### ✅ Before Your Presentation:

1. **Test Everything Now:**
   ```bash
   ./start_server.sh
   ```
   - Open http://localhost:8000/dashboard.html
   - Move the slider - verify it calculates
   - Toggle SMOTE - verify it works
   - Check that ROC curves update

2. **Verify Dependencies:**
   ```bash
   # Check Python
   python3 --version
   
   # Check R
   Rscript --version
   
   # Check R packages (run in R console)
   R
   > install.packages(c("MASS", "caret", "pROC", "jsonlite", "ROSE"))
   ```

3. **Test API Directly:**
   ```bash
   curl -X POST http://localhost:5001/analyze \
     -H "Content-Type: application/json" \
     -d '{"no_diabetes_pct": 65, "use_smote": false}'
   ```
   Should return JSON with model metrics.

4. **Free Up Ports:**
   ```bash
   ./kill_ports.sh
   ```

5. **Create a Backup:**
   - Take a screenshot of the dashboard with good results
   - Or record a short video demo as backup

---

## During Presentation

### Starting the Dashboard:

1. **Open Terminal**
2. **Navigate to project:**
   ```bash
   cd /Users/mayanksharma/Desktop/ASDS_5303_Final_Presentation_Grp_7
   ```
3. **Run startup script:**
   ```bash
   ./start_server.sh
   ```
4. **Wait for:**
   ```
   Starting API server on port 5001...
   API server started (PID: xxxxx)
   Starting web server on port 8000...
   ```
5. **Open browser to:**
   ```
   http://localhost:8000/dashboard.html
   ```

### Presentation Tips:

- **First Demo:** Start with slider at 65% (baseline) - this is fast
- **Show Impact:** Move to 50% to show how balance improves specificity
- **SMOTE Demo:** Enable SMOTE to show synthetic oversampling effect
- **Wait Times:** Each calculation takes 30-60 seconds - mention this is real model training
- **Backup Plan:** If something fails, have screenshots ready

---

## Troubleshooting During Presentation

### If API Server Won't Start:

```bash
# Kill any existing processes
./kill_ports.sh

# Try manual start
python api_server.py
```

### If Ports Are Busy:

```bash
# Kill specific ports
lsof -ti:5001 | xargs kill -9
lsof -ti:8000 | xargs kill -9
```

### If R Script Fails:

Check the dataset path in `model_analysis.R` line 19:
```r
diabetes <- read.csv("/Users/mayanksharma/Desktop/5303 fall/diabetes 2.csv", header = TRUE)
```

### If Dashboard Shows "Failed to Fetch":

1. Check API is running: `curl http://localhost:5001/health`
2. Check browser console for errors (F12)
3. Verify dashboard.html is calling port 5001 (not 5000)

---

## Alternative: Static Demo Mode

If the API fails during presentation, you can:

1. **Use Cached Results:** The dashboard shows baseline metrics even if API fails
2. **Pre-calculate Results:** Run a few API calls before presentation and note the values
3. **Screenshot Backup:** Have screenshots of different slider positions ready

---

## Network Deployment (If Needed)

If you need to access from another device on the same network:

1. **Find your IP:**
   ```bash
   ifconfig | grep "inet " | grep -v 127.0.0.1
   ```
   Or on macOS:
   ```bash
   ipconfig getifaddr en0
   ```

2. **Update API Server:**
   Edit `api_server.py` line ~150:
   ```python
   app.run(host='0.0.0.0', port=5001, debug=False)
   ```

3. **Access from other device:**
   ```
   http://YOUR_IP:8000/dashboard.html
   ```

---

## Post-Presentation

To stop servers:
- Press `Ctrl+C` in the terminal running `start_server.sh`
- Or manually kill processes:
  ```bash
  ./kill_ports.sh
  ```

---

## Quick Reference

| Component | Port | URL |
|-----------|------|-----|
| API Server | 5001 | http://localhost:5001 |
| Web Server | 8000 | http://localhost:8000/dashboard.html |
| Health Check | 5001 | http://localhost:5001/health |

**Key Files:**
- `dashboard.html` - Main dashboard
- `api_server.py` - Backend API
- `model_analysis.R` - R script for model training
- `start_server.sh` - Startup script

**Important:** Make sure the CSV file path in `model_analysis.R` is correct!

