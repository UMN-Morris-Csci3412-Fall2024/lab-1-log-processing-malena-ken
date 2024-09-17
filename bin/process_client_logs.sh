#!/bin/bash

# Directory containing the log files
DIR="$1"

# Move to the specified directory
cd "$DIR" || exit


# Process the log files
find . -type f -print0| xargs -0 cat | awk '
    /Failed password/ {
        if ($9 == "invalid") {
            print $1, $2, substr($3, 1, 2), $11, $13
        } else {
            print $1, $2, substr($3, 1, 2), $9, $11
        }
    }
' > failed_login_data.txt


# Debug: Output the contents of the failed_login_data.txt file
# cat failed_login_data.txt