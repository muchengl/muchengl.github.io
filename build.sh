#!/bin/bash

# Generate the static files with Hexo
echo "Generating static files with Hexo..."
hexo g

# Deploy the generated files with Hexo
echo "Deploying the site with Hexo..."
hexo d

# Commit and push the current Hexo project to a branch in your GitHub repository
echo "Committing and pushing the current Hexo project to GitHub..."

# Define your branch name
BRANCH_NAME="project"

# Add all changes
git add .

# Commit changes with a message
git commit -m "Update Hexo site"

# Push changes to the specified branch
git push https://github.com/muchengl/muchengl.github.io $BRANCH_NAME

echo "Done!"

