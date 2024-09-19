#!/bin/bash

# Check if at least one argument is provided
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <log_archive1.tgz> <log_archive2.tgz> ..."
  exit 1
fi

# Create a temporary scratch directory
SCRATCH_DIR=$(mktemp -d)

# Function to clean up the scratch directory on exit
cleanup() {
  rm -rf "$SCRATCH_DIR"
}
trap cleanup EXIT

# Loop over the provided gzipped tar files
for ARCHIVE in "$@"; do
  # Extract the machine name from the archive name
  MACHINE_NAME=$(basename "$ARCHIVE" _secure.tgz)
  
  # Create a directory for this machine in the scratch directory
  MACHINE_DIR="$SCRATCH_DIR/$MACHINE_NAME"
  mkdir -p "$MACHINE_DIR"
  
  # Extract the contents of the archive into the machine directory
  tar -xzf "$ARCHIVE" -C "$MACHINE_DIR"
  
  # Call process_client_logs.sh
  ./bin/process_client_logs.sh "$MACHINE_DIR"
done

# Call create_username_dist.sh
./bin/create_username_dist.sh "$SCRATCH_DIR"

# Call create_hours_dist.sh
./bin/create_hours_dist.sh "$SCRATCH_DIR"

# Call create_country_dist.sh
./bin/create_country_dist.sh "$SCRATCH_DIR"

# Call assemble_report.sh
./bin/assemble_report.sh "$SCRATCH_DIR"

# Move the final report to the current directory
mv "$SCRATCH_DIR/failed_login_summary.html" .
