#!/bin/bash

# Fetch fresh data from Teable before generating pages
echo "📥 Fetching data from Teable..."
./fetch-teable-data.sh

if [ $? -ne 0 ]; then
    echo "❌ Failed to fetch data from Teable. Aborting."
    exit 1
fi

# Check if data file exists and is not empty
if [ ! -s "data/springs.json" ]; then
    echo "⚠️  No spring data available. Skipping page generation."
    exit 0
fi

jq -c '.[]' data/springs.json | while read -r spring; do
    name=$(echo "$spring" | jq -r '.name')
    slug=$(echo "$spring" | jq -r '.slug')
    temp_f=$(echo "$spring" | jq -r '.temp_f')
    fee=$(echo "$spring" | jq -r '.fee')
    gps=$(echo "$spring" | jq -r '.gps')
    description=$(echo "$spring" | jq -r '.description')
    
    cat > "content/springs/${slug}.md" << EOF
---
title: "${name} Hot Springs"
name: "${name}"
temp_f: ${temp_f}
fee: ${fee}
gps: "${gps}"
description: "${description}"
type: springs
---

# ${name} Hot Springs

${description}

**Temperature:** ${temp_f}°F  
**Fee:** \$${fee}  
**GPS:** ${gps}
EOF
done