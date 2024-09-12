#!/bin/bash

# Set the directory variable
DIR=$1

# Check if the provided argument is a directory
if [ ! -d "$DIR" ]; then
echo "Error: $DIR is not a directory"
exit 1
fi

# Create or clear the failed_login_data.txt file
> "$DIR/failed_login_data.txt"

# Process each log file in the directory
for FILE in "$DIR"/*; do
if [ -f "$FILE" ]; then
    # Extract and format the failed login data
    grep "Failed password" "$FILE" | awk '{print $1, $2, substr($3, 1, 2), $9, $11}' >> "$DIR/failed_login_data.txt"
fi
done

echo "Processing complete. Output written to $DIR/failed_login_data.txt"