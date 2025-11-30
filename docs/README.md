# Dotfiles Documentation

This directory contains the documentation site (VitePress) for the dotfiles repository.

## Development

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build
npm run build

# Preview build
npm run preview
```

## Build and Deploy

This documentation is hosted on GitHub Pages and automatically deployed using GitHub Actions.

### Automatic Deployment

The site is automatically built and deployed when you push to the `main` branch. The GitHub Actions workflow (`.github/workflows/github-pages-deploy.yml`) handles the build and deployment process.

### Manual Build (for local testing)

```bash
# Build for GitHub Pages (outputs to docs/.vitepress/dist/)
# This uses absolute paths (/dotfiles/) and requires a web server
npm run build

# Build for local file access (outputs to docs/.vitepress/dist/)
# This uses relative paths (./) and can be opened directly in a browser
npm run build:local

# Preview the build locally (recommended)
# This starts a local server and works with both build types
npm run preview
```

**Note:**
- `npm run build` creates files with absolute paths (`/dotfiles/`) for GitHub Pages deployment
- `npm run build:local` creates files with relative paths (`./`) that can be opened directly in a browser
  - **Important**: When opening `index.html` directly with `file://` protocol, CSS will load correctly, but navigation between pages may show 404 errors due to browser security restrictions with SPA routing. Use `npm run preview` for full functionality.
- `npm run preview` is the **recommended** way to preview builds locally as it starts a local server and works correctly with all features

### Testing GitHub Actions Locally with act

You can test the GitHub Actions workflow locally using [act](https://github.com/nektos/act):

```bash
# Install act (if not already installed)
# macOS: brew install act
# Or see: https://github.com/nektos/act#installation

# Upgrade act if you encounter Docker API version errors
# brew upgrade act

# List available workflows
act -l

# Run the workflow (build job only, deploy job requires GitHub Pages environment)
act push

# Run a specific job
act -j build

# Run with verbose output
act -v push
```

**Note:**
- The `deploy` job requires GitHub Pages environment and won't work locally. Use `act -j build` to test only the build process.
- When testing with `act`, the artifact upload step will fail with "Unable to get the ACTIONS_RUNTIME_TOKEN env variable" error. This is expected in local testing - the build itself succeeds, and the actual GitHub Actions workflow will work correctly.

### GitHub Pages Configuration

1. Navigate to Settings > Pages in the repository
2. Set Source to "GitHub Actions"
3. The workflow will automatically deploy on push to `main` branch

## File Structure

```
docs/
├── .vitepress/
│   └── config.ts          # VitePress configuration
├── index.md               # Home page
├── install.md             # Installation guide
├── config.md              # Configuration files
├── submodules.md          # Submodules documentation
├── package.json           # Dependencies
└── README.md              # This file
```
