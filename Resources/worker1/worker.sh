#!/bin/bash

# Clone repository
git clone https://github.com/fuaddary/fp-tka.git

# Change directory to BE folder
cd fp-tka/Resources/BE

# Setup MongoDB
sudo apt update
sudo apt install -y mongodb
sudo systemctl start mongodb
sudo systemctl enable mongodb

# Verify MongoDB installation
if mongosh --eval "db.runCommand({ connectionStatus: 1 })"; then
    echo "MongoDB setup successfully."
else
    echo "MongoDB setup failed."
    exit 1
fi

# Setup Python environment and install dependencies
sudo apt install -y python3-venv
python3 -m venv venv
source venv/bin/activate
pip install flask flask-cors textblob pymongo

# Rename the sentiment analysis file
mv sentiment-analysis.py sentiment_analysis.py

# Increase file descriptor limit
ulimit -n 100000
