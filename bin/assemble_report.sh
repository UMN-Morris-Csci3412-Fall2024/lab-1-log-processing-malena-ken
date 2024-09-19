#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Directory containing the HTML files
DIR="$1"

# Create or clear the failed_login_summary.html file in the specified directory
OUTPUT_FILE="$DIR/failed_login_summary.html"
> "$OUTPUT_FILE"

# Temporary file to hold the combined contents
TEMP_FILE=$(mktemp)

# Collect the contents of the three HTML files
cat "$DIR/country_dist.html" "$DIR/hours_dist.html" "$DIR/username_dist.html" > "$TEMP_FILE"

# Wrap the combined contents with the overall header and footer
./bin/wrap_contents.sh "$TEMP_FILE" html_components/summary_plots "$OUTPUT_FILE"

# Clean up the temporary file
rm "$TEMP_FILE"

# Debug: Output the contents of the failed_login_summary.html file
echo "Contents of $OUTPUT_FILE:"
cat "$OUTPUT_FILE"

