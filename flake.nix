            # Optional: Add additional tools as needed
            # nodejs_20  # For frontend assets
            # nodePackages.npm
            # sqlite     # Database
            # postgresql_15
            # curl       # HTTP client
            # jq         # JSON processor

{
  description = "Jetzig web framework project template with Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig.url = "github:mitchellh/zig-overlay";
    zls.url = "github:zigtools/zls";

    # Jetzig source for building CLI
    jetzig = {
      url = "github:jetzig-framework/jetzig";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, zig, zls, jetzig }:
    let
      # Plantilla flake para nix flake init
      templateSrc = self;
    in
    {
      templates.default = {
        path = ./.;
        description = "Jetzig web framework project template with Nix flake";
      };
    } //
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        zigPkg = zig.packages.${system}.master;
        zlsPkg = zls.packages.${system}.default.overrideAttrs (oldAttrs: {
          doCheck = false;
        });

        # Build Jetzig CLI from source
        jetzigCli = pkgs.stdenv.mkDerivation {
          pname = "jetzig-cli";
          version = "unstable";

          src = jetzig;

          nativeBuildInputs = [ zigPkg pkgs.git ];

          buildPhase = ''
            export HOME=$TMPDIR
            cd cli
            zig build -Doptimize=ReleaseSafe
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp zig-out/bin/jetzig $out/bin/
          '';

          meta = {
            description = "CLI tool for the Jetzig web framework";
            homepage = "https://www.jetzig.dev";
            mainProgram = "jetzig";
          };
        };
      in
      {
        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = [
            zigPkg     # Zig compiler (master)
            zlsPkg     # Zig Language Server (master)
            jetzigCli  # Jetzig CLI (master)

            # Web development tools
            pkgs.nodePackages.lighthouse  # Google Lighthouse (web auditing)
            pkgs.brotli                    # Brotli compression for production assets
            pkgs.gzip                      # Gzip compression for compatibility
            pkgs.b3sum                     # BLAKE3 hashing for cache busting
            pkgs.coreutils                 # sha256sum for SRI hashes
            pkgs.curl                      # HTTP client for API testing
            pkgs.jq                        # JSON processor for API responses
            pkgs.git                       # Version control system
            pkgs.coreutils                 # date, mkdir, and other core utilities
            pkgs.esbuild                   # Fast JavaScript/CSS bundler
          ];

          buildPhase = ''
            echo "🔧 Jetzig Build Phase"

            # Detect current git branch
            if [ -d ".git" ]; then
              CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
              echo "📍 Current branch: $CURRENT_BRANCH"
            else
              CURRENT_BRANCH="unknown"
              echo "⚠️  No git repository detected"
            fi

            # Execute appropriate asset building based on branch
            case "$CURRENT_BRANCH" in
              "main"|"devel"|"unknown")
                echo "🔥 Starting development environment with auto-reload..."
                if [ -f "dev-server.sh" ]; then
                  bash dev-server.sh
                else
                  echo "⚠️  Development server script not found, falling back to basic server"
                  jetzig server
                fi
                ;;
              "testing"|"prod")
                echo "🚀 Building production assets..."
                if [ -f "build-assets-prod.sh" ]; then
                  bash build-assets-prod.sh
                else
                  echo "⚠️  Production asset script not found"
                fi
                echo "🏗️  Building Jetzig application for production..."
                zig build
                ;;
              *)
                echo "🔧 Unknown branch, using development environment..."
                if [ -f "dev-server.sh" ]; then
                  bash dev-server.sh
                else
                  echo "⚠️  Development server script not found"
                  jetzig server
                fi
                ;;
            esac
          '';

          shellHook = ''
            echo "🚀 Jetzig development environment loaded!"
            echo ""
            echo "Available tools:"
            echo "  zig $(zig version)"
            echo "  jetzig $(jetzig --version 2>/dev/null || echo 'CLI ready')"
            echo "  zls (language server)"
            echo "  lighthouse $(lighthouse --version 2>/dev/null || echo 'ready')"
            echo "  brotli $(brotli --version 2>/dev/null || echo 'ready')"
            echo "  gzip $(gzip --version 2>/dev/null | head -1 || echo 'ready')"
            echo "  b3sum $(b3sum --version 2>/dev/null || echo 'ready')"
            echo "  sha256sum $(sha256sum --version 2>/dev/null | head -1 || echo 'ready')"
            echo "  curl $(curl --version 2>/dev/null | head -1 || echo 'ready')"
            echo "  jq $(jq --version 2>/dev/null || echo 'ready')"
            echo "  git $(git --version 2>/dev/null || echo 'ready')"
            echo "  esbuild $(esbuild --version 2>/dev/null || echo 'ready')"
            echo ""
            echo "Get started:"
            echo "  jetzig init   - Initialize new project"
            echo "  jetzig server - Start development server"
            echo "  jetzig build  - Build the project"
            echo "  zig fmt src/  - Format code"
            echo ""
            echo "Happy coding! 🎯"
          '';

          # Environment variables
          NIX_SHELL_PRESERVE_PROMPT = 1;
        };

        # Build the project
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "jetzig-app";
          version = "0.1.0";

          src = ./.;

          nativeBuildInputs = [ zigPkg jetzigCli ];

          buildPhase = ''
            export HOME=$TMPDIR
            echo "🔧 Jetzig Package Build"

            # Detect current git branch
            if [ -d ".git" ]; then
              CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
              echo "📍 Current branch: $CURRENT_BRANCH"
            else
              CURRENT_BRANCH="unknown"
              echo "⚠️  No git repository detected, assuming production build"
            fi

            # Execute appropriate asset building based on branch
            case "$CURRENT_BRANCH" in
              "main"|"devel")
                echo "🔧 Development branch - building with production assets for package"
                if [ -f ".claude/build-assets-prod.sh" ]; then
                  bash .claude/build-assets-prod.sh
                fi
                ;;
              "testing"|"prod"|"unknown")
                echo "🚀 Building production assets..."
                if [ -f ".claude/build-assets-prod.sh" ]; then
                  bash .claude/build-assets-prod.sh
                fi
                ;;
            esac

            jetzig build
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp zig-out/bin/* $out/bin/
          '';
        };

        # Export the Jetzig CLI as a package
        packages.jetzig-cli = jetzigCli;
      });
}
