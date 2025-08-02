#!/bin/bash

# install_iceprog.sh
# Script to install iceprog (part of IceStorm toolchain) on macOS and Linux
# This enables hardware programming of FPGA boards without Docker USB passthrough issues

set -e  # Exit on any error

echo "=== IceStorm iceprog Installation Script ==="
echo ""

# Detect operating system
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

echo "Detected OS: $MACHINE"

# Check if iceprog is already installed
if command -v iceprog >/dev/null 2>&1; then
    echo "✅ iceprog is already installed at: $(which iceprog)"
    iceprog --help | head -3
    echo ""
    echo "If you want to reinstall, please remove the existing installation first."
    exit 0
fi

echo "📦 Installing iceprog..."

if [ "$MACHINE" = "Mac" ]; then
    echo ""
    echo "🍎 macOS Installation"
    echo "===================="
    
    # Check if Homebrew is installed
    if ! command -v brew >/dev/null 2>&1; then
        echo "❌ Homebrew is not installed. Please install Homebrew first:"
        echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    
    echo "📋 Installing dependencies via Homebrew..."
    brew install libftdi libusb
    
    echo "📥 Cloning IceStorm repository..."
    if [ -d "icestorm" ]; then
        echo "⚠️  icestorm directory already exists. Removing..."
        rm -rf icestorm
    fi
    git clone https://github.com/YosysHQ/icestorm.git
    
    echo "🔨 Building IceStorm..."
    cd icestorm
    make -j$(sysctl -n hw.ncpu)
    
    echo "📦 Installing IceStorm (requires sudo)..."
    sudo make install
    
    echo "🧹 Cleaning up..."
    cd ..
    rm -rf icestorm
    
elif [ "$MACHINE" = "Linux" ]; then
    echo ""
    echo "🐧 Linux Installation"
    echo "==================="
    
    # Detect Linux distribution
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        echo "❌ Cannot detect Linux distribution"
        exit 1
    fi
    
    echo "Detected distribution: $DISTRO"
    
    # Install dependencies based on distribution
    case $DISTRO in
        ubuntu|debian)
            echo "📋 Installing dependencies via apt..."
            sudo apt-get update
            sudo apt-get install -y build-essential clang bison flex libreadline-dev \
                                    gawk tcl-dev libffi-dev git graphviz xdot pkg-config \
                                    python3 libftdi1-dev libusb-1.0-0-dev
            ;;
        fedora|centos|rhel)
            echo "📋 Installing dependencies via yum/dnf..."
            sudo yum install -y gcc gcc-c++ clang bison flex readline-devel gawk \
                               tcl-devel libffi-devel git graphviz python3 \
                               libftdi-devel libusb1-devel || \
            sudo dnf install -y gcc gcc-c++ clang bison flex readline-devel gawk \
                               tcl-devel libffi-devel git graphviz python3 \
                               libftdi-devel libusb1-devel
            ;;
        arch)
            echo "📋 Installing dependencies via pacman..."
            sudo pacman -S --needed base-devel clang bison flex readline gawk \
                                   tcl libffi git graphviz python libftdi libusb
            ;;
        *)
            echo "⚠️  Unsupported Linux distribution: $DISTRO"
            echo "Please install the following packages manually:"
            echo "  - build-essential/base-devel"
            echo "  - clang, bison, flex, gawk, tcl-dev, libffi-dev"
            echo "  - git, graphviz, python3"
            echo "  - libftdi-dev, libusb-1.0-dev"
            echo ""
            echo "Then run this script again."
            exit 1
            ;;
    esac
    
    echo "📥 Cloning IceStorm repository..."
    if [ -d "icestorm" ]; then
        echo "⚠️  icestorm directory already exists. Removing..."
        rm -rf icestorm
    fi
    git clone https://github.com/YosysHQ/icestorm.git
    
    echo "🔨 Building IceStorm..."
    cd icestorm
    make -j$(nproc)
    
    echo "📦 Installing IceStorm (requires sudo)..."
    sudo make install
    
    echo "🧹 Cleaning up..."
    cd ..
    rm -rf icestorm
    
else
    echo "❌ Unsupported operating system: $MACHINE"
    echo "This script supports macOS and Linux only."
    exit 1
fi

echo ""
echo "✅ Installation completed successfully!"
echo ""

# Verify installation
if command -v iceprog >/dev/null 2>&1; then
    echo "🎉 iceprog is now available at: $(which iceprog)"
    echo ""
    echo "📋 Installation summary:"
    iceprog --help | head -3
    echo ""
    echo "🚀 You can now use 'make burn' to program your FPGA!"
    echo ""
    echo "💡 Tips:"
    echo "  - Make sure your FPGA board is connected via USB"
    echo "  - On Linux, you might need to add your user to the 'dialout' group:"
    echo "    sudo usermod -a -G dialout \$USER"
    echo "  - Then log out and log back in for the changes to take effect"
else
    echo "❌ Installation failed. iceprog is not available in PATH."
    echo "Please check the installation logs above for errors."
    exit 1
fi

echo ""
echo "🎯 Next steps:"
echo "  1. Connect your FPGA board via USB"
echo "  2. Navigate to your project directory"
echo "  3. Run 'make burn' to program the FPGA"
echo ""
echo "Happy FPGA programming! 🚀"
