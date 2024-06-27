#!/bin/bash

source venv/bin/activate
gunicorn -b 0.0.0.0:5000 -w 5 -k gevent --timeout 60 --graceful-timeout 60 sentiment_analysis:app
