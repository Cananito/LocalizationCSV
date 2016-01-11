# LocalizationCSV

OS X app to generate CSV files from a project’s NSLocalizedStrings and IB files, and backwards.

## Requirements

* OS X 10.10

## Usage Instructions

Start by downloading the [latest release](https://github.com/Cananito/LocalizationCSV/releases).

### Generate CSVs

The first tab takes care of generating a set of CSV files based on the existing `NSLocalizedString`s and localized IB files.

The language columns in each CSV is determined based on the enabled locales for the project and IB files.

<img src="https://raw.githubusercontent.com/Cananito/LocalizationCSV/master/Assets/Screenshots/ToCSVs.png" />

You should point the first text field to the root of your project. The second text field indicates where it’ll create a new folder with the generated CSVs.

### Update Strings Files

The second tab takes care of updating existing `.strings` files out of existing CSVs (must’ve been created by this app).

<img src="https://raw.githubusercontent.com/Cananito/LocalizationCSV/master/Assets/Screenshots/FromCSVs.png" />

You should point the first text field to the folder containing the CSV files. You should point the second text field to the root of your project.

### Generate Localized JSONs

The third tab can create a localized set of JSON files out of an individual CSV file.

<img src="https://raw.githubusercontent.com/Cananito/LocalizationCSV/master/Assets/Screenshots/ToJSONs.png" />

You should point the first text field to the CSV file. The second text field indicates where it’ll create a new folder with the generated localized JSON files.
