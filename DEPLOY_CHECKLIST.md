# 📋 GitHub Pages Deployment Checklist

## Pre-Deployment Setup

### 1. Initialize Git Repository

```bash
git init
git add .
git commit -m "Initial commit: Biryani By Flame app"
```

- [ ] Git initialized
- [ ] All files committed

### 2. Create GitHub Repository

Go to: https://github.com/new

Settings:

- Repository name: `fyro_invoicing` (or your choice)
- Visibility: Public (required for free GitHub Pages)
- **DO NOT** check:
  - [ ] ❌ Add a README file
  - [ ] ❌ Add .gitignore
  - [ ] ❌ Choose a license

Click "Create repository"

- [ ] GitHub repository created

### 3. Connect Local to GitHub

```bash
git remote add origin https://github.com/YOUR_USERNAME/fyro_invoicing.git
git branch -M main
git push -u origin main
```

Replace `YOUR_USERNAME` with your actual GitHub username.

- [ ] Remote origin added
- [ ] Code pushed to GitHub

---

## Deployment Configuration

### 4. Enable GitHub Pages

1. Go to your repository on GitHub
2. Click **Settings** tab (top right)
3. Click **Pages** in left sidebar
4. Under "Build and deployment":
   - Source: Select **"GitHub Actions"**
   - (Don't select "Deploy from a branch")
5. Save (if button appears)

- [ ] GitHub Pages source set to "GitHub Actions"

### 5. Wait for First Deployment

1. Go to **Actions** tab in your repository
2. You should see a workflow running: "Deploy to GitHub Pages"
3. Wait for it to complete (green checkmark, ~2-3 minutes)
4. If it fails (red X), click on it to see error details

- [ ] First deployment workflow completed successfully

---

## Verify Deployment

### 6. Access Your Site

Your site URL will be:

```
https://YOUR_USERNAME.github.io/fyro_invoicing/
```

Test the following:

- [ ] Site loads without errors
- [ ] Home screen appears correctly
- [ ] Can navigate to Menu screen
- [ ] Can create a new order
- [ ] Can add items to order
- [ ] Can complete and print order (preview works)
- [ ] Can view order history
- [ ] Statistics show correctly
- [ ] App theme (black/gold/red) displays properly

---

## Post-Deployment

### 7. Bookmark and Share

- [ ] Bookmark the URL
- [ ] Add to home screen on tablet/device
- [ ] Share with team members
- [ ] Test on different browsers (Chrome, Safari, Firefox)
- [ ] Test on different devices (desktop, tablet, mobile)

### 8. Document Your URL

Write down your site URL:

```
https://_________________________.github.io/fyro_invoicing/
```

---

## Future Updates

### Deploying Updates

Whenever you make changes:

```bash
git add .
git commit -m "Description of your changes"
git push
```

GitHub Actions will automatically:

1. Build the updated app
2. Deploy to GitHub Pages
3. Update your live site (2-3 minutes)

- [ ] Understand update process

---

## Optional: Custom Domain

If you have a custom domain (e.g., `orders.biryanibyflame.com`):

### 1. Update Workflow File

Edit `.github/workflows/deploy.yml`:

- Change `--base-href "/fyro_invoicing/"` to `--base-href "/"`
- Change `cname: false` to `cname: orders.biryanibyflame.com`

### 2. Configure DNS

In your domain provider's DNS settings:

```
Type: CNAME
Name: orders (or subdomain you want)
Value: YOUR_USERNAME.github.io
TTL: 3600
```

### 3. Enable in GitHub

Settings → Pages → Custom domain:

- Enter: `orders.biryanibyflame.com`
- Check "Enforce HTTPS"
- Wait for DNS check (can take up to 24 hours)

- [ ] Custom domain configured (if applicable)

---

## Troubleshooting

### Common Issues

**❌ Site shows 404 error**

- Solution: Wait 2-3 minutes after first deployment
- Check: Settings → Pages → Source is "GitHub Actions"
- Check: Repository is Public

**❌ Workflow fails in Actions tab**

- Click on the failed workflow to see logs
- Common fixes:
  - Update Flutter version in workflow file
  - Check pubspec.yaml for errors
  - Try: `flutter build web --release` locally first

**❌ Site loads but app doesn't work**

- Check browser console (F12) for errors
- Verify base-href in workflow matches repository name
- Clear browser cache and hard refresh (Ctrl+Shift+R)

**❌ Printing doesn't work**

- Printing requires browser print dialog support
- Test preview mode first
- Some features may need HTTPS (GitHub Pages provides this)

---

## Quick Reference Commands

```bash
# Check git status
git status

# View commit history
git log --oneline -5

# View remote URL
git remote -v

# Test build locally
flutter build web --release

# Run deployment script
./deploy.sh

# Force push (use with caution!)
git push -f origin main
```

---

## Support Files Created

- ✅ `.github/workflows/deploy.yml` - GitHub Actions workflow
- ✅ `deploy.sh` - Automated deployment script
- ✅ `DEPLOYMENT.md` - Detailed deployment guide
- ✅ `QUICK_DEPLOY.md` - Quick start guide
- ✅ `DEPLOY_CHECKLIST.md` - This checklist

---

## Final Checklist Summary

- [ ] Git repository initialized
- [ ] GitHub repository created (public)
- [ ] Code pushed to GitHub
- [ ] GitHub Pages enabled (Source: GitHub Actions)
- [ ] First deployment successful
- [ ] Site accessible and working
- [ ] URL bookmarked and shared
- [ ] Team knows how to access the site

---

**🎉 Once all items are checked, your deployment is complete!**

Your live site: `https://YOUR_USERNAME.github.io/fyro_invoicing/`
