# Test Data Files

This directory contains various CSV files for testing the CSVQuickStats application.

## Valid CSV Files

### simple-sales.csv
- Basic sales data with numeric and text columns
- 7 rows of data with headers
- Tests: Date, Product, Quantity, Price, Revenue columns

### employee-data.csv
- Employee information dataset
- 10 rows of employee data
- Tests: Mixed data types (ID, Names, Departments, Salaries, Experience, Status)

### mixed-data.csv
- Product catalog with various data types
- 6 rows with complex descriptions
- Tests: Boolean values, quoted strings with commas, ratings

### large-dataset.csv
- Transaction data with 15 records
- Tests: Multiple currencies, timestamps, repeated customer IDs
- Simulates larger dataset processing

## Error Test Files

### missing-quotes.csv
- **Error**: Unquoted strings containing quotes
- Tests quote handling and parsing errors

### inconsistent-columns.csv
- **Error**: Rows with different numbers of columns
- Tests column count validation

### empty-fields.csv
- **Error**: Missing data in various fields
- Tests handling of empty/null values

### malformed-quotes.csv
- **Error**: Improperly escaped quotes within quoted strings
- Tests quote parsing edge cases

### no-headers.csv
- **Edge Case**: CSV without header row
- Tests header detection and default column naming

### mixed-line-endings.csv
- **Edge Case**: Different line ending formats
- Tests cross-platform compatibility

### empty-file.csv
- **Edge Case**: Completely empty file
- Tests file validation

### only-headers.csv
- **Edge Case**: File with headers but no data rows
- Tests empty dataset handling

## Usage

These files are designed to test various aspects of the CSV parsing and analysis functionality:

1. **Basic functionality**: Use valid files to test core features
2. **Error handling**: Use error files to verify graceful error handling
3. **Edge cases**: Use edge case files to ensure robust parsing
4. **Performance**: Use large-dataset.csv to test performance optimization