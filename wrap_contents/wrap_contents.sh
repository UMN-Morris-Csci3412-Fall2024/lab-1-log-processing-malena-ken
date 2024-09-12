#!/bin/bash

# This script takes in three arguments: the contents to wrap, the header specifier, and the output file name
contents=$1
header_specifier=$2
result=$3

# Create the header and footer files names
header_file="${header_specifier}_header.html"
footer_file="${header_specifier}_footer.html"

# Joining the contents, header, and footer into the result file
cat "$header_file" "$contents" "$footer_file" > "$result"

