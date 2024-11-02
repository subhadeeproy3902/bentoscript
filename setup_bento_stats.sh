
#!/bin/bash

# Prompt for GitHub details and user-specific links
read -p "Enter your GitHub username: " USERNAME
read -p "Enter your GitHub email: " EMAIL

# Define API and image link based on provided input
API_LINK=""
BENTO_LINK=""

echo "Generated API Link: $API_LINK"
echo "Generated Bento Link: $BENTO_LINK"

# Create README.md dynamically with Bento Link
echo "# Bento GitHub Stats for $USERNAME" > README.md
echo "$BENTO_LINK" >> README.md
echo "Updated README.md with dynamic Bento GitHub Stats link."

# Create .github/workflows directory and GitHub Actions workflow file
mkdir -p .github/workflows
touch .github/workflows/update_bento_readme.yml

# Generate content for GitHub Actions workflow
cat <<EOF > .github/workflows/update_bento_readme.yml

name: Update README with Bento Stats

on:
  schedule:
    - cron: "*/10 * * * *" # Runs every 5 minutes
  workflow_dispatch: # Allows manual triggering of the workflow

jobs:
  update-readme:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Fetch Latest Bento Image URL
        id: fetch_bento_url
        run: |
          API_URL=""
          RESPONSE=$(curl -s "$API_URL")
          echo "API Response: $RESPONSE"  # Log the entire response
          IMAGE_URL=$(echo $RESPONSE | jq -r '.url')
          echo "Fetched Image URL: $IMAGE_URL"
          echo "::set-output name=image_url::$IMAGE_URL"

      - name: Delete current README.md
        if: env.skip != 'true'
        run: |
          if [ -f README.md ]; then
            rm README.md
            echo "Deleted old README.md"
          fi

      - name: Create new README.md
        if: env.skip != 'true'
        run: |
          IMAGE_URL=$(cat last_image_url.txt)  # Read the URL from last_image_url.txt
          echo "# Bento GitHub Stats" > README.md
          echo "![Bento GitHub Stats]($IMAGE_URL)" >> README.md
          echo "Created new README.md with the latest image URL."

      - name: Commit and Push Changes
        if: env.skip != 'true'
        run: |
          git config --global user.email "$EMAIL"
          git config --global user.name "$USERNAME"
          git add .
          git commit -m "Update README with latest Bento stats image"
          git push

EOF

git config --global user.email "$EMAIL"
git config --global user.name "$USERNAME"
git add .
git commit -m "Setup OpBento GitHub Action"
git push

echo "Setup complete! Your GitHub Actions workflow will run every 5 minutes and update the README with the latest Bento stats link."
