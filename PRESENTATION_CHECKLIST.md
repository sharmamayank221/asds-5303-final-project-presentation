# Pre-Presentation Checklist

## ✅ Test Everything NOW (Before Tomorrow)

### 1. Test the Dashboard
```bash
./start_presentation.sh
```
- [ ] Open http://localhost:8000/dashboard.html
- [ ] Move slider from 65% to 50% - verify it calculates
- [ ] Toggle SMOTE ON - verify it works
- [ ] Check ROC curves update correctly
- [ ] Verify all stat cards update

### 2. Verify Dependencies
```bash
# Check Python
python3 --version

# Check R
Rscript --version

# Check R packages (if needed)
R
> install.packages(c("MASS", "caret", "pROC", "jsonlite", "ROSE"))
```

### 3. Test API Directly
```bash
# Start API server first
python api_server.py

# In another terminal, test:
curl -X POST http://localhost:5001/analyze \
  -H "Content-Type: application/json" \
  -d '{"no_diabetes_pct": 65, "use_smote": false}'
```
Should return JSON with model metrics.

### 4. Free Up Ports
```bash
./kill_ports.sh
```

### 5. Verify CSV File Path
Check `model_analysis.R` line 19:
```r
diabetes <- read.csv("/Users/mayanksharma/Desktop/5303 fall/diabetes 2.csv", header = TRUE)
```
Make sure this file exists!

---

## 📋 Day of Presentation

### Morning Of:
1. [ ] Test dashboard one more time
2. [ ] Free up ports: `./kill_ports.sh`
3. [ ] Close unnecessary applications
4. [ ] Have backup screenshots ready

### Starting the Dashboard:
```bash
cd /Users/mayanksharma/Desktop/ASDS_5303_Final_Presentation_Grp_7
./start_presentation.sh
```

Then open: **http://localhost:8000/dashboard.html**

### If Something Goes Wrong:
1. **API won't start:** Run `./kill_ports.sh` and try again
2. **Dashboard shows errors:** Check browser console (F12)
3. **R script fails:** Verify CSV file path in `model_analysis.R`
4. **Use backup:** Have screenshots ready as fallback

---

## 🎯 Presentation Flow

1. **Start with baseline (65%)** - Show current performance
2. **Move to 50%** - Show how balance improves specificity
3. **Enable SMOTE** - Show synthetic oversampling effect
4. **Explain metrics** - Use tooltips to explain what each metric means

**Note:** Each calculation takes 30-60 seconds. Mention this is real model training happening live!

---

## 📞 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Port 5001 busy | `lsof -ti:5001 \| xargs kill -9` |
| Port 8000 busy | `lsof -ti:8000 \| xargs kill -9` |
| API not responding | Check `python api_server.py` runs manually |
| R script error | Verify CSV path in `model_analysis.R` |
| Dashboard blank | Check browser console (F12) for errors |

---

## 🎬 Backup Plan

If live demo fails:
1. Have screenshots of different slider positions
2. Have a pre-recorded video demo
3. Explain the concept even if dashboard doesn't work

---

## ✅ Final Check

Before you present:
- [ ] Dashboard loads correctly
- [ ] Slider works
- [ ] SMOTE toggle works
- [ ] Results update after calculation
- [ ] ROC curves display
- [ ] All tooltips work (hover over ? icons)

**You're ready! Good luck with your presentation! 🚀**

