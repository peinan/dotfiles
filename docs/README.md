# Dotfiles Documentation

This directory contains the documentation site (Astro) for the dotfiles repository.

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
# Build (outputs to docs/dist/)
npm run build

# Preview the build locally
npm run preview
```

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
├── src/
│   ├── components/     # Reusable components
│   ├── layouts/        # Layout components
│   ├── pages/          # Page files
│   └── styles/         # Global styles
├── public/             # Static assets
├── astro.config.mjs    # Astro configuration
├── package.json        # Dependencies
└── tailwind.config.mjs # Tailwind configuration
```

