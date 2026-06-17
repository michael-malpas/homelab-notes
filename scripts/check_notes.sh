#!/bin/bash

echo "Checking markdown files..."

count=$(find . -name "*.md" | wc -l)

echo "Markdown files: $count"

if [ "$count" -lt 5 ]; then
	echo "Not enough documentation!"
	exit 1
fi

echo "Validation passed."
