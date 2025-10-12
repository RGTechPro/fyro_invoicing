# GitHub Pages Deployment Guide

## Quick Setup Steps

### 1. Initialize Git Repository (If not already done)

```bash
git init
git add .
git commit -m "Initial commit: Biryani By Flame invoicing app"
```

### 2. Create GitHub Repository

1. Go to [GitHub.com](https://github.com) and log in
2. Click the "+" icon in the top right → "New repository"
3. Name your repository: `fyro_invoicing` (or any name you prefer)
4. **Do NOT** initialize with README, .gitignore, or license (we already have these)
5. Click "Create repository"

### 3. Connect Local Repo to GitHub

Replace `YOUR_USERNAME` with your GitHub username:

```bash
git remote add origin https://github.com/YOUR_USERNAME/fyro_invoicing.git
git branch -M main
git push -u origin main
```

### 4. Enable GitHub Pages

1. Go to your repository on GitHub
2. Click "Settings" tab
3. Click "Pages" in the left sidebar
4. Under "Build and deployment":
   - Source: Select "GitHub Actions"
5. The workflow will automatically run and deploy your site

### 5. Access Your Site

After deployment completes (2-3 minutes), your site will be available at:

```
https://YOUR_USERNAME.github.io/fyro_invoicing/
```

---

## Manual Build & Deploy (Alternative Method)

If you prefer to deploy manually without GitHub Actions:

### Step 1: Build the Web App

```bash
# Build with correct base-href
flutter build web --release --base-href "/fyro_invoicing/"
```

### Step 2: Deploy to gh-pages Branch

```bash
# Install gh-pages package (one-time)
npm install -g gh-pages

# Deploy build folder
gh-pages -d build/web
```

### Step 3: Configure GitHub Pages

1. Go to repository Settings → Pages
2. Source: Deploy from branch
3. Branch: Select `gh-pages` and `/ (root)`
4. Save

---

## Important Notes

### Base URL Configuration

The app is configured to work at: `https://YOUR_USERNAME.github.io/fyro_invoicing/`

If you want to use a custom domain or different repository name:

1. Update the `--base-href` in `.github/workflows/deploy.yml`
2. Rebuild: `flutter build web --release --base-href "/YOUR_REPO_NAME/"`

### Custom Domain (Optional)

To use a custom domain like `biryani.yourdomain.com`:

1. Update `.github/workflows/deploy.yml`:

   - Change `--base-href` to `"/"`
   - Set `cname: biryani.yourdomain.com`

2. Add DNS records in your domain provider:

   ```
   Type: CNAME
   Name: biryani
   Value: YOUR_USERNAME.github.io
   ```

3. In GitHub Settings → Pages:
   - Enter your custom domain
   - Enable "Enforce HTTPS"

### Troubleshooting

**Problem: Site shows 404**

- Check the base-href matches your repository name
- Ensure GitHub Pages is enabled in Settings
- Wait 2-3 minutes after first deployment

**Problem: Build fails**

- Check Flutter version in workflow matches your local version
- Verify all dependencies in `pubspec.yaml` are valid

**Problem: App doesn't work on GitHub Pages**

- Check browser console for errors
- Verify base-href is correct
- Test build locally first: `flutter run -d chrome --release`

---

## Automated Updates

Every time you push to the `main` branch:

1. GitHub Actions automatically builds the app
2. Deploys to GitHub Pages
3. Your site updates within 2-3 minutes

To push updates:

```bash
git add .
git commit -m "Description of changes"
git push
```

---

## Local Testing Before Deploy

Always test locally before deploying:

```bash
# Test in debug mode
flutter run -d chrome

# Test production build locally
flutter build web --release
cd build/web
python3 -m http.server 8000
# Visit http://localhost:8000
```

---

## Repository Settings Checklist

✅ Repository created on GitHub
✅ Code pushed to `main` branch
✅ GitHub Actions workflow file present (`.github/workflows/deploy.yml`)
✅ GitHub Pages enabled (Settings → Pages → Source: GitHub Actions)
✅ First deployment completed successfully
✅ Site accessible at GitHub Pages URL

---

## Next Steps After Deployment

1. **Test the deployed site thoroughly**

   - Test all features (menu, orders, printing)
   - Check on different devices/browsers
   - Verify printing functionality

2. **Share the URL**

   - Bookmark the site
   - Add to home screen on tablets
   - Share with team members

3. **Monitor and Update**
   - Push updates as needed
   - Check GitHub Actions for build status
   - Keep Flutter SDK updated

---

## Security Note

This is a client-side web app with local storage (Hive). Data is stored in the browser's IndexedDB. For production use with sensitive data, consider:

- Adding authentication
- Backend database
- Secure data transmission
- Regular backups

---

**Your site will be live at:** `https://YOUR_USERNAME.github.io/fyro_invoicing/`

Replace `YOUR_USERNAME` with your actual GitHub username!
