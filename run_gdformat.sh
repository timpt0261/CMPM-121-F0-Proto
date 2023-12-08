#!/bin/bash

# Change to the script directory
cd "$(dirname "$0")"

# Run gdformat on all .gd files
gdformat *.gd
