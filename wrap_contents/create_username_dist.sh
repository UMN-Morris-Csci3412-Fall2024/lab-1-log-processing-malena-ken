#!/bin/bash

# Set the directory variable
DIR=$1

# Check if the provided argument is a directory
if [ ! -d "$DIR" ]; then
  echo "Error: $DIR is not a directory"
  exit 1
fi

# Create or clear the username_dist.html file
OUTPUT_FILE="$DIR/username_dist.html"
> "$OUTPUT_FILE"

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

# Generate the HTML/JavaScript structure
{
  echo "<!DOCTYPE html>"
  echo "<html lang=\"en\">"
  echo "<head>"
  echo "  <meta charset=\"UTF-8\">"
  echo "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
  echo "  <title>Username Distribution</title>"
  echo "  <script type=\"text/javascript\" src=\"https://www.gstatic.com/charts/loader.js\"></script>"
  echo "  <script type=\"text/javascript\">"
  echo "    google.charts.load('current', {'packages':['corechart']});"
  echo "    google.charts.setOnLoadCallback(drawChart);"
  echo "    function drawChart() {"
  echo "      var data = google.visualization.arrayToDataTable(["
  echo "        ['Username', 'Count'],"
  for username in "${!username_counts[@]}"; do
    echo "        ['$username', ${username_counts[$username]}],"
  done
  echo "      ]);"
  echo "      var options = {"
  echo "        title: 'Username Distribution',"
  echo "        pieHole: 0.4,"
  echo "      };"
  echo "      var chart = new google.visualization.PieChart(document.getElementById('donutchart'));"
  echo "      chart.draw(data, options);"
  echo "    }"
  echo "  </script>"
  echo "</head>"
  echo "<body>"
  echo "  <div id=\"donutchart\" style=\"width: 900px; height: 500px;\"></div>"
  echo "</body>"
  echo "</html>"
} >> "$OUTPUT_FILE"

echo "Username distribution HTML generated at $OUTPUT_FILE"