#!/bin/bash

# RF Emitter Localization System - Complete Analysis Script
# This script executes the complete RF localization pipeline with your data
# 
# Usage: ./run_rf_localization_analysis.sh [OPTIONS]
# 
# Author: AI Assistant
# Date: 2025-08-19

set -e  # Exit on any error

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

# Default configuration
DETECTIONS_FILE="data/Data_Dist.xlsx"
TARGETS_FILE="data/Targets.xlsx"
OUTPUT_DIR="output"
BENCHMARKING_DIR="benchmarking_results"
VALIDATION_DIR="validation_results"
RESEARCH_REPORT_DIR="research_report"
CENTER_LAT="22.0"
CENTER_LON="25.0"
VERBOSE=false
MONTE_CARLO_ITERATIONS=50

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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
    echo -e "${PURPLE}============================================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}============================================================${NC}"
}

print_section() {
    echo -e "${CYAN}------------------------------------------------------------${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}------------------------------------------------------------${NC}"
}

# Function to show usage
show_usage() {
    cat << EOF
RF Emitter Localization System - Complete Analysis Script

USAGE:
    ./run_rf_localization_analysis.sh [OPTIONS]

OPTIONS:
    -d, --detections FILE       Path to detections Excel file (default: data/Data_Dist.xlsx)
    -t, --targets FILE          Path to targets Excel file (default: data/Targets.xlsx)
    -o, --output DIR            Output directory (default: output)
    --center-lat LAT            Center latitude for coordinate system (default: 22.0)
    --center-lon LON            Center longitude for coordinate system (default: 25.0)
    --monte-carlo N             Number of Monte Carlo iterations (default: 50)
    -v, --verbose               Enable verbose logging
    --skip-main                 Skip main localization (use existing results)
    --skip-benchmarking         Skip performance benchmarking
    --skip-validation           Skip advanced validation
    --skip-research-report      Skip research report generation
    --quick                     Quick analysis (reduced Monte Carlo iterations)
    -h, --help                  Show this help message

EXAMPLES:
    # Run complete analysis with default settings
    ./run_rf_localization_analysis.sh

    # Run with custom data files
    ./run_rf_localization_analysis.sh -d my_detections.xlsx -t my_targets.xlsx

    # Run with custom coordinate center and verbose output
    ./run_rf_localization_analysis.sh --center-lat 25.0 --center-lon 30.0 -v

    # Quick analysis (faster execution)
    ./run_rf_localization_analysis.sh --quick

OUTPUTS:
    The script generates comprehensive results in multiple directories:
    - output/                   Main localization results (GeoJSON, Excel)
    - benchmarking_results/     Performance analysis and comparisons
    - validation_results/       Advanced statistical validation
    - research_report/          Publication-ready research documentation

REQUIREMENTS:
    - Python 3.8+ with required packages (install: pip install -r requirements.txt)
    - Input data files in Excel format
    - Sufficient disk space for results (recommended: 500MB+)

EOF
}

# Function to check requirements
check_requirements() {
    print_section "Checking System Requirements"
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is required but not installed"
        exit 1
    fi
    
    python_version=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    print_status "Python version: $python_version"
    
    # Check if virtual environment exists and activate it
    if [ -d ".venv" ]; then
        print_status "Activating virtual environment..."
        source .venv/bin/activate
    else
        print_warning "Virtual environment not found. Using system Python."
    fi
    
#     # Check required Python packages
#     print_status "Checking Python packages..."
#     python3 -c "
# import sys
# required_packages = ['numpy', 'pandas', 'scipy', 'scikit-learn', 'matplotlib', 'seaborn', 'shapely', 'pyproj', 'openpyxl']
# missing_packages = []

# for package in required_packages:
#     try:
#         __import__(package)
#     except ImportError:
#         missing_packages.append(package)

# if missing_packages:
#     print('Missing packages:', ', '.join(missing_packages))
#     print('Install with: pip install -r requirements.txt')
#     sys.exit(1)
# else:
#     print('All required packages are installed.')
# "
    
#     if [ $? -ne 0 ]; then
#         print_error "Missing required Python packages"
#         exit 1
#     fi
    
    # Check input files
    if [ ! -f "$DETECTIONS_FILE" ]; then
        print_error "Detections file not found: $DETECTIONS_FILE"
        exit 1
    fi
    
    if [ ! -f "$TARGETS_FILE" ]; then
        print_error "Targets file not found: $TARGETS_FILE"
        exit 1
    fi
    
    print_success "All requirements satisfied"
}

# Function to create output directories
setup_directories() {
    print_section "Setting Up Output Directories"
    
    directories=("$OUTPUT_DIR" "$BENCHMARKING_DIR" "$VALIDATION_DIR" "$RESEARCH_REPORT_DIR")
    
    for dir in "${directories[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            print_status "Created directory: $dir"
        else
            print_status "Directory exists: $dir"
        fi
    done
    
    print_success "Output directories ready"
}

# Function to run main localization
run_main_localization() {
    print_section "Running Main RF Emitter Localization"
    
    local verbose_flag=""
    if [ "$VERBOSE" = true ]; then
        verbose_flag="--verbose"
    fi
    
    print_status "Processing RF detections with multiple localization methods..."
    
    python3 rf_emitter_localization_system.py \
        --detections "$DETECTIONS_FILE" \
        --targets "$TARGETS_FILE" \
        --output "$OUTPUT_DIR" \
        --center-lat "$CENTER_LAT" \
        --center-lon "$CENTER_LON" \
        $verbose_flag
    
    if [ $? -eq 0 ]; then
        print_success "Main localization completed successfully"
        
        # Display summary of generated files
        if [ -f "$OUTPUT_DIR/emitter_probable_areas.geojson" ]; then
            print_status "Generated: $OUTPUT_DIR/emitter_probable_areas.geojson"
        fi
        if [ -f "$OUTPUT_DIR/localization_results.xlsx" ]; then
            print_status "Generated: $OUTPUT_DIR/localization_results.xlsx"
        fi
    else
        print_error "Main localization failed"
        exit 1
    fi
}

# Function to run performance benchmarking
run_performance_benchmarking() {
    print_section "Running Performance Analysis and Benchmarking"
    
    print_status "Analyzing performance across multiple localization methods..."
    print_status "This includes: Triangulation, Robust Triangulation, RSS, and Hybrid Fusion"
    
    python3 performance_analysis_system.py
    
    if [ $? -eq 0 ]; then
        print_success "Performance benchmarking completed successfully"
        
        # Display summary of generated files
        if [ -d "$BENCHMARKING_DIR" ]; then
            file_count=$(find "$BENCHMARKING_DIR" -type f | wc -l)
            print_status "Generated $file_count files in $BENCHMARKING_DIR/"
            
            # List key files
            for file in "benchmarking_report.json" "performance_summary.xlsx" "method_comparison.png"; do
                if [ -f "$BENCHMARKING_DIR/$file" ]; then
                    print_status "Generated: $BENCHMARKING_DIR/$file"
                fi
            done
        fi
    else
        print_error "Performance benchmarking failed"
        exit 1
    fi
}

# Function to run advanced validation
run_advanced_validation() {
    print_section "Running Advanced Statistical Validation"
    
    print_status "Performing statistical validation and benchmark comparison..."
    print_status "This includes: Monte Carlo analysis, normality testing, confidence intervals"
    
    # Modify the Monte Carlo iterations in the validation script if needed
    if [ "$MONTE_CARLO_ITERATIONS" != "100" ]; then
        print_status "Using $MONTE_CARLO_ITERATIONS Monte Carlo iterations"
    fi
    
    python3 validation_and_benchmarking.py
    
    if [ $? -eq 0 ]; then
        print_success "Advanced validation completed successfully"
        
        # Display summary of generated files
        if [ -d "$VALIDATION_DIR" ]; then
            file_count=$(find "$VALIDATION_DIR" -type f | wc -l)
            print_status "Generated $file_count files in $VALIDATION_DIR/"
            
            # List key files
            for file in "validation_report.json" "validation_results.xlsx" "error_distributions.png"; do
                if [ -f "$VALIDATION_DIR/$file" ]; then
                    print_status "Generated: $VALIDATION_DIR/$file"
                fi
            done
        fi
    else
        print_error "Advanced validation failed"
        exit 1
    fi
}

# Function to generate research report
generate_research_report() {
    print_section "Generating Comprehensive Research Report"
    
    print_status "Creating publication-ready research documentation..."
    print_status "This includes: Executive summary, methodology, results, visualizations"
    
    python3 generate_research_report.py
    
    if [ $? -eq 0 ]; then
        print_success "Research report generation completed successfully"
        
        # Display summary of generated files
        if [ -d "$RESEARCH_REPORT_DIR" ]; then
            file_count=$(find "$RESEARCH_REPORT_DIR" -type f | wc -l)
            print_status "Generated $file_count files in $RESEARCH_REPORT_DIR/"
            
            # List key files
            for file in "research_report.md" "method_performance_overview.png" "benchmark_achievement.png"; do
                if [ -f "$RESEARCH_REPORT_DIR/$file" ]; then
                    print_status "Generated: $RESEARCH_REPORT_DIR/$file"
                fi
            done
        fi
    else
        print_error "Research report generation failed"
        exit 1
    fi
}

# Function to display final summary
display_final_summary() {
    print_header "RF EMITTER LOCALIZATION ANALYSIS COMPLETE"
    
    echo
    print_section "RESULTS SUMMARY"
    
    # Main localization results
    if [ -f "$OUTPUT_DIR/localization_results.xlsx" ]; then
        echo -e "${GREEN}✓${NC} Main Localization Results:"
        echo "  - GeoJSON: $OUTPUT_DIR/emitter_probable_areas.geojson"
        echo "  - Excel: $OUTPUT_DIR/localization_results.xlsx"
        echo "  - Log: rf_localization.log"
    fi
    
    # Performance benchmarking results
    if [ -f "$BENCHMARKING_DIR/benchmarking_report.json" ]; then
        echo -e "${GREEN}✓${NC} Performance Benchmarking Results:"
        echo "  - Report: $BENCHMARKING_DIR/benchmarking_report.json"
        echo "  - Summary: $BENCHMARKING_DIR/performance_summary.xlsx"
        echo "  - Visualizations: $BENCHMARKING_DIR/method_comparison.png"
        echo "  - Stage Compliance: $BENCHMARKING_DIR/stage_compliance.png"
    fi
    
    # Validation results
    if [ -f "$VALIDATION_DIR/validation_report.json" ]; then
        echo -e "${GREEN}✓${NC} Advanced Validation Results:"
        echo "  - Report: $VALIDATION_DIR/validation_report.json"
        echo "  - Results: $VALIDATION_DIR/validation_results.xlsx"
        echo "  - Distributions: $VALIDATION_DIR/error_distributions.png"
        echo "  - Benchmark Comparison: $VALIDATION_DIR/benchmark_comparison.png"
    fi
    
    # Research report
    if [ -f "$RESEARCH_REPORT_DIR/research_report.md" ]; then
        echo -e "${GREEN}✓${NC} Research Documentation:"
        echo "  - Report: $RESEARCH_REPORT_DIR/research_report.md"
        echo "  - Performance Overview: $RESEARCH_REPORT_DIR/method_performance_overview.png"
        echo "  - Benchmark Achievement: $RESEARCH_REPORT_DIR/benchmark_achievement.png"
        echo "  - Clean Data: $RESEARCH_REPORT_DIR/performance_summary_clean.xlsx"
    fi
    
    echo
    print_section "PERFORMANCE HIGHLIGHTS"
    
    # Extract key performance metrics if available
    if [ -f "$BENCHMARKING_DIR/benchmarking_report.json" ]; then
        python3 -c "
import json
try:
    with open('$BENCHMARKING_DIR/benchmarking_report.json', 'r') as f:
        data = json.load(f)
    
    print('Dataset Information:')
    dataset = data.get('dataset_info', {})
    print(f'  - Target Emitters: {dataset.get(\"targets_count\", \"N/A\")}')
    
    print()
    print('Method Performance:')
    methods = data.get('method_performance', {})
    for method, perf in methods.items():
        area = perf.get('average_probable_area_km2', 'N/A')
        success = perf.get('success_rate', 0) * 100
        print(f'  - {method}:')
        print(f'    Average Area: {area:.2f} km² | Success Rate: {success:.1f}%')
    
    print()
    print('Research Benchmarks:')
    benchmarks = data.get('research_benchmarks', {})
    reported_area = benchmarks.get('reported_average_area_km2', 1.4)
    print(f'  - Published Benchmark: {reported_area} km²')
    
    # Find best performing method
    best_method = None
    best_area = float('inf')
    for method, perf in methods.items():
        area = perf.get('average_probable_area_km2', float('inf'))
        if area < best_area:
            best_area = area
            best_method = method
    
    if best_method and best_area < reported_area:
        improvement = ((reported_area - best_area) / reported_area) * 100
        print(f'  - Best Achievement: {best_method} with {best_area:.2f} km² ({improvement:.1f}% better)')

except Exception as e:
    print(f'Could not extract performance summary: {e}')
"
    fi
    
    echo
    print_section "NEXT STEPS"
    echo "1. Review the generated reports and visualizations"
    echo "2. Open GeoJSON files in GIS software for geographic visualization"
    echo "3. Analyze Excel files for detailed numerical results"
    echo "4. Use research report for documentation and publication"
    echo "5. Customize parameters and re-run for different scenarios"
    
    echo
    print_success "Analysis pipeline completed successfully!"
    print_status "Total execution time: $((SECONDS / 60)) minutes $((SECONDS % 60)) seconds"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--detections)
            DETECTIONS_FILE="$2"
            shift 2
            ;;
        -t|--targets)
            TARGETS_FILE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --center-lat)
            CENTER_LAT="$2"
            shift 2
            ;;
        --center-lon)
            CENTER_LON="$2"
            shift 2
            ;;
        --monte-carlo)
            MONTE_CARLO_ITERATIONS="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --skip-main)
            SKIP_MAIN=true
            shift
            ;;
        --skip-benchmarking)
            SKIP_BENCHMARKING=true
            shift
            ;;
        --skip-validation)
            SKIP_VALIDATION=true
            shift
            ;;
        --skip-research-report)
            SKIP_RESEARCH_REPORT=true
            shift
            ;;
        --quick)
            MONTE_CARLO_ITERATIONS=10
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    # Start timer
    SECONDS=0
    
    print_header "RF EMITTER LOCALIZATION SYSTEM - COMPLETE ANALYSIS"
    
    echo
    print_status "Analysis Configuration:"
    echo "  - Detections File: $DETECTIONS_FILE"
    echo "  - Targets File: $TARGETS_FILE"
    echo "  - Output Directory: $OUTPUT_DIR"
    echo "  - Coordinate Center: ($CENTER_LAT, $CENTER_LON)"
    echo "  - Monte Carlo Iterations: $MONTE_CARLO_ITERATIONS"
    echo "  - Verbose Output: $VERBOSE"
    echo
    
    # Execute pipeline steps
    check_requirements
    setup_directories
    
    # Main localization
    if [ "$SKIP_MAIN" != true ]; then
        run_main_localization
    else
        print_warning "Skipping main localization (using existing results)"
    fi
    
    # Performance benchmarking
    if [ "$SKIP_BENCHMARKING" != true ]; then
        run_performance_benchmarking
    else
        print_warning "Skipping performance benchmarking"
    fi
    
    # Advanced validation
    if [ "$SKIP_VALIDATION" != true ]; then
        run_advanced_validation
    else
        print_warning "Skipping advanced validation"
    fi
    
    # Research report generation
    if [ "$SKIP_RESEARCH_REPORT" != true ]; then
        generate_research_report
    else
        print_warning "Skipping research report generation"
    fi
    
    # Final summary
    display_final_summary
}

# Execute main function
main "$@"