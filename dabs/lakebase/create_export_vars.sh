#!/bin/bash

# Script to convert pg_vars.txt to set_lakebase_variable.sh
# Reads the comma-separated quoted key=value pairs and converts them to export statements

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUT_FILE="${SCRIPT_DIR}/pg_vars.txt"
OUTPUT_FILE="${SCRIPT_DIR}/set_lakebase_variable.sh"

# Check if input file exists
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: Input file $INPUT_FILE not found"
    exit 1
fi

# Create/overwrite the output file
> "$OUTPUT_FILE"

# Read each line from pg_vars.txt and convert to export statement
while IFS= read -r line || [[ -n "$line" ]]; do
    # Remove leading/trailing whitespace, quotes, and trailing comma
    cleaned=$(echo "$line" | sed 's/^[[:space:]]*"//g' | sed 's/",[[:space:]]*$//g' | sed 's/"$//g')
    
    # Skip empty lines
    if [[ -z "$cleaned" ]]; then
        continue
    fi
    
    # Extract variable name and value
    varname=$(echo "$cleaned" | cut -d= -f1)
    value=$(echo "$cleaned" | cut -d= -f2-)
    
    # Write export statement to output file
    echo "export ${varname}='${value}'" >> "$OUTPUT_FILE"
done < "$INPUT_FILE"

echo "Successfully created $OUTPUT_FILE from $INPUT_FILE"
