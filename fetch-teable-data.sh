#!/bin/bash

# Teable API Configuration
TEABLE_BASE_URL="https://app.teable.ai/api"
TABLE_ID="tbl6GOlfPz8ZHgez4Pl"
VIEW_ID="viwLvzWJa7rviDmC6Kj"

# Configuration file for API token
CONFIG_FILE=".teable-config"

# Output file
OUTPUT_FILE="data/springs.json"

# Check for API token
if [ -n "$1" ]; then
    # Use command line argument (highest priority)
    API_TOKEN="$1"
elif [ -f "$CONFIG_FILE" ]; then
    # Load token from config file
    source "$CONFIG_FILE"
    API_TOKEN="$TEABLE_API_TOKEN"
elif [ -n "$TEABLE_API_TOKEN" ]; then
    # Use environment variable
    API_TOKEN="$TEABLE_API_TOKEN"
else
    echo "❌ Teable API token not found!"
    echo ""
    echo "Please provide your API token in one of these ways:"
    echo "1. Create a .teable-config file with: TEABLE_API_TOKEN='your_token_here'"
    echo "2. Set TEABLE_API_TOKEN environment variable"
    echo "3. Pass as argument: ./fetch-teable-data.sh YOUR_API_TOKEN"
    exit 1
fi

echo "🔍 Fetching data from Teable..."

# Fetch data from Teable API
RESPONSE=$(curl -s -X GET \
  "${TEABLE_BASE_URL}/table/${TABLE_ID}/record?viewId=${VIEW_ID}" \
  -H "Authorization: Bearer ${API_TOKEN}" \
  -H "Accept: application/json")

# Check if curl failed
if [ $? -ne 0 ]; then
    echo "❌ Failed to fetch data from Teable API"
    exit 1
fi

# Check for errors in response
if echo "$RESPONSE" | grep -q '"error"\|"message"'; then
    HTTP_STATUS=$(echo "$RESPONSE" | jq -r '.status // .code // "unknown"')
    echo "❌ API Error (Status: $HTTP_STATUS):"
    echo "$RESPONSE" | jq '.'
    echo ""
    if echo "$RESPONSE" | grep -q '403\|restricted_resource'; then
        echo "🔐 Permission Denied (403)"
        echo ""
        echo "To fix this:"
        echo "1. Verify your API token has 'record|read' permission for this table"
        echo "2. Check that TABLE_ID and VIEW_ID in this script are correct"
        echo "3. In Teable, go to: Table Settings > API & Connectors > regenerate token"
        echo ""
        echo "Test with:"
        echo "  curl -H \"Authorization: Bearer YOUR_TOKEN\" \\"
        echo "    https://app.teable.ai/api/table/${TABLE_ID}/record?viewId=${VIEW_ID}\""
    fi
    exit 1
fi

echo "📊 Transforming data..."

# Transform Teable data format to springs.json format
# Assuming Teable has columns: Name, Slug, Temp_F, Fee, GPS, Description
TRANSFORMED_DATA=$(echo "$RESPONSE" | jq '[
  .records[] |
  {
    name: (.fields.Name // .fields.name // ""),
    slug: (.fields.Slug // .fields.slug // ""),
    temp_f: (.fields.Temp_F // .fields.temp_f // .fields.temperature // 0 | tonumber),
    fee: (.fields.Fee // .fields.fee // .fields.cost // 0 | tonumber),
    gps: (.fields.GPS // .fields.gps // .fields.coordinates // ""),
    description: (.fields.Description // .fields.description // .fields.desc // ""),
    location: (.fields.Location // .fields.location // ""),
    website: (.fields.Website // .fields.website // ""),
    amenities: (.fields.Amenities // .fields.amenities // [])
  }
] | map(select(.name != "" and .slug != ""))')

# Check if transformation produced valid data
if [ "$TRANSFORMED_DATA" = "[]" ] || [ -z "$TRANSFORMED_DATA" ]; then
    echo "⚠️  No valid records found in Teable response"
    echo ""
    echo "Raw API response:"
    echo "$RESPONSE" | jq '.'
    exit 1
fi

# Save to springs.json
echo "$TRANSFORMED_DATA" | jq '.' > "$OUTPUT_FILE"

# Verify file was created
if [ -f "$OUTPUT_FILE" ]; then
    RECORD_COUNT=$(echo "$TRANSFORMED_DATA" | jq 'length')
    echo "✅ Success! Fetched $RECORD_COUNT records and saved to $OUTPUT_FILE"
    
    # Show first few records as preview
    echo ""
    echo "Preview of transformed data:"
    echo "$TRANSFORMED_DATA" | jq '.[0:3]'
else
    echo "❌ Failed to save data to $OUTPUT_FILE"
    exit 1
fi