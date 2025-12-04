#!/bin/bash

# Script to prepare project for cloud deployment

echo "=========================================="
echo "  Preparing for Cloud Deployment"
echo "=========================================="
echo ""

# Check if CSV file exists
CSV_PATH="/Users/mayanksharma/Desktop/5303 fall/diabetes 2.csv"
if [ -f "$CSV_PATH" ]; then
    echo "✅ CSV file found"
    
    # Create data directory if it doesn't exist
    mkdir -p data
    
    # Copy CSV to data directory
    cp "$CSV_PATH" data/diabetes_2.csv 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ CSV file copied to data/diabetes_2.csv"
    else
        echo "⚠️  Could not copy CSV file. You'll need to add it manually to the data/ folder."
    fi
else
    echo "⚠️  CSV file not found at: $CSV_PATH"
    echo "   Please copy your CSV file to data/diabetes_2.csv"
fi

echo ""
echo "=========================================="
echo "  Next Steps:"
echo "=========================================="
echo ""
echo "1. Push to GitHub:"
echo "   git init"
echo "   git add ."
echo "   git commit -m 'Prepare for deployment'"
echo "   git remote add origin YOUR_REPO_URL"
echo "   git push -u origin main"
echo ""
echo "2. Deploy Backend to Render:"
echo "   - Go to render.com"
echo "   - New Web Service → Connect GitHub"
echo "   - Select your repo"
echo "   - Environment: Docker"
echo "   - Port: 5001"
echo ""
echo "3. Deploy Frontend to Vercel:"
echo "   - Go to vercel.com"
echo "   - Import GitHub repo"
echo "   - Framework: Other"
echo ""
echo "4. Update dashboard.html:"
echo "   - Change API_BASE_URL to your Render URL"
echo ""
echo "=========================================="

