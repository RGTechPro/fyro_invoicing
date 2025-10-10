# 🚀 Quick Deployment Guide

## Option 1: Automated Deployment (Recommended)

### Step 1: Initialize Git and Create GitHub Repository

```bash
# Initialize git
git init
git add .
git commit -m "Initial commit: Biryani By Flame app"
```

### Step 2: Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `fyro_invoicing`
3. **Important**: Don't check any boxes (no README, no .gitignore)
4. Click "Create repository"

### Step 3: Connect and Push

Replace `YOUR_USERNAME` with your GitHub username:

```bash
git remote add origin https://github.com/YOUR_USERNAME/fyro_invoicing.git
git branch -M main
git push -u origin main
```

### Step 4: Enable GitHub Pages

1. Go to your repository on GitHub
2. Click **Settings** → **Pages**
3. Under "Build and deployment":
   - Source: **GitHub Actions** (select this)
4. Wait 2-3 minutes for the workflow to complete

### Step 5: Access Your Site

Your site will be live at:
```
https://YOUR_USERNAME.github.io/fyro_invoicing/
```

---

## Option 2: Use the Deploy Script

After creating your GitHub repository and connecting it:

```bash
# Run the automated deployment script
./deploy.sh
```

This script will:
- ✅ Build your Flutter web app
- ✅ Commit changes
- ✅ Push to GitHub
- ✅ Trigger automatic deployment

---

## Future Updates

To deploy updates, simply:

```bash
git add .
git commit -m "Your update description"
git push
```

GitHub Actions will automatically build and deploy! 🎉

---

## Troubleshooting

**Issue: "Permission denied" on deploy.sh**
```bash
chmod +x deploy.sh
./deploy.sh
```

**Issue: Site shows 404**
- Wait 2-3 minutes after first push
- Check Settings → Pages → Source is "GitHub Actions"
- Check Actions tab for build errors

**Issue: Build fails in GitHub Actions**
- Check the Actions tab for error details
- Ensure pubspec.yaml dependencies are correct
- Try building locally: `flutter build web --release`

---

## What's Been Set Up

✅ `.github/workflows/deploy.yml` - Automatic deployment workflow
✅ `deploy.sh` - Easy deployment script
✅ `DEPLOYMENT.md` - Detailed deployment guide
✅ `.gitignore` - Git ignore file (already exists)

---

## Your Site URL Format

```
https://YOUR_USERNAME.github.io/fyro_invoicing/
```

**Example**: If your GitHub username is `john_doe`:
```
https://john_doe.github.io/fyro_invoicing/
```

---

## Need Help?

Check `DEPLOYMENT.md` for detailed instructions and troubleshooting!
