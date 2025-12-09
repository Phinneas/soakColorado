#!/bin/bash
# Use this script to test with sample data instead of fetching from Teable

echo "📋 Using sample data for testing..."
cp data/springs.sample.json data/springs.json

# Show what data we're working with
echo ""
echo "Sample data loaded:"
cat data/springs.json | jq '.'

echo ""
echo "✅ Sample data ready! Run './build-pages.sh && hugo --minify' to build the site"