import os
from flask import Flask, jsonify

app = Flask(__name__)

# Read settings from outside the app (with safe defaults)
APP_VERSION = os.getenv("APP_VERSION", "v1.0.0")
FAIL_HEALTH = os.getenv("FAIL_HEALTH", "false").lower() == "true"

@app.route("/")
def home():
    return jsonify({
        "service": "nomad-canary-demo",
        "version": APP_VERSION,
        "status": "running"
    }), 200

@app.route("/health")
def health():
    if FAIL_HEALTH:
        
        return jsonify({"status": "unhealthy", "version": APP_VERSION}), 500
    
    
    return jsonify({"status": "healthy", "version": APP_VERSION}), 200

if __name__ == "__main__":
    
    app.run(host="0.0.0.0", port=8080)
