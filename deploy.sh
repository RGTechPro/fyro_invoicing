#!/bin/bash

# Biryani By Flame - Deployment Script
# This script helps you deploy your Flutter web app to GitHub Pages

set -e  # Exit on error

echo "🔥 Biryani By Flame - GitHub Pages Deployment 🔥"
echo "=================================================="
echo ""

# Check if git is initialized
if [ ! -d .git ]; then
    echo "📦 Initializing Git repository..."
    git init
    git add .
    git commit -m "Initial commit: Biryani By Flame invoicing app"
    echo "✅ Git repository initialized"
    echo ""
fi

# Check if remote is set
if ! git remote | grep -q origin; then
    echo "❌ GitHub remote not configured!"
    echo ""
    echo "Please follow these steps:"
    echo "1. Create a new repository on GitHub (https://github.com/new)"
    echo "2. Name it 'fyro_invoicing' (or your preferred name)"
    echo "3. Don't initialize with README"
    echo "4. Run this command with your GitHub username:"
    echo ""
    echo "   git remote add origin https://github.com/YOUR_USERNAME/fyro_invoicing.git"
    echo ""
    exit 1
fi

# Get the repository name from git remote
REPO_URL=$(git remote get-url origin)
REPO_NAME=$(basename "$REPO_URL" .git)

echo "📋 Repository: $REPO_NAME"
echo ""

# Build the Flutter web app
echo "🏗️  Building Flutter web app..."
flutter build web --release --base-href "/$REPO_NAME/"

if [ $? -ne 0 ]; then
    echo "❌ Build failed! Please fix errors and try again."
    exit 1
fi

echo "✅ Build completed successfully"
echo ""

# Commit any changes
if [[ -n $(git status -s) ]]; then
    echo "💾 Committing changes..."
    git add .
    read -p "Enter commit message (or press Enter for default): " COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Update app - $(date '+%Y-%m-%d %H:%M:%S')"
    fi
    git commit -m "$COMMIT_MSG"
    echo "✅ Changes committed"
    echo ""
fi

# Push to main branch
echo "🚀 Pushing to GitHub..."
git push origin main

if [ $? -ne 0 ]; then
    echo "⚠️  Push failed. If this is your first push, try:"
    echo "   git push -u origin main"
    exit 1
fi

echo "✅ Code pushed to GitHub"
echo ""

echo "=================================================="
echo "✅ Deployment initiated!"
echo ""
echo "📝 Next steps:"
echo "1. Go to your GitHub repository"
echo "2. Click on 'Actions' tab to see deployment progress"
echo "3. Once complete, your site will be live at:"
echo ""
echo "   https://YOUR_USERNAME.github.io/$REPO_NAME/"
echo ""
echo "4. If this is your first deployment:"
echo "   - Go to Settings → Pages"
echo "   - Ensure Source is set to 'GitHub Actions'"
echo ""
echo "⏱️  Deployment usually takes 2-3 minutes"
echo "=================================================="
