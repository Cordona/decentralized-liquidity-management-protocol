#!/bin/bash

# Ensure the script is called with the environment file as the first argument
if [ -z "$1" ]; then
    echo "ERROR: No environment file specified." >&2
    exit 1
fi

ENV_FILE=$1

# Check if the environment file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "ERROR: Environment file '$ENV_FILE' not found." >&2
    exit 1
fi

# Export valid environment variables
while IFS= read -r line || [ -n "$line" ]; do
    # Skip empty lines and comments
    if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then
        # Validate the format of the environment variable (VAR=VALUE)
        if [[ "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; then
            # Print the variable in the format `export VAR=value`
            echo "export $line"
        else
            echo "WARNING: Skipping invalid line: $line" >&2
        fi
    fi
done < "$ENV_FILE"