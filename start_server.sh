#!/bin/bash

# Startup script for Dynamic Dashboard
# This script starts both the API server and web server

echo "Starting Dynamic Dashboard System..."
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed"
    exit 1
fi

# Check if R is installed
if ! command -v Rscript &> /dev/null; then
    echo "Error: R is not installed"
    exit 1
fi

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check if virtual environment exists, create if not
if [ ! -d ".venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv .venv
fi

# Activate virtual environment
echo "Activating virtual environment..."
source .venv/bin/activate

# Check if required Python packages are installed
echo "Checking Python dependencies..."
python -c "import flask, flask_cors" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Installing Python dependencies..."
    pip install -r requirements.txt
fi

# Start API server in background
echo "Starting API server on port 5001..."
python api_server.py &
API_PID=$!

# Wait a moment for API server to start
sleep 2

# Check if API server started successfully
if ! kill -0 $API_PID 2>/dev/null; then
    echo "Error: API server failed to start"
    exit 1
fi

echo "API server started (PID: $API_PID)"
echo ""

# Start web server
echo "Starting web server on port 8000..."
echo "Open http://localhost:8000/dashboard.html in your browser"
echo ""
echo "Press Ctrl+C to stop both servers"
echo ""

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "Stopping servers..."
    kill $API_PID 2>/dev/null
    exit 0
}

trap cleanup SIGINT SIGTERM

# Start web server (this will block)
python -m http.server 8000

