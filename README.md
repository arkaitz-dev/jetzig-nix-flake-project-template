# Jetzig Smart Template

A complete, intelligent development template for [Jetzig](https://github.com/jetzig-framework/jetzig) web applications with automatic asset bundling, git-aware workflows, and zero-configuration development environment.

## ✨ Features

🧠 **Intelligent Build System** - Automatically detects git branch and executes appropriate workflows  
⚡ **Complete Auto-reload** - Live reload for Zig/Zmpl templates + JavaScript/CSS assets  
🎨 **Modern Asset Pipeline** - esbuild + CSS processing with compression (Brotli/Gzip)  
🎯 **Git-aware Workflows** - Different behaviors for development vs production branches  
🔧 **Zero Configuration** - Everything works out of the box  
📦 **Template System** - Complete project initialization with one command  
🎨 **CSS Theme System** - Modular themes (common/light/dark) with easy customization  
🚀 **Production Ready** - Optimized builds with SRI hashes and compression  

## 🚀 Quick Start

### Initialize New Project
```bash
nix flake init -t github:username/jetzig-template
cd your-project-name
```

### Development Workflow
```bash
# Enter development environment (automatically detects git branch)
nix develop

# For main/devel branches: Starts dev server with auto-reload
# For testing/prod branches: Provides production build environment
```

### Production Build
```bash
# Build optimized package (always uses production assets)
nix build

# Run the compiled application
./result/bin/your-app-name
```

## 🔧 Development Environment

### Git Branch Workflows

The template automatically adapts behavior based on your current git branch:

#### Development Branches (`main`, `devel`)
- **`nix develop`**: Launches `dev-server.sh` with complete auto-reload
- **Auto-reload features**:
  - ✅ Zig source code changes
  - ✅ Zmpl template changes  
  - ✅ JavaScript/CSS assets
  - ✅ Static files

#### Production Branches (`testing`, `prod`)
- **`nix develop`**: Provides build environment for production testing
- **`nix build`**: Creates optimized deployment package

### Manual Commands

If you prefer manual control:

```bash
# Development server (any branch)
bash .claude/dev-server.sh

# Production asset building
bash .claude/build-assets-prod.sh

# Development asset building (faster, uncompressed)
bash .claude/build-assets-dev.sh
```

## 📁 Project Structure

```
your-project/
├── flake.nix                    # Nix development environment + build logic
├── .gitignore                   # Optimized for Jetzig + generated assets
├── .claude/                     # Smart build system
│   ├── dev-server.sh           # Development server with auto-reload
│   ├── build-assets-dev.sh     # Fast development asset builds
│   ├── build-assets-prod.sh    # Optimized production asset builds
│   ├── asset-manifest.yaml     # Asset metadata with SRI hashes
│   └── context.md              # Complete documentation
├── src/                         # Zig source code
├── views/                       # Zmpl templates
└── public/                      # All static assets (source + generated)
    ├── css/
    │   ├── common.css          # Base styles (source)
    │   ├── theme-light.css     # Light theme (source)
    │   ├── theme-dark.css      # Dark theme (source)
    │   ├── bundle.css          # Generated bundled CSS
    │   ├── bundle.css.br       # Brotli compressed
    │   └── bundle.css.gz       # Gzip compressed
    └── js/
        ├── app.js              # Application JavaScript (source)
        ├── bundle.js           # Generated bundled JavaScript
        ├── bundle.js.br        # Brotli compressed
        └── bundle.js.gz        # Gzip compressed
```

## 🎨 CSS Theme System

The template includes a modular CSS architecture:

### Theme Files
- **`public/css/common.css`**: Base styles, layout, typography
- **`public/css/theme-light.css`**: Light theme colors and specific styles
- **`public/css/theme-dark.css`**: Dark theme colors and specific styles

### Usage in Templates
```html
<!-- In your Zmpl templates -->
<link rel="stylesheet" href="/css/bundle.css">
<script src="/js/bundle.js"></script>
```

### Adding New Themes
1. Create `public/css/theme-yourname.css`
2. Add to `build-assets-*.sh` bundling configuration
3. Assets automatically optimized and compressed

## ⚡ Asset Pipeline

### Development Mode
- **Fast bundling** with esbuild
- **No compression** for speed
- **Source maps** for debugging
- **Live reload** on file changes

### Production Mode
- **Minified and optimized** assets
- **Brotli + Gzip compression**
- **SRI integrity hashes**
- **Cache-friendly filenames**

### Asset Serving

The template automatically handles:
- ✅ **Content-Encoding**: Serves `.br` or `.gz` based on client support
- ✅ **SRI Hashes**: Subresource integrity for security
- ✅ **Cache Headers**: Optimal caching strategies
- ✅ **Fallbacks**: Graceful degradation for unsupported compression

## 🔧 Available Commands

### Development
```bash
nix develop                      # Enter dev environment (branch-aware)
bash .claude/dev-server.sh       # Manual dev server
```

### Building
```bash
nix build                        # Production package
bash .claude/build-assets-dev.sh # Fast asset development build
bash .claude/build-assets-prod.sh # Optimized asset production build
```

### Asset Management
```bash
# View asset manifest
cat .claude/asset-manifest.yaml

# Check compressed asset sizes
ls -la public/css/ public/js/
```

## 🧠 Intelligent Features

### Automatic Branch Detection
The flake automatically detects your current git branch and:
- Chooses appropriate asset building strategy
- Configures development vs production workflows
- Optimizes build times for your current context

### Smart Caching
- Development builds prioritize speed
- Production builds prioritize optimization
- Asset changes trigger appropriate rebuilds

### Zero Configuration
- Works immediately after `nix flake init`
- No additional setup or configuration required
- Intelligent defaults for all workflows

## 📚 Documentation

Complete documentation available in `.claude/context.md` including:
- Detailed workflow explanations
- Asset pipeline internals
- Customization guides
- Troubleshooting tips

## 🤝 Contributing

This template is designed to be:
- **Extensible**: Easy to add new asset types or build steps
- **Maintainable**: Clear separation of concerns
- **Flexible**: Adaptable to different project needs

## 📄 License

MIT License - feel free to use this template for any project!

---

**Ready to build something amazing with Jetzig?** 🚀

```bash
nix flake init -t github:username/jetzig-template
nix develop
# Start coding! 
```