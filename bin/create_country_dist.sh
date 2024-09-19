#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Directory containing the sub-directories
DIR="$1"

# Create or clear the country_dist.html file in the specified directory
OUTPUT_FILE="$DIR/country_dist.html"
#> "$OUTPUT_FILE"

# Initialize an associative array to count countries
declare -A country_counts

# Path to the IP to country mapping file
IP_COUNTRY_MAP="etc/country_IP_map.txt"

# Process each sub-directory
for SUBDIR in "$DIR"/*; do
  if [ -d "$SUBDIR" ]; then
    FAILED_LOGIN_FILE="$SUBDIR/failed_login_data.txt"
    if [ -f "$FAILED_LOGIN_FILE" ]; then
      # Extract IP addresses
      awk '{print $5}' "$FAILED_LOGIN_FILE" | sort > "$SUBDIR/ip_addresses.txt"
      # Map IP addresses to countries
      join -1 1 -2 1 "$SUBDIR/ip_addresses.txt" <(sort -k 1,1 "$IP_COUNTRY_MAP") | awk '{print $2}' | sort | uniq -c > "$SUBDIR/country_counts.txt"
      # Count occurrences of each country
      while read -r count country; do
        ((country_counts["$country"]+=count))
      done < "$SUBDIR/country_counts.txt"
    fi
  fi
done

# Generate the data section for the geo chart
DATA_FILE=$(mktemp)
{
  for country in $(printf "%s\n" "${!country_counts[@]}" | sort); do
    echo "data.addRow(['${country}', ${country_counts[$country]}]);"
  done
} > "$DATA_FILE"

# Remove the trailing comma from the last data.addRow line
sed -i '$ s/,$//' "$DATA_FILE"

# Wrap the data section with the header and footer
./bin/wrap_contents.sh "$DATA_FILE" html_components/country_dist "$OUTPUT_FILE"

# Clean up the temporary data file
rm "$DATA_FILE"