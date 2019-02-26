#!/bin/bash

set -e
ZIP_FILE_NAME="copy-ami.zip"
rm -f ${ZIP_FILE_NAME} && zip -q "${ZIP_FILE_NAME}" lambda_function.py
jq -n --arg deploydoc "$ZIP_FILE_NAME" '{"deploydoc":$deploydoc}'
