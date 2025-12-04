#!/bin/bash

# Helper script to kill processes on ports 5000 and 8000

echo "Checking for processes on ports 5001 and 8000..."

# Kill process on port 5001 (API server)
# Note: Port 5000 is used by macOS AirPlay, so we use 5001
PID_5001=$(lsof -ti:5001)
if [ ! -z "$PID_5001" ]; then
    echo "Killing process $PID_5001 on port 5001..."
    kill $PID_5001
    echo "✓ Port 5001 is now free"
else
    echo "✓ Port 5001 is free"
fi

# Kill process on port 8000 (Web server)
PID_8000=$(lsof -ti:8000)
if [ ! -z "$PID_8000" ]; then
    echo "Killing process $PID_8000 on port 8000..."
    kill $PID_8000
    echo "✓ Port 8000 is now free"
else
    echo "✓ Port 8000 is free"
fi

echo ""
echo "All ports are now available!"

