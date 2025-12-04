# Quick Deploy Guide - Render + Vercel

## 🚀 Fastest Way to Deploy (15 minutes)

### Step 1: Prepare Files (2 min)

```bash
# Run preparation script
./prepare_for_deployment.sh

# Initialize git (if not already)
git init
git add .
git commit -m "Ready for deployment"
```

### Step 2: Push to GitHub (3 min)

1. Create a new repository on GitHub
2. Push your code:
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
   git push -u origin main
   ```

### Step 3: Deploy Backend to Render (5 min)

1. Go to [render.com](https://render.com) → Sign up (free)
2. Click **"New +"** → **"Web Service"**
3. Connect your GitHub account
4. Select your repository
5. Configure:
   - **Name:** `diabetes-api` (or any name)
   - **Environment:** `Docker`
   - **Dockerfile Path:** `Dockerfile` (should auto-detect)
   - **Port:** `5001`
   - **Plan:** `Free`
6. Click **"Create Web Service"**
7. Wait for deployment (5-10 minutes)
8. Copy your URL: `https://your-app-name.onrender.com`

### Step 4: Deploy Frontend to Vercel (3 min)

1. Go to [vercel.com](https://vercel.com) → Sign up (free)
2. Click **"Add New Project"**
3. Import your GitHub repository
4. Configure:
   - **Framework Preset:** `Other`
   - **Root Directory:** `./` (leave as is)
5. Click **"Deploy"**
6. Wait 1-2 minutes
7. Copy your URL: `https://your-project.vercel.app`

### Step 5: Connect Frontend to Backend (2 min)

1. Edit `dashboard.html`:
   - Find line: `const API_BASE_URL = 'http://localhost:5001';`
   - Change to: `const API_BASE_URL = 'https://your-app-name.onrender.com';`
   - Replace `your-app-name` with your actual Render app name

2. Commit and push:
   ```bash
   git add dashboard.html
   git commit -m "Update API URL for production"
   git push
   ```

3. Vercel will auto-deploy the update (takes 1-2 minutes)

### Step 6: Test! 🎉

1. Open your Vercel URL: `https://your-project.vercel.app/dashboard.html`
2. Test the slider - it should work!
3. Test SMOTE toggle

---

## 📝 Important Notes

### CSV File

Make sure your CSV file is in the `data/` folder:
```bash
mkdir -p data
cp "/Users/mayanksharma/Desktop/5303 fall/diabetes 2.csv" data/diabetes_2.csv
git add data/diabetes_2.csv
git commit -m "Add dataset"
git push
```

### Free Tier Limits

- **Render:** Free tier may spin down after 15 min of inactivity (first request will be slow)
- **Vercel:** Unlimited requests on free tier
- **Solution:** Keep Render "always on" (paid) or accept slow first request

### Update vercel.json

After deploying, update `vercel.json` with your actual Render URL:
```json
{
  "rewrites": [
    {
      "source": "/api/:path*",
      "destination": "https://YOUR-ACTUAL-RENDER-URL.onrender.com/:path*"
    }
  ]
}
```

---

## 🎯 Your Live URLs

After deployment, you'll have:
- **Dashboard:** `https://your-project.vercel.app/dashboard.html`
- **API:** `https://your-app-name.onrender.com`

Share the Vercel URL for your presentation! 🚀

---

## ⚠️ Troubleshooting

### API returns 500 error
- Check Render logs
- Verify CSV file is in `data/` folder
- Check R packages installed correctly

### CORS errors
- Already handled in `api_server.py` with `CORS(app)`
- If still issues, check API URL is correct

### Slow first request
- Render free tier spins down after inactivity
- First request takes 30-60 seconds to wake up
- Subsequent requests are fast

---

## ✅ Checklist

- [ ] CSV file in `data/` folder
- [ ] Code pushed to GitHub
- [ ] Backend deployed to Render
- [ ] Frontend deployed to Vercel
- [ ] API URL updated in `dashboard.html`
- [ ] Tested slider movement
- [ ] Tested SMOTE toggle
- [ ] Everything works! 🎉

Good luck with your presentation! 🚀

