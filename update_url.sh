#!/bin/bash

# Exit on any error
set -e

# Check if URL argument is provided
if [ -z "$1" ]; then
  echo "❌ Error: Please provide the Cloudflare URL."
  echo "👉 Usage: ./update_url.sh https://your-tunnel-url.trycloudflare.com"
  exit 1
fi

RAW_URL="$1"

# Strip trailing slashes and /api/v1 if included by mistake
CLEAN_URL=$(echo "$RAW_URL" | sed -e 's|/api/v1/*$||' -e 's|/*$||')

# Ensure URL starts with http:// or https://
if [[ ! "$CLEAN_URL" =~ ^https?:// ]]; then
  CLEAN_URL="https://$CLEAN_URL"
fi

echo "🚀 Updating SoulSync Backend URL to: $CLEAN_URL"

# Python script to safely and accurately replace the URLs in both Dart files
python3 - <<EOF
import re

clean_url = "$CLEAN_URL"

# 1. Update lib/core/config/app_config.dart
app_config_path = "lib/core/config/app_config.dart"
with open(app_config_path, "r") as f:
    content = f.read()

# Replace baseUrl in constructor default
content = re.sub(
    r"(this\.baseUrl\s*=\s*')https://[^']+(\.trycloudflare\.com')",
    rf"\g<1>{clean_url}'",
    content
)
# Replace defaultUrl in ServerUrlNotifier
content = re.sub(
    r"(static const String defaultUrl\s*=\s*')https://[^']+(\.trycloudflare\.com')",
    rf"\g<1>{clean_url}'",
    content
)

with open(app_config_path, "w") as f:
    f.write(content)

# 2. Update lib/core/constants/api_constants.dart
api_constants_path = "lib/core/constants/api_constants.dart"
with open(api_constants_path, "r") as f:
    api_content = f.read()

# Replace baseUrl in ApiConstants
api_content = re.sub(
    r"(static const String baseUrl\s*=\s*')https://[^']+(\.trycloudflare\.com/api/v1')",
    rf"\g<1>{clean_url}/api/v1'",
    api_content
)

with open(api_constants_path, "w") as f:
    f.write(api_content)

print("✅ Files updated successfully.")
EOF

# Git commands: add, commit, and push
echo "📦 Committing and pushing changes to GitHub..."
git add lib/core/config/app_config.dart lib/core/constants/api_constants.dart
if ! git diff-index --quiet --cached HEAD; then
  git commit -m "Update backend Cloudflare tunnel URL to $(echo "$CLEAN_URL" | sed -e 's|https://||' -e 's|\.trycloudflare\.com||')"
else
  echo "ℹ️ No changes detected in Dart files, continuing with push..."
fi
git pull --rebase --autostash origin main
git push origin main

echo ""
echo "🎉 Done! GitHub Actions has been triggered and is now building the app with the new URL."
