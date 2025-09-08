!/usr/bin/env bash

NEOVIM_VERSION="v0.11.4"
NEOVIM_URL="https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux64.tar.gz"
INSTALL_DIR="/usr/local/nvim-linux64"

# Function to install packages based on the detected package manager
install_package() {
    local PACKAGE=$1
    local PACKAGE_MANAGER=$(detect_package_manager)

    case $PACKAGE_MANAGER in
        pacman)
            sudo pacman -Sy $PACKAGE
            ;;
        apt)
            sudo apt update && sudo apt install -y $PACKAGE
            ;;
        dnf)
            sudo dnf install -y $PACKAGE
            ;;
        *)
            echo "Unknown package manager. Please install $PACKAGE manually."
            exit 1
            ;;
    esac
}

# Function to detect the package manager
detect_package_manager() {
    if command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    elif command -v apt-get >/dev/null 2>&1; then
        echo "apt"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    else
        echo "unknown"
    fi
}

# Install wget if not already installed
which wget && echo "wget already installed" || (
    echo "Installing wget..."
    install_package wget
)

# Install Neovim if not already installed
if command -v nvim >/dev/null 2>&1; then
    echo "Neovim is already installed at $(command -v nvim)"
else
    echo "Downloading Neovim ${NEOVIM_VERSION}..."
    wget $NEOVIM_URL -O nvim-linux64.tar.gz

    echo "Extracting Neovim..."
    tar -xzf nvim-linux64.tar.gz

    echo "Installing Neovim..."
    sudo mv nvim-linux64 $INSTALL_DIR

    echo "Creating symlink for Neovim..."
    sudo ln -sf $INSTALL_DIR/bin/nvim /usr/local/bin/nvim

    rm -f nvim-linux64.tar.gz

    echo "Neovim ${NEOVIM_VERSION} installed successfully!"
fi

# Install unzip if not already installed
which unzip && echo "unzip already installed" || (
    echo "Installing unzip..."
    install_package unzip
)

# Symlink Neovim config
ln -sf "$HOME/.dotfiles/.config/nvim" "$HOME/.config/nvim" && echo "Symlink Created: ~/.config -> $HOME/.dotfiles/.config" || echo "Failed to create symlink."

# Install Zsh if not already installed
install_package zsh
echo "Zsh installed successfully."

# Symlink Zsh config
ln -sf "$HOME/.dotfiles/.zshrc" "$HOME/.zshrc" && echo "Symlink created: ~/.zshrc -> $HOME/.dotfiles/.zshrc" || echo "Failed to create symlink."

# Set Zsh as default shell
chsh -s $(which zsh) && echo "Zsh set as the default shell." || echo "Failed to set Zsh as the default shell."

# Install Git if not already installed
ln -sf "$HOME/.dotfiles/.gitconfig" "$HOME/.gitconfig" && echo "Symlink created: ~/.gitconfig -> $HOME/.dotfiles/.gitconfig" || echo "Failed to create symlink."

# Install tmux if not already installed
install_package tmux
echo "Tmux installed."

# Symlink tmux config
ln -sf "$HOME/.dotfiles/.tmux/.tmux.conf" "$HOME/.tmux.conf" && echo "Symlink created: ~/.tmux.conf -> $HOME/.dotfiles/.tmux/.tmux.conf" || echo "Failed to create symlink."

# Reload tmux config
command -v tmux && tmux source-file ~/.tmux.conf || echo "tmux is not installed"

# Install NVM (Node Version Manager)
if ! command -v nvm &>/dev/null; then
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
else
    echo "NVM is already installed."
fi

# Load NVM into the current shell session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install the latest LTS version of Node.js
nvm install --lts

# Set the installed version as default
nvm alias default 'lts/*'

# Install pnpm globally using NVM-managed Node.js
if ! command -v pnpm &>/dev/null; then
    echo "Installing pnpm..."
    curl -fsSL https://get.pnpm.io/install.sh | sh -
else
    echo "PNPM is already installed."
fi

# Set up pnpm (create necessary directories)
echo "Setting up PNPM..."
pnpm setup || echo "Failed to set up PNPM. Proceeding anyway."

# Add pnpm global bin directory to PATH
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Optionally, make this permanent by adding to .zshrc
echo "export PNPM_HOME=\"$HOME/.local/share/pnpm\"" >> "$HOME/.zshrc"
echo "export PATH=\"$PNPM_HOME:$PATH\"" >> "$HOME/.zshrc"

# You can also verify pnpm installation and the global bin directory
pnpm -v && pnpm bin -g

# Install TypeScript and ts-node globally using pnpm
echo "Installing TypeScript and ts-node..."
pnpm add -g typescript ts-node

# Example of running a setup command for your dev environment
echo "Setting up development environment..."

echo "Development environment setup completed successfully!"

#postgress stuff
install_package postgresql-server postgresql-contrib

sudo systemctl enable postgresql

sudo postgresql-setup --initdb --unit postgresql

sudo systemctl start postgresql
