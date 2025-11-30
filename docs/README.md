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

The site is automatically built and deployed when you push to the `main` branch. The GitHub Actions workflow (`.github/workflows/deploy.yml`) handles the build and deployment process.

### Manual Build (for local testing)

```bash
# Build (outputs to docs/dist/)
npm run build

# Preview the build locally
npm run preview
```

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

