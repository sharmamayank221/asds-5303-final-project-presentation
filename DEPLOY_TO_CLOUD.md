# Deploy Dashboard to Free Cloud Platforms

## Overview

Your dashboard has two components:
1. **Frontend** (HTML/CSS/JS) - Can deploy to Vercel, Netlify, or GitHub Pages
2. **Backend API** (Python + R) - Needs a platform that supports R execution

## Option 1: Render (Recommended - Easiest)

Render offers free tier with Docker support, perfect for R.

### Step 1: Prepare Files

1. **Create a GitHub repository** (if you haven't already):
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin YOUR_GITHUB_REPO_URL
   git push -u origin main
   ```

2. **Update `api_server.py`** to use environment variables:
   ```python
   # At the end of api_server.py, change:
   if __name__ == '__main__':
       port = int(os.environ.get('PORT', 5001))
       app.run(host='0.0.0.0', port=port, debug=False)
   ```

### Step 2: Deploy to Render

1. Go to [render.com](https://render.com) and sign up (free)
2. Click "New +" → "Web Service"
3. Connect your GitHub repository
4. Configure:
   - **Name:** `diabetes-dashboard-api`
   - **Environment:** `Docker`
   - **Dockerfile Path:** `Dockerfile`
   - **Port:** `5001`
   - **Plan:** Free
5. Add Environment Variable:
   - Key: `CSV_PATH`
   - Value: `/app/data/diabetes_2.csv` (or upload CSV to repo)
6. Click "Create Web Service"

### Step 3: Update Dashboard for Cloud

Update `dashboard.html` to use your Render API URL:

```javascript
// Change this line in dashboard.html:
const API_BASE_URL = 'https://your-app-name.onrender.com';
```

### Step 4: Deploy Frontend to Vercel

1. Go to [vercel.com](https://vercel.com) and sign up
2. Click "Add New Project"
3. Import your GitHub repository
4. Configure:
   - **Framework Preset:** Other
   - **Root Directory:** `./`
5. Deploy!

**Your dashboard will be live at:** `https://your-project.vercel.app/dashboard.html`

---

## Option 2: Railway (Alternative)

Railway has a generous free tier and great Docker support.

### Step 1: Prepare

Same as Render - ensure your code is on GitHub.

### Step 2: Deploy

1. Go to [railway.app](https://railway.app) and sign up
2. Click "New Project" → "Deploy from GitHub"
3. Select your repository
4. Railway will auto-detect the Dockerfile
5. Add environment variable for CSV path if needed
6. Deploy!

### Step 3: Update Dashboard

Same as Render - update `API_BASE_URL` in `dashboard.html` to your Railway URL.

---

## Option 3: Replit (Easiest for R, but less professional)

Replit has built-in R support, making it the easiest option.

### Step 1: Create Repl

1. Go to [replit.com](https://replit.com) and sign up
2. Click "Create Repl" → "Python"
3. Name it `diabetes-dashboard-api`

### Step 2: Upload Files

Upload these files to your Repl:
- `api_server.py`
- `model_analysis.R`
- `requirements.txt`
- Your CSV file (or use a URL)

### Step 3: Install R in Repl

In Repl shell:
```bash
# Replit has R pre-installed, but you may need to install packages
R
> install.packages(c("MASS", "caret", "pROC", "jsonlite", "ROSE"))
```

### Step 4: Run

1. Click "Run" button
2. Replit will give you a URL like: `https://your-repl-name.repl.co`
3. Update `dashboard.html` with this URL

### Step 5: Deploy Frontend

Deploy `dashboard.html` to Vercel/Netlify as in Option 1.

---

## Option 4: Separate Deployments (Most Flexible)

Deploy frontend and backend separately for maximum flexibility.

### Backend: Render/Railway
- Deploy API using Docker (as in Option 1)
- Get your API URL: `https://your-api.onrender.com`

### Frontend: Vercel/Netlify
1. **For Vercel:**
   - Create `vercel.json`:
   ```json
   {
     "rewrites": [
       { "source": "/api/:path*", "destination": "https://your-api.onrender.com/:path*" }
     ]
   }
   ```

2. **For Netlify:**
   - Create `netlify.toml`:
   ```toml
   [[redirects]]
     from = "/api/*"
     to = "https://your-api.onrender.com/:splat"
     status = 200
     force = true
   ```

3. Update `dashboard.html`:
   ```javascript
   const API_BASE_URL = '/api';  // Uses proxy
   ```

---

## Quick Setup Script

I'll create a script to help you prepare for deployment:

```bash
# Run this to prepare for cloud deployment
./prepare_for_deployment.sh
```

---

## Important Notes

### CSV File Location

You have two options:

1. **Upload CSV to repository:**
   - Create `data/` folder
   - Add `diabetes_2.csv` to `data/`
   - Update `model_analysis.R` line 19:
     ```r
     diabetes <- read.csv("data/diabetes_2.csv", header = TRUE)
     ```

2. **Use absolute path in Docker:**
   - Copy CSV into Docker image
   - Update Dockerfile to copy CSV

### Environment Variables

For cloud deployment, you may want to make the CSV path configurable:

```python
# In api_server.py, add:
CSV_PATH = os.environ.get('CSV_PATH', '/app/data/diabetes_2.csv')
```

Then update `model_analysis.R` to accept CSV path as argument.

---

## Testing Your Deployment

1. **Test API:**
   ```bash
   curl https://your-api-url.onrender.com/health
   ```

2. **Test Analysis:**
   ```bash
   curl -X POST https://your-api-url.onrender.com/analyze \
     -H "Content-Type: application/json" \
     -d '{"no_diabetes_pct": 65, "use_smote": false}'
   ```

3. **Test Dashboard:**
   - Open your deployed dashboard URL
   - Try moving the slider
   - Check browser console (F12) for errors

---

## Recommended: Render + Vercel

**Best combination for free deployment:**
- **Backend:** Render (free tier, Docker support, R support)
- **Frontend:** Vercel (free tier, fast CDN, easy deployment)

**Total cost:** $0/month

**Steps:**
1. Deploy API to Render (15-20 minutes)
2. Deploy frontend to Vercel (5 minutes)
3. Update `dashboard.html` with Render API URL
4. Done! 🎉

---

## Troubleshooting

### API returns 500 errors
- Check Render/Railway logs
- Verify R packages are installed
- Check CSV file path is correct

### CORS errors
- Ensure `CORS(app)` is enabled in `api_server.py`
- Check API URL in `dashboard.html` matches deployed URL

### R script fails
- Check R packages are installed in Dockerfile
- Verify CSV file exists in container
- Check Render logs for R errors

---

## Next Steps

1. Choose your platform (Render recommended)
2. Push code to GitHub
3. Deploy backend
4. Deploy frontend
5. Update API URL in dashboard
6. Test everything!

Good luck with your deployment! 🚀

