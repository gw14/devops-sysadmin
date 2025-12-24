#!/bin/bash

# ==============================================================================
# SCRIPT: setup_nvim.sh
# VERSION: 2.9.1
# DESCRIPTION: Nightly v0.11+ IDE Installer with Full Revert & Health Fixes
# ==============================================================================

LOG_FILE="nvim_setup.log"
CONFIG_DIR="$HOME/.config/nvim"

# Module Toggles
INSTALL_DAP=false
INSTALL_BASH=false
INSTALL_GIT=false
PERFORM_CLEANUP=false
DEBUG_MODE=false

log() {
    local mode=$1
    local msg=$2
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$mode] $msg" | tee -a "$LOG_FILE"
}

# --- Function: Full Uninstall & Path Reversion ---
cleanup_env() {
    log "INFO" "UNINSTALLING: Removing binaries and reverting symbolic links..."
    
    # Revert symlink and remove bin
    [ -L /usr/local/bin/nvim ] && rm /usr/local/bin/nvim
    rm -rf /opt/nvim-linux-x86_64
    
    # Purge config and data
    log "INFO" "CLEANUP: Purging data, config, and global npm modules..."
    rm -rf "$CONFIG_DIR" "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"
    
    # Clean up global npm tool installed by this script
    npm uninstall -g tree-sitter-cli > /dev/null 2>&1
    
    log "SUCCESS" "System reverted to original state."
    echo "------------------------------------------"
    echo -e "\033[0;31m\u2705 Uninstall complete. Link /usr/local/bin/nvim removed.\033[0m"
    echo "------------------------------------------"
    exit 0
}

# --- Argument Parsing ---
for arg in "$@"; do
    case $arg in
        --cleanup)   PERFORM_CLEANUP=true ;;
        --debug)     DEBUG_MODE=true ;;
        --with-dap)  INSTALL_DAP=true ;;
        --with-bash) INSTALL_BASH=true ;;
        --with-git)  INSTALL_GIT=true ;;
        -h|--help)
            echo "Usage: ./setup_nvim.sh [OPTIONS]"
            echo "Options: --cleanup (Full Uninstall), --debug, --with-dap, --with-bash, --with-git"
            exit 0
            ;;
    esac
done

[[ "$PERFORM_CLEANUP" == true ]] && cleanup_env

# --- 1. System Dependency Installation ---
log "INFO" "Installing Dependencies (including LuaRocks and Build Tools)..."
DEPS=("git" "curl" "unzip" "ripgrep" "python3" "python3-pip" "python3-venv" "nodejs" "npm" "xclip" "luarocks" "build-essential")
[[ "$INSTALL_BASH" == true ]] && DEPS+=("shellcheck" "shfmt")

REDIRECT="/dev/null"
[[ "$DEBUG_MODE" == true ]] && REDIRECT="/dev/stdout"

apt-get update -y > $REDIRECT
apt-get install -y "${DEPS[@]}" > $REDIRECT

# Fix for Missing Tree-sitter-cli
log "INFO" "Installing tree-sitter-cli via npm..."
npm install -g tree-sitter-cli > $REDIRECT 2>&1

# --- 2. Neovim Nightly Installation ---
log "INFO" "Downloading Neovim Nightly (v0.11+)..."
rm -rf /opt/nvim-linux-x86_64
curl -Lf https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.tar.gz -o /tmp/nvim.tar.gz
tar -C /opt -xzf /tmp/nvim.tar.gz
ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

# --- 3. Native v0.11 Config Generation ---
log "INFO" "Generating init.lua..."
mkdir -p "$CONFIG_DIR"
cat <<EOF > "$CONFIG_DIR/init.lua"
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.opt.number, vim.opt.relativenumber = true, true
vim.opt.termguicolors = true

require("lazy").setup({
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "neovim/nvim-lspconfig", dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" } },
  { "hrsh7th/nvim-cmp", dependencies = { "hrsh7th/cmp-nvim-lsp", "L3MON4D3/LuaSnip" } },
  $([[ "$INSTALL_GIT" == true ]] && echo '{ "lewis6991/gitsigns.nvim", opts = {} }, { "tpope/vim-fugitive" },')
})

vim.schedule(function()
  vim.cmd.colorscheme "catppuccin"
  require("mason").setup()
  require("mason-lspconfig").setup({
      ensure_installed = { "pyright" $([[ "$INSTALL_BASH" == true ]] && echo ', "bashls"') }
  })

  local caps = pcall(require, 'cmp_nvim_lsp') and require('cmp_nvim_lsp').default_capabilities() or {}
  
  -- Using Native v0.11 LSP patterns
  if vim.lsp.config then
      vim.lsp.config('*', { capabilities = caps })
      vim.lsp.enable('pyright')
      $([[ "$INSTALL_BASH" == true ]] && echo "vim.lsp.enable('bashls')")
  end

  $([[ "$INSTALL_DAP" == true ]] && cat <<DAP_LUA
  local dap, dapui = require("dap"), require("dapui")
  dapui.setup()
  dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
  dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
  require('dap-python').setup('python3')
DAP_LUA
)
end)

-- KEYBINDINGS
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
EOF

# --- 4. Validation & Warm-up ---
log "INFO" "Warming up plugins and generating health report..."
nvim --headless "+Lazy! sync" +qa > $REDIRECT 2>&1
nvim --headless "+checkhealth" "+w! nvim_health.log" "+qa" > /dev/null 2>&1

echo -e "\n--- Validation Check ---"
command -v luarocks >/dev/null && echo -e "\033[0;32m[OK]\033[0m LuaRocks installed"
command -v tree-sitter >/dev/null && echo -e "\033[0;32m[OK]\033[0m Tree-sitter-cli installed"

log "SUCCESS" "Installation finished."
echo "------------------------------------------"
echo -e "\033[0;32m\u2705 Neovim $(nvim --version | head -n 1) is ready!\033[0m"
echo -e "\033[0;34m\u2139 Full health report saved to: nvim_health.log\033[0m"
echo "------------------------------------------"
