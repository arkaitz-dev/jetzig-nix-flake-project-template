#!/usr/bin/env bash

# Development asset building script
# Fast bundling with esbuild for development environment

set -euo pipefail

echo "🔧 Building assets for development..."

# Create assets directories if they don't exist
mkdir -p src/assets
mkdir -p public/assets

# Create default source files if they don't exist
if [ ! -f "src/assets/main.js" ]; then
    cat > src/assets/main.js << 'EOF'
// Main JavaScript entry point
// Import all JavaScript modules here

// Example: Theme switching functionality
import './modules/theme-switcher.js';

// Example: App initialization
import './modules/app.js';

console.log('Jetzig app loaded');
EOF
    echo "Created src/assets/main.js"
fi

# Create JavaScript modules directory and example files
mkdir -p src/assets/modules

if [ ! -f "src/assets/modules/app.js" ]; then
    cat > src/assets/modules/app.js << 'EOF'
// Main application logic
export class App {
    constructor() {
        this.init();
    }

    init() {
        console.log('App initialized');
        this.setupEventListeners();
    }

    setupEventListeners() {
        // Add your event listeners here
        // NO inline JavaScript in HTML - all events handled here
        document.addEventListener('DOMContentLoaded', () => {
            console.log('DOM fully loaded');
        });
    }
}

// Initialize app
new App();
EOF
    echo "Created src/assets/modules/app.js"
fi

if [ ! -f "src/assets/modules/theme-switcher.js" ]; then
    cat > src/assets/modules/theme-switcher.js << 'EOF'
// Theme switching functionality
export class ThemeSwitcher {
    constructor() {
        this.currentTheme = this.getStoredTheme() || this.getPreferredTheme();
        this.init();
    }

    init() {
        this.applyTheme(this.currentTheme);
        this.setupThemeToggle();
    }

    getStoredTheme() {
        return localStorage.getItem('theme');
    }

    getPreferredTheme() {
        return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    }

    applyTheme(theme) {
        document.documentElement.setAttribute('data-theme', theme);
        localStorage.setItem('theme', theme);
        this.currentTheme = theme;
    }

    toggleTheme() {
        const newTheme = this.currentTheme === 'light' ? 'dark' : 'light';
        this.applyTheme(newTheme);
    }

    setupThemeToggle() {
        // Find theme toggle button and add event listener
        const themeToggle = document.querySelector('[data-theme-toggle]');
        if (themeToggle) {
            themeToggle.addEventListener('click', () => this.toggleTheme());
        }
    }
}

// Initialize theme switcher
new ThemeSwitcher();
EOF
    echo "Created src/assets/modules/theme-switcher.js"
fi

if [ ! -f "src/assets/main.css" ]; then
    cat > src/assets/main.css << 'EOF'
/* Main CSS entry point - imports all CSS files */
@import './common.css';
@import './light.css';
@import './dark.css';
EOF
    echo "Created src/assets/main.css"
fi

# Create CSS theme files if they don't exist
if [ ! -f "src/assets/common.css" ]; then
    cat > src/assets/common.css << 'EOF'
/* Common styles and CSS variables structure */
* {
    box-sizing: border-box;
}

:root {
    /* Common non-color variables */
    --font-family-base: system-ui, -apple-system, sans-serif;
    --font-size-base: 16px;
    --line-height-base: 1.6;
    --border-radius: 4px;
    --spacing-xs: 0.25rem;
    --spacing-sm: 0.5rem;
    --spacing-md: 1rem;
    --spacing-lg: 1.5rem;
    --spacing-xl: 2rem;
    
    /* Color variables (defined in theme files) */
    --color-primary: var(--theme-primary);
    --color-secondary: var(--theme-secondary);
    --color-background: var(--theme-background);
    --color-surface: var(--theme-surface);
    --color-text: var(--theme-text);
    --color-text-secondary: var(--theme-text-secondary);
    --color-border: var(--theme-border);
}

body {
    font-family: var(--font-family-base);
    font-size: var(--font-size-base);
    line-height: var(--line-height-base);
    margin: 0;
    padding: 0;
    background-color: var(--color-background);
    color: var(--color-text);
    transition: background-color 0.2s ease, color 0.2s ease;
}

/* Add common component styles here */
EOF
    echo "Created src/assets/common.css"
fi

if [ ! -f "src/assets/light.css" ]; then
    cat > src/assets/light.css << 'EOF'
/* Light theme color definitions */
:root {
    --theme-primary: #3b82f6;
    --theme-secondary: #6b7280;
    --theme-background: #ffffff;
    --theme-surface: #f9fafb;
    --theme-text: #111827;
    --theme-text-secondary: #6b7280;
    --theme-border: #e5e7eb;
}

/* Light theme is default - no media query needed */
EOF
    echo "Created src/assets/light.css"
fi

if [ ! -f "src/assets/dark.css" ]; then
    cat > src/assets/dark.css << 'EOF'
/* Dark theme color definitions */
@media (prefers-color-scheme: dark) {
    :root {
        --theme-primary: #60a5fa;
        --theme-secondary: #9ca3af;
        --theme-background: #111827;
        --theme-surface: #1f2937;
        --theme-text: #f9fafb;
        --theme-text-secondary: #d1d5db;
        --theme-border: #374151;
    }
}

/* Manual dark theme activation */
[data-theme="dark"] {
    --theme-primary: #60a5fa;
    --theme-secondary: #9ca3af;
    --theme-background: #111827;
    --theme-surface: #1f2937;
    --theme-text: #f9fafb;
    --theme-text-secondary: #d1d5db;
    --theme-border: #374151;
}
EOF
    echo "Created src/assets/dark.css"
fi

# Build with esbuild for development
echo "Building with esbuild..."

# Check if watch mode is requested
if [ "$1" = "--watch" ]; then
    echo "🔥 Starting asset watch mode (Ctrl+C to stop)..."
    esbuild src/assets/main.js src/assets/main.css \
        --bundle \
        --outdir=public/assets \
        --sourcemap \
        --target=es2020 \
        --format=esm \
        --splitting \
        --chunk-names="chunks/[name]-[hash]" \
        --asset-names="[name]" \
        --public-path="/assets/" \
        --watch \
        --log-level=info
else
    # One-time build
    esbuild src/assets/main.js src/assets/main.css \
        --bundle \
        --outdir=public/assets \
        --sourcemap \
        --target=es2020 \
        --format=esm \
        --splitting \
        --chunk-names="chunks/[name]-[hash]" \
        --asset-names="[name]" \
        --public-path="/assets/" \
        --log-level=info

    echo "✅ Development assets built successfully!"
    echo "📁 Output: public/assets/"
    echo "🔧 Ready for development with source maps"
    echo ""
    echo "💡 For automatic rebuilding on file changes:"
    echo "   bash .claude/build-assets-dev.sh --watch"
fi