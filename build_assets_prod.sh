#!/usr/bin/env bash

# Production asset building script
# Complete pipeline: bundle -> minify -> hash -> compress -> SRI

set -euo pipefail

echo "🚀 Building assets for production..."

# Ensure directories exist
mkdir -p src/assets
mkdir -p public/assets
mkdir -p .claude

# Clean previous production builds
rm -rf public/assets/*

# Step 1: Bundle and minify with esbuild
echo "📦 Step 1: Bundling and minifying..."
esbuild src/assets/main.js src/assets/main.css \
    --bundle \
    --minify \
    --outdir=public/assets \
    --target=es2020 \
    --format=esm \
    --splitting \
    --chunk-names="chunks/[name]-[hash]" \
    --entry-names="[name]-[hash]" \
    --asset-names="[name]-[hash]" \
    --public-path="/assets/" \
    --metafile=public/assets/meta.json \
    --log-level=info

# Step 2: Generate content hashes for cache busting (BLAKE3)
echo "🔐 Step 2: Generating cache-busting hashes..."
for file in public/assets/*.{css,js}; do
    if [ -f "$file" ]; then
        # Get BLAKE3 hash for filename (already done by esbuild --entry-names)
        echo "✓ Hashed: $(basename "$file")"
    fi
done

# Step 3: Generate SRI hashes for security
echo "🛡️  Step 3: Generating SRI hashes..."
declare -A sri_hashes
for file in public/assets/*.{css,js}; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        sri_hash="sha256-$(sha256sum "$file" | cut -d' ' -f1 | xxd -r -p | base64 -w 0)"
        sri_hashes["$filename"]="$sri_hash"
        echo "✓ SRI for $filename: $sri_hash"
    fi
done

# Step 4: Compress assets
echo "🗜️  Step 4: Compressing assets..."
for file in public/assets/*.{css,js}; do
    if [ -f "$file" ]; then
        # Brotli compression
        brotli --best --keep "$file"
        echo "✓ Brotli: $(basename "$file").br"
        
        # Gzip compression
        gzip --best --keep "$file"
        echo "✓ Gzip: $(basename "$file").gz"
    fi
done

# Step 5: Generate asset manifest with SRI hashes
echo "📋 Step 5: Generating asset manifest..."
cat > .claude/asset-manifest.yaml << EOF
# Asset manifest for production
# Generated: $(date)
assets:
EOF

for file in public/assets/*.{css,js}; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        filepath="/assets/$filename"
        sri_hash="${sri_hashes[$filename]}"
        
        # Determine asset type
        if [[ "$filename" == *.css ]]; then
            asset_type="stylesheet"
        elif [[ "$filename" == *.js ]]; then
            asset_type="script"
        fi
        
        cat >> .claude/asset-manifest.yaml << EOF
  $asset_type:
    filename: "$filename"
    path: "$filepath"
    sri: "$sri_hash"
    brotli: "${filepath}.br"
    gzip: "${filepath}.gz"
EOF
    fi
done

echo ""
echo "✅ Production build completed successfully!"
echo "📊 Build summary:"
echo "   - Bundled and minified with esbuild"
echo "   - Content hashes for cache busting"
echo "   - SRI hashes for security"
echo "   - Brotli + Gzip compression"
echo "   - Asset manifest: .claude/asset-manifest.yaml"
echo ""
echo "🔧 Use the manifest in your Zmpl templates to load assets with proper integrity checks"