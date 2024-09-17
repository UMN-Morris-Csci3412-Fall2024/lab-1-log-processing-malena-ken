#!/bin/bash

# Set the directory variable
DIR=$1

# Check if the provided argument is a directory
if [ ! -d "$DIR" ]; then
  echo "Error: $DIR is not a directory"
  exit 1
fi

# Create or clear the hours_dist.html file
OUTPUT_FILE="$DIR/hours_dist.html"
#> "$OUTPUT_FILE"

# Initialize an associative array to count hours
declare -A hour_counts

# Process each sub-directory
for SUBDIR in "$DIR"/*; do
  if [ -d "$SUBDIR" ]; then
    FAILED_LOGIN_FILE="$SUBDIR/failed_login_data.txt"
    if [ -f "$FAILED_LOGIN_FILE" ]; then
      # Extract hours and count occurrences
      while read -r line; do
        hour=$(echo "$line" | awk '{print substr($3, 1, 2)}')
        ((hour_counts["$hour"]++))
      done < "$FAILED_LOGIN_FILE"
    fi
  fi
done

# Generate the data section for the column chart
DATA_FILE=$(mktemp)
{
  for hour in $(printf "%s\n" "${!hour_counts[@]}" | sort); do
    echo "data.addRow(['${hour}', ${hour_counts[$hour]}]);"
  done
} > "$DATA_FILE"

# Remove the trailing comma from the last data.addRow line
sed -i '$ s/,$//' "$DATA_FILE"

# Wrap the data section with the header and footer
./bin/wrap_contents.sh "$DATA_FILE" html_components/hours_dist "$OUTPUT_FILE"

# Clean up the temporary data file
rm "$DATA_FILE"

echo "Hours distribution HTML generated at $OUTPUT_FILE"