# RF Emitter Localization System - Complete Usage Guide

## Quick Start

### 1. Setup Environment
```bash
# Make scripts executable and install dependencies
./setup.sh
```

### 2. Run Complete Analysis
```bash
# Run the full analysis pipeline with your data
./run_rf_localization_analysis.sh
```

### 3. View Results
- **Main Results**: `output/` directory
- **Performance Analysis**: `benchmarking_results/` directory  
- **Statistical Validation**: `validation_results/` directory
- **Research Report**: `research_report/` directory

---

## Detailed Usage Instructions

### Prerequisites

#### System Requirements
- **Operating System**: Linux, macOS, or Windows with WSL
- **Python**: Version 3.8 or higher
- **Memory**: 8 GB RAM minimum (16 GB recommended)
- **Storage**: 2 GB free space for results
- **Dependencies**: See `requirements.txt`

#### Data Requirements
- **Detection Data**: Excel file with RF detection measurements
- **Target Data**: Excel file with ground truth emitter positions

### Data Format Requirements

#### Detection Data File (e.g., `data/Data_Dist.xlsx`)
Required columns:
- `Lat`: Sensor latitude (decimal degrees)
- `Lon`: Sensor longitude (decimal degrees) 
- `Angle`: Bearing angle (degrees, 0-360)
- `Freq`: Frequency (MHz)
- `PRI`: Pulse Repetition Interval (microseconds)
- `PW`: Pulse Width (microseconds)
- `Time`: Timestamp
- `DF_Q`: Detection quality score (1-10)

#### Target Data File (e.g., `data/Targets.xlsx`)
Required columns:
- `Frequency`: Frequency or frequency range (MHz)
- `Latitude`: Target latitude (decimal degrees)
- `Longitude`: Target longitude (decimal degrees)

### Setup Instructions

#### Option 1: Automated Setup
```bash
# Run the setup script (recommended)
./setup.sh
```

#### Option 2: Manual Setup
```bash
# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Make scripts executable
chmod +x *.sh
```

### Running the Analysis

#### Complete Analysis (Recommended)
```bash
# Run everything with default settings
./run_rf_localization_analysis.sh

# Run with custom data files
./run_rf_localization_analysis.sh -d my_detections.xlsx -t my_targets.xlsx

# Run with verbose output
./run_rf_localization_analysis.sh --verbose

# Quick analysis (faster, fewer Monte Carlo iterations)
./run_rf_localization_analysis.sh --quick
```

#### Custom Configuration
```bash
# Custom coordinate center
./run_rf_localization_analysis.sh --center-lat 25.0 --center-lon 30.0

# Custom output directory
./run_rf_localization_analysis.sh --output my_results

# Custom Monte Carlo iterations
./run_rf_localization_analysis.sh --monte-carlo 100
```

#### Partial Analysis
```bash
# Skip certain components
./run_rf_localization_analysis.sh --skip-validation
./run_rf_localization_analysis.sh --skip-research-report
./run_rf_localization_analysis.sh --skip-benchmarking
```

### Advanced Usage

#### Running Individual Components

**1. Main Localization Only**
```bash
python3 rf_emitter_localization_system.py \
    --detections data/Data_Dist.xlsx \
    --targets data/Targets.xlsx \
    --output ./output \
    --center-lat 22.0 \
    --center-lon 25.0 \
    --verbose
```

**2. Performance Benchmarking Only**
```bash
python3 performance_analysis_system.py
```

**3. Advanced Validation Only**
```bash
python3 validation_and_benchmarking.py
```

**4. Research Report Generation Only**
```bash
python3 generate_research_report.py
```

### Command Line Options

#### Main Script Options
```
USAGE: ./run_rf_localization_analysis.sh [OPTIONS]

OPTIONS:
    -d, --detections FILE       Path to detections Excel file
    -t, --targets FILE          Path to targets Excel file  
    -o, --output DIR            Output directory
    --center-lat LAT            Center latitude for coordinate system
    --center-lon LON            Center longitude for coordinate system
    --monte-carlo N             Number of Monte Carlo iterations
    -v, --verbose               Enable verbose logging
    --skip-main                 Skip main localization
    --skip-benchmarking         Skip performance benchmarking
    --skip-validation           Skip advanced validation  
    --skip-research-report      Skip research report generation
    --quick                     Quick analysis (reduced iterations)
    -h, --help                  Show help message
```

### Output Description

#### Main Localization Results (`output/`)
- **`emitter_probable_areas.geojson`**: GIS-compatible probable area polygons
- **`localization_results.xlsx`**: Detailed tabular results
- **`rf_localization.log`**: Execution log file

#### Performance Analysis (`benchmarking_results/`)
- **`benchmarking_report.json`**: Comprehensive performance metrics
- **`performance_summary.xlsx`**: Method comparison summary
- **`method_comparison.png`**: Performance visualization
- **`stage_compliance.png`**: Stage requirements compliance
- **`detailed_results.xlsx`**: Detailed results by method

#### Statistical Validation (`validation_results/`)
- **`validation_report.json`**: Statistical validation results
- **`validation_results.xlsx`**: Validation summary tables
- **`error_distributions.png`**: Error distribution analysis
- **`benchmark_comparison.png`**: Benchmark achievement visualization

#### Research Documentation (`research_report/`)
- **`research_report.md`**: Complete research report
- **`method_performance_overview.png`**: Performance overview chart
- **`benchmark_achievement.png`**: Benchmark comparison chart
- **`performance_summary_clean.xlsx`**: Publication-ready data

### Troubleshooting

#### Common Issues

**1. Python Package Errors**
```bash
# Reinstall packages
pip install --upgrade -r requirements.txt

# Check virtual environment
source .venv/bin/activate
```

**2. Data File Errors**
- Verify Excel file format and column names
- Check for missing or corrupted data
- Ensure coordinate values are in decimal degrees

**3. Memory Issues**
```bash
# Reduce Monte Carlo iterations for large datasets
./run_rf_localization_analysis.sh --monte-carlo 10
```

**4. Permission Errors**
```bash
# Make scripts executable
chmod +x *.sh
```

#### Debug Mode
```bash
# Run with maximum verbosity
./run_rf_localization_analysis.sh --verbose
```

#### Log Files
- Check `rf_localization.log` for detailed execution logs
- Python error messages provide specific error locations

### Performance Optimization

#### For Large Datasets (>10,000 detections)
- Use `--quick` mode for initial analysis
- Reduce Monte Carlo iterations: `--monte-carlo 20`
- Consider running on multi-core systems

#### For Production Deployment
- Use full analysis with default settings
- Allocate sufficient memory (16+ GB recommended)
- Consider batch processing for multiple datasets

### Integration with GIS Software

#### QGIS Integration
1. Open QGIS
2. Add Vector Layer → Select `output/emitter_probable_areas.geojson`
3. Style probable area polygons by confidence levels

#### ArcGIS Integration
1. Import GeoJSON file as feature class
2. Symbolize by emitter properties
3. Create maps with coordinate grids

### API Integration

#### Python API Usage
```python
from rf_emitter_localization_system import RFEmitterLocalizationSystem

# Initialize system
system = RFEmitterLocalizationSystem(center_lat=22.0, center_lon=25.0)

# Process data
results = system.process_data(
    detections_file="data/Data_Dist.xlsx",
    targets_file="data/Targets.xlsx",
    output_dir="./output"
)

print(f"Processed {results['total_detections']} detections")
print(f"Identified {results['emitter_groups']} emitter groups")
```

### Customization

#### Modifying Localization Parameters
Edit parameters in the Python scripts:
- **Triangulation**: Modify Huber loss threshold in `GeometricTriangulator`
- **RANSAC**: Adjust iterations and threshold in `RobustEstimator`
- **RSS**: Modify weighting functions in `MethodComparator`

#### Adding New Methods
1. Implement method in `MethodComparator` class
2. Add to methods dictionary in `PerformanceAnalyzer`
3. Update visualization and reporting components

### Examples

#### Example 1: Basic Analysis
```bash
# Place your data files
cp my_rf_data.xlsx data/Data_Dist.xlsx
cp my_targets.xlsx data/Targets.xlsx

# Run complete analysis
./run_rf_localization_analysis.sh

# View results
ls -la output/
ls -la benchmarking_results/
```

#### Example 2: Custom Region Analysis
```bash
# Mediterranean region analysis
./run_rf_localization_analysis.sh \
    --center-lat 35.0 \
    --center-lon 20.0 \
    --output mediterranean_results
```

#### Example 3: High-Precision Analysis
```bash
# Maximum precision analysis
./run_rf_localization_analysis.sh \
    --monte-carlo 200 \
    --verbose \
    --output high_precision_results
```

### Support and Documentation

#### Additional Resources
- **Technical Report**: `RF_Emitter_Localization_Final_Research_Report.md`
- **Performance Analysis**: `PERFORMANCE_ANALYSIS_SUMMARY.md`
- **Research Foundation**: `Project research.md`
- **Implementation Details**: Source code comments

#### Getting Help
- Review error messages in log files
- Check data format requirements
- Verify system requirements are met
- Consult the comprehensive research report for methodology details

---

## Summary

The RF Emitter Localization System provides a complete, production-ready pipeline for RF emitter localization analysis. The shell scripts automate the entire process from data loading through research report generation, making it easy to run comprehensive analyses with your data.

**Key Benefits:**
- **Complete Automation**: Single command execution
- **Multiple Methods**: Triangulation, RANSAC, RSS, and Hybrid Fusion
- **Comprehensive Validation**: Statistical analysis and benchmark comparison
- **Professional Output**: GIS-compatible results and research documentation
- **Flexible Configuration**: Customizable parameters and execution options

Start with the quick setup and default analysis, then customize as needed for your specific requirements.