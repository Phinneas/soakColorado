# Teable Integration Setup

This guide explains how to integrate your Teable table with the Colorado Hot Springs Directory.

## Setup Instructions

### 1. Get Your Teable API Token

1. Log in to your Teable account at https://app.teable.ai
2. Go to your profile settings
3. Generate an API token
4. Copy the token (it starts with `tea_`)

### 2. Configure API Token

Choose one of these methods:

**Option A: Config File (Recommended)**
```bash
cp .teable-config.example .teable-config
```

Edit `.teable-config` and add your token:
```bash
TEABLE_API_TOKEN='your_token_here'
```

**Option B: Environment Variable**
```bash
export TEABLE_API_TOKEN='your_token_here'
```

**Option C: Command Line Argument**
```bash
./fetch-teable-data.sh 'your_token_here'
```

### 3. Verify Table Structure

Your Teable table should have these columns (case-insensitive):

| Column Name | Type | Required | Description |
|------------|------|----------|-------------|
| Name | Single line text | ✅ Yes | Hot spring name (e.g., "Ouray") |
| Slug | Single line text | ✅ Yes | URL-friendly slug (e.g., "ouray") |
| Temp_F | Number | ✅ Yes | Temperature in Fahrenheit |
| Fee | Number | ✅ Yes | Entry fee in USD |
| GPS | Single line text | ✅ Yes | Coordinates (e.g., "38.0267° N, 107.6733° W") |
| Description | Long text | ✅ Yes | Description of the hot spring |
| Location | Single line text | No | General location/region |
| Website | URL | No | Official website URL |
| Amenities | Multiple select | No | List of amenities |

### 4. Test the Integration

Run the fetch script:
```bash
./fetch-teable-data.sh
```

You should see:
```
🔍 Fetching data from Teable...
📊 Transforming data...
✅ Success! Fetched X records and saved to data/springs.json
```

### 5. Build the Site

Generate spring pages and build the static site:
```bash
# Option 1: Full build (fetch data + generate pages + build site)
./build-pages.sh && hugo --minify

# Option 2: If you already have data in springs.json
hugo --minify
```

### 6. Deploy

Deploy the `public/` directory to your hosting provider.

## Troubleshooting

### "API token not found"
- Make sure `.teable-config` exists and contains your token
- Or set `TEABLE_API_TOKEN` environment variable
- Or pass token as command line argument

### "No valid records found"
- Verify your table has the required columns
- Check column names match (case-insensitive)
- Ensure records have values in required fields

### "Failed to fetch data from Teable"
- Check your internet connection
- Verify the table ID and view ID in `fetch-teable-data.sh`
- Ensure your API token has access to the table

## Security Notes

- **NEVER** commit `.teable-config` to git (it's in `.gitignore`)
- **NEVER** share your API token
- Use environment variables in CI/CD pipelines
- Rotate API tokens regularly

## Automating Builds

For automated deployments, set the `TEABLE_API_TOKEN` environment variable in your CI/CD pipeline:

**GitHub Actions:**
```yaml
env:
  TEABLE_API_TOKEN: ${{ secrets.TEABLE_API_TOKEN }}
```

**Netlify:**
Add `TEABLE_API_TOKEN` to Build environment variables

**Vercel:**
Add `TEABLE_API_TOKEN` to Environment Variables

## Support

Need help? Check:
1. Teable API documentation: https://help.teable.ai/en/api
2. This integration uses Teable REST API v1
3. Table schema must match expected columns above