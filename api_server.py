#!/usr/bin/env python3
"""
Flask API Server for Dynamic Diabetes Model Analysis
Executes R scripts with different class imbalance and SMOTE parameters
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import subprocess
import json
import os
import tempfile
import time

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Paths
R_SCRIPT_PATH = os.path.join(os.path.dirname(__file__), "model_analysis.R")
BASE_DIR = os.path.dirname(__file__)

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({"status": "healthy", "message": "API is running"})

@app.route('/analyze', methods=['POST'])
def analyze():
    """
    Execute R script with given parameters
    Expected JSON body:
    {
        "no_diabetes_pct": 65,  # Percentage for No Diabetes class (40-60)
        "use_smote": false      # Whether to use SMOTE
    }
    """
    try:
        data = request.get_json()
        
        # Validate inputs
        no_diabetes_pct = float(data.get('no_diabetes_pct', 65))
        use_smote = bool(data.get('use_smote', False))
        
        # Validate percentage range
        if not (40 <= no_diabetes_pct <= 70):
            return jsonify({"error": "no_diabetes_pct must be between 40 and 70"}), 400
        
        # Create temporary output file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False, dir=BASE_DIR) as tmp_file:
            output_file = tmp_file.name
        
        try:
            # Execute R script
            # Rscript model_analysis.R <no_diabetes_pct> <use_smote> <output_file>
            cmd = [
                'Rscript',
                R_SCRIPT_PATH,
                str(no_diabetes_pct),
                str(use_smote),
                output_file
            ]
            
            start_time = time.time()
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=120  # 2 minute timeout
            )
            execution_time = time.time() - start_time
            
            if result.returncode != 0:
                error_msg = result.stderr or result.stdout
                return jsonify({
                    "error": "R script execution failed",
                    "details": error_msg,
                    "returncode": result.returncode
                }), 500
            
            # Read results from JSON file
            if not os.path.exists(output_file):
                return jsonify({
                    "error": "Output file was not created",
                    "stdout": result.stdout,
                    "stderr": result.stderr
                }), 500
            
            with open(output_file, 'r') as f:
                results = json.load(f)
            
            # Add metadata
            results['metadata'] = {
                'execution_time': round(execution_time, 2),
                'parameters': {
                    'no_diabetes_pct': no_diabetes_pct,
                    'use_smote': use_smote
                }
            }
            
            return jsonify(results)
            
        finally:
            # Clean up temporary file
            if os.path.exists(output_file):
                try:
                    os.remove(output_file)
                except:
                    pass
                    
    except subprocess.TimeoutExpired:
        return jsonify({"error": "R script execution timed out"}), 500
    except Exception as e:
        return jsonify({"error": str(e), "type": type(e).__name__}), 500

@app.route('/baseline', methods=['GET'])
def baseline():
    """Get baseline results (65/35, no SMOTE)"""
    try:
        with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False, dir=BASE_DIR) as tmp_file:
            output_file = tmp_file.name
        
        try:
            cmd = [
                'Rscript',
                R_SCRIPT_PATH,
                '65',
                'False',
                output_file
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
            
            if result.returncode != 0:
                return jsonify({"error": "Failed to get baseline"}), 500
            
            with open(output_file, 'r') as f:
                results = json.load(f)
            
            return jsonify(results)
            
        finally:
            if os.path.exists(output_file):
                try:
                    os.remove(output_file)
                except:
                    pass
                    
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    print("Starting Diabetes Model Analysis API Server...")
    print(f"R Script Path: {R_SCRIPT_PATH}")
    print(f"R Script Exists: {os.path.exists(R_SCRIPT_PATH)}")
    # Use PORT environment variable for cloud deployment (Render, Railway, etc.)
    port = int(os.environ.get('PORT', 5001))
    debug = os.environ.get('DEBUG', 'False').lower() == 'true'
    app.run(host='0.0.0.0', port=port, debug=debug)

