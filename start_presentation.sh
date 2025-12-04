#!/bin/bash

# Simple Presentation Startup Script
# Run this before your presentation

clear
echo "=========================================="
echo "  Diabetes Dashboard - Presentation Mode"
echo "=========================================="
echo ""

# Check dependencies
echo "Checking dependencies..."
if ! command -v python3 &> /dev/null; then
    echo "❌ ERROR: Python 3 not found!"
    exit 1
fi

if ! command -v Rscript &> /dev/null; then
    echo "❌ ERROR: R not found!"
    exit 1
fi

echo "✅ Python found"
echo "✅ R found"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Kill any existing servers
echo "Cleaning up existing servers..."
./kill_ports.sh 2>/dev/null
sleep 1

# Setup virtual environment if needed
if [ ! -d ".venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv .venv
fi

# Activate virtual environment
source .venv/bin/activate

# Install dependencies if needed
python -c "import flask, flask_cors" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Installing Python dependencies..."
    pip install -q -r requirements.txt
fi

echo ""
echo "Starting servers..."
echo ""

# Start API server
echo "🚀 Starting API server (port 5001)..."
python api_server.py > /tmp/api_server.log 2>&1 &
API_PID=$!
sleep 3

# Check if API started
if ! kill -0 $API_PID 2>/dev/null; then
    echo "❌ API server failed to start!"
    echo "Check /tmp/api_server.log for errors"
    exit 1
fi

# Test API health
sleep 1
if curl -s http://localhost:5001/health > /dev/null; then
    echo "✅ API server running (PID: $API_PID)"
else
    echo "⚠️  API server started but health check failed"
fi

# Start web server
echo "🌐 Starting web server (port 8000)..."
python -m http.server 8000 > /tmp/web_server.log 2>&1 &
WEB_PID=$!
sleep 1

echo "✅ Web server running (PID: $WEB_PID)"
echo ""
echo "=========================================="
echo "  ✅ Dashboard is ready!"
echo "=========================================="
echo ""
echo "📍 Open in browser:"
echo "   http://localhost:8000/dashboard.html"
echo ""
echo "📊 API Health Check:"
echo "   http://localhost:5001/health"
echo ""
echo "⏹️  To stop: Press Ctrl+C or run ./kill_ports.sh"
echo ""
echo "=========================================="
echo ""

# Cleanup function
cleanup() {
    echo ""
    echo "Stopping servers..."
    kill $API_PID 2>/dev/null
    kill $WEB_PID 2>/dev/null
    echo "✅ Servers stopped"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Keep script running
echo "Servers are running. Press Ctrl+C to stop."
echo ""
# Wait for interrupt
while true; do
    sleep 1
done

