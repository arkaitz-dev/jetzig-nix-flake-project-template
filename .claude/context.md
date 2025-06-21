# Jetzig Nix Flake Project Context

This is a web project created with Jetzig (master version), using Zig (master) and providing ZLS (also master) for LSP.

## Project Overview

**Framework**: Jetzig (Zig web framework)
**Build System**: Nix Flakes
**Language**: Zig
**Purpose**: Modern web application with reproducible development environment

## Key Components

### System Data File (.claude/system-data.yaml)
Claude Code must always check and maintain this file with current system information:
```yaml
LANG: en_US.UTF-8
WORKDIR: /path/to/project
ZIG_VERSION: 0.14.0-dev.123+abc123
JETZIG_VERSION: 0.1.0-dev
LAST_VERIFICATION_DATE: 2025-06-19
```
- **Location**: `.claude/system-data.yaml` (relative to project root)
- **Content**: System variables that may change between sessions
- **Verification**: Check daily - if LAST_VERIFICATION_DATE != today, refresh all data
- **Git exclusion**: Must be in .gitignore (system-specific, auto-generated)
- **Usage**: Always read this file to understand current environment before proceeding
- `flake.nix`: Minimal Nix flake providing only Zig (master), ZLS (master), and Jetzig (master)
- Development shell includes only essential tools for Jetzig development

### Development Workflow
- Always work within the Nix development environment (`nix develop`)
- `jetzig init` initializes a new Jetzig project structure
- `jetzig server` starts the development server with hot reload
- `zig fmt src/` formats Zig code following standard conventions
- Default server runs on localhost:8080
- Add additional tools to flake.nix as needed (databases, Node.js, etc.)

## Common Commands

### Development
```bash
# Enter development environment (REQUIRED)
nix develop

# Initialize new Jetzig project
jetzig init

# Add dependencies when needed
zig fetch --save https://github.com/example/package/archive/main.tar.gz

# Start Jetzig development server (with hot reload)
jetzig server

# Build project
jetzig build

# Run tests
zig build test

# Format Zig code
zig fmt src/

# Update to latest master branches
nix flake update
```

### Project Structure
- `flake.nix`: Nix configuration
- `.claude/context.md`: Documentation context for Claude Code
- All Jetzig project files created by `jetzig init` command

## Environment Variables
- `JETZIG_PORT`: Server port (default: 8080)
- `JETZIG_HOST`: Server host (default: localhost)
- `JETZIG_ENV`: Environment (development/production)
- `DATABASE_URL`: Database connection string

## Development Guidelines
- Always work within the Nix development shell (`nix develop`)
- **First step**: Ensure git repository is initialized (`git init` if .git directory doesn't exist)
- **Second step**: System data verification and management:
  - Run the system data script: `bash .claude/update-system-data.sh`
  - This script will automatically:
    - Create `.claude/` directory if it doesn't exist
    - Create or update `.claude/system-data.yaml` with current system information
    - Check if LAST_VERIFICATION_DATE is today, update if necessary
    - Display current system configuration
  - **Variables captured by the script**:
    - `LANG`: System language preference (`$LANG` environment variable)
    - `WORKDIR`: Project root directory (current working directory)
    - `ZIG_VERSION`: Current Zig version
    - `JETZIG_VERSION`: Current Jetzig version
    - `LAST_VERIFICATION_DATE`: Today's date
- **Always reference**: Read and understand `.claude/system-data.yaml` content at the start of any session
- Use `jetzig init` to create initial project structure
- Add dependencies with `zig fetch --save <url>` to update build.zig.zon
- Import dependencies in build.zig: `const dep = b.dependency("name", .{ .target = target, .optimize = optimize });`
- Add modules to executable: `exe.root_module.addImport("name", dep.module("name"));`
- Use Zig formatting conventions (`zig fmt`)
- Write tests for new functionality
- Follow Jetzig framework patterns for route handling
- Use Nix for all system dependencies
- Test APIs with curl and process JSON responses with jq for debugging and validation
- Commit changes regularly with meaningful commit messages

## Jetzig-Specific Best Practices
- **Project Structure**: Use `jetzig init` to create the standard project structure. Follow Jetzig conventions for directory layout
- **Code Generation**: Always use `jetzig generate` when possible for creating components. Use generators to ensure proper structure and avoid manual file creation

## JavaScript Best Practices
- **No inline JavaScript**: All JavaScript code must be in external files, never inline in HTML
- **File organization**: Structure JavaScript in src/assets/ and organize by functionality
- **Module system**: Use ES modules (import/export) for better organization
- **Event handling**: Move all event listeners to external JS files
- **Template integration**: Reference bundled JS files in Zmpl templates with proper SRI hashes
- **Theme switching**: If implementing theme toggles, create dedicated JS modules

## CSS Theme System
- **Three CSS files structure**: main.css imports common.css, light.css, and dark.css
- **common.css**: Contains all structural styles, layout, typography, and non-color CSS variables
  - Defines CSS custom properties structure: `--color-primary: var(--theme-primary)`
  - Contains all component styles using the defined color variables
  - No color definitions - only references to theme variables
- **light.css**: Light theme color definitions only
  - Defines `--theme-*` variables for light color scheme
  - Must contain exactly the same variable names as dark.css
  - Applied by default (no media query)
- **dark.css**: Dark theme color definitions only
  - Defines `--theme-*` variables for dark color scheme
  - Must contain exactly the same variable names as light.css
  - Applied via `@media (prefers-color-scheme: dark)` and `[data-theme="dark"]`
- **Theme switching**: Support both automatic (prefers-color-scheme) and manual (data-theme attribute)
- **Consistency rule**: light.css and dark.css must have identical structure - only color values differ
- **Color scope**: Only color-related properties should differ between themes (backgrounds, text, borders, etc.)

## Asset Building
- **Development**: Use `bash build-assets-dev.sh` for fast development builds
  - Creates source files if they don't exist (main.js, main.css)
  - Bundles with source maps for debugging
  - No minification for faster builds
  - Outputs to public/assets/ with readable names
- **Production**: Use `bash build-assets-prod.sh` for optimized production builds
  - Complete pipeline: bundle → minify → hash → compress → SRI
  - Generates .claude/asset-manifest.yaml with all asset information
  - Creates .br and .gz compressed versions
  - Includes SRI hashes for security
- **Asset Structure**: Place source files in src/assets/, outputs go to public/assets/
- **Templates**: Reference .claude/asset-manifest.yaml in Zmpl templates to load assets with proper integrity
- **Bundle & Minimize**: Use bundling systems for CSS and JavaScript minimization in production builds only
- **Development vs Production**: Skip minification during development for easier debugging and faster build times
- **Brotli Compression**: Compress production assets with Brotli for optimal file sizes:
  - `brotli --best bundle.css -o bundle.css.br`
  - `brotli --best bundle.js -o bundle.js.br`
  - Only compress final bundled/minified files in production
- **Gzip Compression**: Also provide Gzip compression for broader compatibility:
  - `gzip --best --keep bundle.css` (creates bundle.css.gz)
  - `gzip --best --keep bundle.js` (creates bundle.js.gz)
  - Serve both .br and .gz versions, with server preferring Brotli when supported
- **Self-Hosted Assets**: Serve all static assets from your own server rather than external CDNs when possible
- **Zmpl Templates**: Design layouts to differentiate between development and production environments:
  - Development: Serve multiple individual CSS/JS files for easier debugging
  - Production: Serve single bundled, minified, and compressed files (both .br and .gz versions)
- **Environment Detection**: Use Jetzig's environment variables to conditionally load different asset configurations in Zmpl templates
- **Asset Pipeline**: Implement build scripts that bundle, minify, and compress (Brotli + Gzip) only for production deployments
- **File Organization**: Keep source assets organized in development-friendly structure, generate production bundles as needed
- **Cache Strategies**: Use appropriate cache headers and file naming strategies for static assets in production
- **Compression Headers**: Configure server to serve compressed files with proper headers:
  - Brotli: `Content-Encoding: br` for .br files
  - Gzip: `Content-Encoding: gzip` for .gz files
  - Server should negotiate best compression based on client support

## HTML/Web Performance Best Practices
- **Lighthouse Auditing**: Use `lighthouse https://localhost:8080 --output json --chrome-flags="--headless"` to audit your web application
- **Performance Goal**: Aim for 100/100 scores in all Lighthouse categories (Performance, Accessibility, Best Practices, SEO)
- **Regular Testing**: Run Lighthouse audits regularly during development to catch performance regressions early
- **Semantic HTML**: Use proper HTML5 semantic elements for better accessibility and SEO
- **Optimize Assets**: Compress images, minify CSS/JS, and use appropriate formats (WebP for images, etc.)
- **Accessibility**: Ensure proper ARIA labels, keyboard navigation, and sufficient color contrast
- **Mobile-First**: Design and test for mobile devices first, then scale up to desktop

## Zig-Specific Best Practices
- **Memory Management**: Always use `defer` to free allocated memory. Match every `allocator.alloc()` with `defer allocator.free()`
- **Avoid Unnecessary Copies**: Pass pointers/slices instead of copying data structures when possible
- **Error Handling**: Use Zig's error system properly with `!` and `try`. Handle errors explicitly rather than ignoring them
- **Comptime Usage**: Leverage `comptime` for:
  - Creating generic types and functions
  - Building interfaces and type-safe abstractions
  - Avoiding code repetition through compile-time code generation
  - Type introspection and metaprogramming
- **Testing**: Write tests for every new function/feature using `test "description" { ... }`. After successful compilation, run tests if they are newly created
- **Compilation**: Ensure code compiles after each significant change with `zig build`, then run `zig build test`
- **Memory Safety**: Prefer stack allocation when size is known at compile time
- **Slices over Arrays**: Use slices (`[]T`) for function parameters instead of arrays when size is dynamic

## Troubleshooting
- Always work within the Nix development shell (`nix develop`)
- Run `jetzig init` first to create project structure
- Use `zig fetch --save <url>` for adding dependencies
- Run `zig build` after dependency changes
- Check environment variables in `.env` file
- Use `nix flake update` to update dependencies
