#!/bin/bash

# RF Emitter Localization System - Setup Script
# This script sets up the environment and installs dependencies
# 
# Usage: ./setup.sh
# 
# Author: AI Assistant
# Date: 2025-08-19

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${GREEN}============================================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}============================================================${NC}"
}

# Check Python installation
check_python() {
    print_status "Checking Python installation..."
    
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed"
        print_status "Please install Python 3.8 or higher from https://python.org"
        exit 1
    fi
    
    python_version=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    print_success "Python $python_version found"
    
    # Check if Python version is 3.8+
    if python3 -c "import sys; exit(0 if sys.version_info >= (3, 8) else 1)"; then
        print_success "Python version is compatible"
    else
        print_error "Python 3.8 or higher is required"
        exit 1
    fi
}

# Setup virtual environment
setup_virtual_environment() {
    print_status "Setting up virtual environment..."
    
    if [ ! -d ".venv" ]; then
        print_status "Creating virtual environment..."
        python3 -m venv .venv
        print_success "Virtual environment created"
    else
        print_status "Virtual environment already exists"
    fi
    
    print_status "Activating virtual environment..."
    source .venv/bin/activate
    
    print_status "Upgrading pip..."
    pip install --upgrade pip
    
    print_success "Virtual environment ready"
}

# Install Python packages
install_packages() {
    print_status "Installing Python packages..."
    
    # Check if requirements.txt exists
    if [ ! -f "requirements.txt" ]; then
        print_warning "requirements.txt not found, creating one..."
        cat > requirements.txt << EOF
# RF Emitter Localization System Requirements
numpy>=1.21.0
pandas>=1.3.0
scipy>=1.7.0
scikit-learn>=1.0.0
matplotlib>=3.5.0
seaborn>=0.11.0
shapely>=1.8.0
pyproj>=3.2.0
openpyxl>=3.0.0
xlsxwriter>=3.0.0
EOF
        print_success "Created requirements.txt"
    fi
    
    print_status "Installing packages from requirements.txt..."
    pip install -r requirements.txt
    
    print_success "All packages installed successfully"
}

# Verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    python3 -c "
import sys
packages = [
    'numpy', 'pandas', 'scipy', 'sklearn', 'matplotlib', 
    'seaborn', 'shapely', 'pyproj', 'openpyxl'
]

print('Checking Python packages:')
for package in packages:
    try:
        module = __import__(package)
        if hasattr(module, '__version__'):
            version = module.__version__
        else:
            version = 'installed'
        print(f'  ✓ {package}: {version}')
    except ImportError as e:
        print(f'  ✗ {package}: NOT INSTALLED')
        sys.exit(1)

print()
print('All packages verified successfully!')
"
    
    if [ $? -eq 0 ]; then
        print_success "Installation verification passed"
    else
        print_error "Installation verification failed"
        exit 1
    fi
}

# Check data files
check_data_files() {
    print_status "Checking data files..."
    
    if [ ! -d "data" ]; then
        print_warning "Data directory not found, creating..."
        mkdir -p data
    fi
    
    if [ ! -f "data/Data_Dist.xlsx" ]; then
        print_warning "data/Data_Dist.xlsx not found"
        print_status "Please place your detection data file at: data/Data_Dist.xlsx"
    else
        print_success "Detection data file found: data/Data_Dist.xlsx"
    fi
    
    if [ ! -f "data/Targets.xlsx" ]; then
        print_warning "data/Targets.xlsx not found"
        print_status "Please place your target data file at: data/Targets.xlsx"
    else
        print_success "Target data file found: data/Targets.xlsx"
    fi
}

# Make scripts executable
setup_scripts() {
    print_status "Setting up executable scripts..."
    
    chmod +x run_rf_localization_analysis.sh
    print_success "run_rf_localization_analysis.sh is now executable"
    
    if [ -f "setup.sh" ]; then
        chmod +x setup.sh
        print_success "setup.sh is now executable"
    fi
}

# Create demo data (if no real data exists)
create_demo_data() {
    if [ ! -f "data/Data_Dist.xlsx" ] || [ ! -f "data/Targets.xlsx" ]; then
        print_status "Creating demo data files for testing..."
        
        python3 -c "
import pandas as pd
import numpy as np
from pathlib import Path

# Create data directory
Path('data').mkdir(exist_ok=True)

# Create demo detection data
np.random.seed(42)
n_detections = 1000

detections_data = {
    'Lat': np.random.uniform(20, 30, n_detections),
    'Lon': np.random.uniform(20, 30, n_detections),
    'Angle': np.random.uniform(0, 360, n_detections),
    'Freq': np.random.uniform(1800, 2100, n_detections),
    'PRI': np.random.uniform(100, 1000, n_detections),
    'PW': np.random.uniform(1, 10, n_detections),
    'Time': ['2025-01-01 12:00:00'] * n_detections,
    'DF_Q': np.random.randint(1, 10, n_detections)
}

detections_df = pd.DataFrame(detections_data)
detections_df.to_excel('data/Data_Dist.xlsx', index=False)

# Create demo target data
targets_data = {
    'Frequency': ['1850-1900', '1900-1950', '1950-2000', '2000-2050', '2050-2100'],
    'Latitude': [22.5, 24.0, 25.5, 27.0, 28.5],
    'Longitude': [23.0, 24.5, 26.0, 27.5, 29.0]
}

targets_df = pd.DataFrame(targets_data)
targets_df.to_excel('data/Targets.xlsx', index=False)

print('Demo data files created successfully!')
"
        
        if [ $? -eq 0 ]; then
            print_success "Demo data files created for testing"
            print_warning "Replace with your actual data files when ready"
        else
            print_error "Failed to create demo data files"
        fi
    fi
}

# Main setup function
main() {
    print_header "RF EMITTER LOCALIZATION SYSTEM - SETUP"
    
    echo "This script will set up your environment for running the RF localization system."
    echo
    
    check_python
    setup_virtual_environment
    install_packages
    verify_installation
    check_data_files
    setup_scripts
    create_demo_data
    
    echo
    print_header "SETUP COMPLETE"
    
    print_success "Environment setup completed successfully!"
    echo
    print_status "Next steps:"
    echo "1. Place your data files in the data/ directory:"
    echo "   - data/Data_Dist.xlsx (RF detection data)"
    echo "   - data/Targets.xlsx (ground truth target data)"
    echo
    echo "2. Run the analysis:"
    echo "   ./run_rf_localization_analysis.sh"
    echo
    echo "3. For help and options:"
    echo "   ./run_rf_localization_analysis.sh --help"
    echo
    
    if [ -f "data/Data_Dist.xlsx" ] && [ -f "data/Targets.xlsx" ]; then
        print_status "Data files detected - you can run the analysis immediately!"
        echo
        echo "Quick start:"
        echo "  ./run_rf_localization_analysis.sh"
    else
        print_warning "Place your data files first before running the analysis"
    fi
}

# Run main function
main "$@"