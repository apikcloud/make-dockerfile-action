#!/bin/bash

set -e

WORKDIR="$1"
FILENAME="$2"
BASE="$3"
DEV="$4"

python3 /app/main.py --workdir "$WORKDIR" --base "$BASE" --output --filename "$FILENAME" "$DEV"