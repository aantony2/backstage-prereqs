#!/usr/bin/env bash
#
# create-node-env.sh
#
# Quickly bootstrap an isolated Node.js project directory
# with its own Node version (via nvm) and fresh npm/yarn/pnpm
# workspace.  Works on macOS, Linux, and WSL.
#
# Usage:
#   ./create-node-env.sh <project-name> [node-version]
#
# Examples:
#   ./create-node-env.sh my‑api            # uses current LTS
#   ./create-node-env.sh ui-playground 20  # installs/uses Node 20.x
#
# Prerequisites:
#   • nvm (https://github.com/nvm-sh/nvm) already installed in your shell
#   • Internet connection (first‑time Node download)
#

set -euo pipefail

#######################################
# Helper functions
#######################################
die() { echo "❌  $*" >&2; exit 1; }
info(){ echo -e "🟢  $*"; }

#######################################
# Basic argument parsing
#######################################
PROJECT_NAME=${1:-}
NODE_VERSION=${2:-"lts/*"}   # “lts/*” picks the latest active LTS

[[ -z "$PROJECT_NAME" ]] && die "Project name required.\n\nUsage:\n  $0 <project-name> [node-version]"

#######################################
# Ensure nvm is available
#######################################
if ! command -v nvm >/dev/null 2>&1; then
  # nvm lives in a shell function, not a binary
  if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    # shellcheck source=/dev/null
    . "$HOME/.nvm/nvm.sh"
  fi
fi
command -v nvm >/dev/null 2>&1 || die "nvm not found. Install it first: https://github.com/nvm-sh/nvm"

#######################################
# Create & enter project directory
#######################################
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

#######################################
# Install & pin desired Node version
#######################################
info "Installing / using Node.js \"$NODE_VERSION\" via nvm…"
nvm install "$NODE_VERSION"       # downloads if not present
nvm use "$NODE_VERSION"

# Record version in .nvmrc so others/open shells auto‑select it
node -v | cut -c2- > .nvmrc
info "Pinned Node $(cat .nvmrc) in .nvmrc"

#######################################
# Initialise package management
#######################################
info "Initialising npm workspace…"
npm init -y >/dev/null

# Optional: enable Corepack so yarn & pnpm are available out‑of‑box
info "Enabling Corepack (yarn & pnpm shims)…"
corepack enable >/dev/null

#######################################
# House‑keeping conveniences
#######################################
cat <<'EOF' > .gitignore
# Node artefacts
node_modules/
.env
dist/
coverage/
EOF

#######################################
# Success message
#######################################
cat <<EOF

🎉  Project “$PROJECT_NAME” is ready!

Next steps:
  cd $PROJECT_NAME          # already here
  nvm use                   # auto‑selects Node via .nvmrc in new shells
  npm install <pkg>         # add dependencies
  npm run <script>          # or yarn / pnpm after “corepack prepare”

Happy hacking! 🚀
EOF