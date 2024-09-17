#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Directory containing the sub-directories
DIR="$1"

# Create or clear the username_dist.html file in the specified directory
OUTPUT_FILE="$DIR/username_dist.html"
#> "$OUTPUT_FILE"

# Initialize an associative array to count usernames
declare -A username_counts

# Process each sub-directory
for SUBDIR in "$DIR"/*; do
  if [ -d "$SUBDIR" ]; then
    FAILED_LOGIN_FILE="$SUBDIR/failed_login_data.txt"
    if [ -f "$FAILED_LOGIN_FILE" ]; then
      # Extract usernames and count occurrences
      while read -r line; do
        username=$(echo "$line" | awk '{print $4}')
        ((username_counts["$username"]++))
      done < "$FAILED_LOGIN_FILE"
    fi
  fi
done

# Generate the data section for the pie chart
DATA_FILE=$(mktemp)
{
  echo "data.addRows(["
  for username in "${!username_counts[@]}"; do
    echo "  ['${username}', ${username_counts[$username]}],"
  done
  echo "]);"
} > "$DATA_FILE"

# Remove the trailing comma from the last data.addRow line
sed -i '$ s/,$//' "$DATA_FILE"

# Wrap the data section with the header and footer
./bin/wrap_contents.sh "$DATA_FILE" html_components/username_dist "$OUTPUT_FILE"

# Clean up the temporary data file
rm "$DATA_FILE"