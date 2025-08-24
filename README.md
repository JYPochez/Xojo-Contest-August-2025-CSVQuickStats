# CSVQuickStats

A fast and intuitive console application for analyzing CSV datasets and generating comprehensive summaries without the need for spreadsheet applications.

## Overview

CSVQuickStats is designed for data analysts, developers, and anyone who needs to quickly understand the structure and content of CSV files. Get instant insights into your data with statistical summaries, column analysis, and export capabilities.

## Features

### ✅ Implemented

- [x] Console application with command line interface
- [x] CSV structure detection (rows/columns)  
- [x] Header identification and display
- [x] Column type detection (Text, Integer, Double, Boolean, Date, Mixed)
- [x] Statistical analysis for numeric columns (min, max, mean, median, std dev, Q1, Q3)
- [x] Text column analysis (unique values, length statistics)
- [x] Clean console output with aligned statistics
- [x] Export to JSON format
- [x] Export to Markdown format with tables
- [x] Error handling for malformed and empty files
- [x] Command line argument parsing with help system
- [x] Robust CSV parsing with quote handling
- [x] Enhanced error reporting with detailed issue descriptions and suggestions
- [x] Mixed data type detection and warnings for data quality assurance
- [x] Enhanced JSON and Markdown export with issue reporting integration
- [x] Automatic filename generation for export options without specified output files
- [x] File replacement confirmation dialog for existing output files

### 🎉 Development Complete

All core features have been implemented and tested successfully.

## Key Capabilities

**Basic Summary**

- Row and column count
- Complete headers list
- File structure overview

**Column Analysis**

- **Numeric Columns**: Min, max, mean, median, standard deviation, quartiles (Q1, Q3)
- **Text Columns**: Count of unique values, min/max/average length statistics
- **Data Types**: Automatic detection of Text, Integer, Double, Boolean, Date, Mixed

**Export Options**

- JSON format for automation and integration (includes comprehensive issue reporting)
- Markdown format for documentation and reporting (includes data quality sections)
- Automatic filename generation when output file not specified (`--json` → `filename.json`)
- Interactive file replacement confirmation for existing files

**Preview Mode**

- Display first N rows with properly aligned columns
- Quick data verification without opening full datasets

**Error Handling & Data Quality**

- Robust detection and reporting of malformed CSV files
- Graceful handling of edge cases and data inconsistencies
- Enhanced error reporting with line numbers and actionable suggestions
- Mixed data type warnings for columns containing both text and numbers
- Comprehensive issue reporting with severity levels (Critical, Warning, Info)

## Technical Specifications

- **Platform**: Console application built with Xojo
- **File Support**: Standard CSV files up to 50MB
- **Performance**: Optimized for quick analysis of large datasets
- **Output**: Console display with optional file export (JSON/Markdown)

## Use Cases

**For Data Analysts**

- Quickly understand CSV structure without opening Excel or similar tools
- Verify data integrity before detailed analysis
- Generate quick reports for stakeholders

**For Developers**

- Validate CSV files in data pipelines
- Get summary statistics for testing and validation
- Export structured summaries for automated workflows

**For General Users**

- Understand data files received from various sources
- Preview large CSV files without performance impact
- Generate readable summaries for documentation

## Installation

### macOS

The application is built and ready to use. No additional installation required.

1. **Download or Build**: 
   
   - Use the pre-built executable in the `CSVQuickStats/` directory
   - Or build from source using Xojo IDE

2. **Run from Terminal**:
   
   ```bash
   cd /path/to/CSVQuickStats/CSVQuickStats
   ./CSVQuickStats your-file.csv
   ```

3. **Add to PATH (Optional)**:
   
   ```bash
   # Add to your shell profile (~/.zshrc, ~/.bash_profile)
   export PATH="/path/to/CSVQuickStats/CSVQuickStats:$PATH"
   
   # Then use from anywhere
   CSVQuickStats data.csv
   ```

### Building from Source

1. **Requirements**:
   
   - Xojo IDE (2023 or later recommended)
   - macOS 10.15+ (for building)

2. **Build Steps**:
   
   ```bash
   # Clone the repository
   git clone <repository-url>
   cd CSVQuickStats
   
   # Open in Xojo IDE
   open CSVQuickStats.xojo_project
   
   # Build using Xojo IDE: Build → Build App
   # Executable will be created in CSVQuickStats/ directory
   ```

### Verification

Test the installation:

```bash
./CSVQuickStats test-data/simple-sales.csv
```

You should see CSV analysis output with statistics for 5 columns.

## Usage

### Command Line Interface

```bash
# Basic analysis - console output only
CSVQuickStats data.csv

# Export to JSON for automation
CSVQuickStats data.csv --json output.json

# Export to Markdown for documentation
CSVQuickStats data.csv --markdown report.md

# Export with automatic filenames (generates data.json and data.md)
CSVQuickStats data.csv --json --markdown

# Export to both formats with custom names
CSVQuickStats data.csv --json stats.json --markdown report.md
```

### Example Output

#### Clean CSV File (No Issues)
```
=== CSV Quick Statistics ===

File: sales-data.csv
Rows: 7
Columns: 5
Has Headers: Yes

=== Column Statistics ===

Column: Quantity
  Type: Integer
  Total Count: 7
  Non-Empty: 7
  Empty: 0
  Unique Values: 7
  Min: 3
  Max: 15
  Mean: 8.57
  Median: 8.00
  Std Dev: 3.81
  Q1: 6.00
  Q3: 11.00
```

#### CSV File with Data Quality Warnings
```
=== CSV Analysis Issues ===

⚠️  3 Warnings - Analysis completed with notes

WARNINGS:
⚠️  WARNING (Line 0): Column 'ID' contains mixed data types (text and numbers)
    → Suggestion: Consider separating different data types into different columns or cleaning data to be consistent

⚠️  WARNING (Line 4): Extra columns - Expected 4, found 5
    → Suggestion: Remove extra columns or check for unescaped commas

⚠️  WARNING (Line 5): Missing columns - Expected 4, found 2
    → Suggestion: Add missing commas or values

=== CSV Quick Statistics ===

File: mixed-data.csv
Rows: 6
Columns: 5
Has Headers: Yes

=== Column Statistics ===

Column: ID
  Type: Mixed
  Total Count: 6
  Non-Empty: 6
  Empty: 0
  Unique Values: 6
```

#### CSV File with Critical Errors
```
=== CSV Analysis Issues ===

❌ 1 Critical Error Found - Analysis stopped

CRITICAL ERRORS:
❌ CRITICAL (Line 15, Column 3): Unclosed quote in field
    → Suggestion: Add closing quote or escape internal quotes with double quotes

Error: Failed to analyze the CSV file.
```

#### Export with Automatic Filename Confirmation
```
=== CSV Quick Statistics ===
[... analysis output ...]

Output file already exists: /path/to/data.json
Replace existing file? (y/N): y
Output file created successfully: /path/to/data.json
```

### Export Format Examples

#### JSON Export with Issues
```json
{
  "dataset": {
    "file_path": "/path/to/data.csv",
    "total_rows": 6,
    "total_columns": 5,
    "has_headers": true
  },
  "issues": {
    "has_issues": true,
    "critical_error_count": 0,
    "warning_count": 2,
    "details": [
      {
        "severity": "warning",
        "line_number": 0,
        "column_index": 0,
        "message": "Column 'ID' contains mixed data types (text and numbers)",
        "suggestion": "Consider separating different data types into different columns"
      }
    ]
  },
  "columns": {
    "ID": {
      "type": "Mixed",
      "total_count": 6,
      "unique_count": 6
    }
  }
}
```

#### Markdown Export with Issues
```markdown
# CSV Quick Statistics

## Dataset Overview
- **File**: `/path/to/data.csv`
- **Rows**: 6
- **Columns**: 5
- **Has Headers**: Yes

## Data Quality Issues

⚠️ **2 Warnings** - Analysis completed with notes

### Warnings
- ⚠️ **WARNING (Line 0)**: Column 'ID' contains mixed data types (text and numbers)
  - *Suggestion*: Consider separating different data types into different columns

## Column Statistics

### ID
| Statistic | Value |
|-----------|-------|
| Type | Mixed |
| Total Count | 6 |
```

## Development Status

✅ **Development Complete** - All core features have been implemented and thoroughly tested.

## System Requirements

- Compatible with modern desktop operating systems
- Sufficient memory to handle CSV files up to 50MB
- No external dependencies required

---

**CSVQuickStats** - Fast, reliable CSV analysis from the command line. Perfect for data analysts, developers, and anyone working with CSV data.