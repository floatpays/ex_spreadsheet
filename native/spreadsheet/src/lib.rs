use calamine::{open_workbook_auto, open_workbook_auto_from_rs, Data, Reader, SheetVisible};
use rustler::{Binary, NifTaggedEnum};
use std::io::Cursor;

fn filter_sheet_names_by_visibility(
    sheet_names: &[String],
    sheets_metadata: &[calamine::Sheet],
    show_hidden: bool,
) -> Vec<String> {
    if show_hidden {
        sheet_names.to_owned()
    } else {
        // Filter out hidden sheets using metadata
        sheets_metadata
            .iter()
            .filter(|sheet| sheet.visible == SheetVisible::Visible)
            .map(|sheet| sheet.name.clone())
            .collect()
    }
}

#[rustler::nif]
fn sheet_names_from_binary(content: Binary, show_hidden: bool) -> Result<Vec<String>, String> {
    let cursor = Cursor::new(content.as_slice());

    match open_workbook_auto_from_rs(cursor) {
        Ok(workbook) => {
            let sheet_names = workbook.sheet_names();
            let sheets_metadata = workbook.sheets_metadata();
            Ok(filter_sheet_names_by_visibility(
                &sheet_names,
                sheets_metadata,
                show_hidden,
            ))
        }
        Err(e) => Err(e.to_string()),
    }
}

#[rustler::nif]
fn sheet_names_from_path(path: &str, show_hidden: bool) -> Result<Vec<String>, String> {
    match open_workbook_auto(path) {
        Ok(workbook) => {
            let sheet_names = workbook.sheet_names();
            let sheets_metadata = workbook.sheets_metadata();
            Ok(filter_sheet_names_by_visibility(
                &sheet_names,
                sheets_metadata,
                show_hidden,
            ))
        }
        Err(e) => Err(e.to_string()),
    }
}

#[rustler::nif]
fn parse_from_path(path: &str, sheet_name: &str) -> Result<Vec<Vec<ColumnData>>, String> {
    let result = open_workbook_auto(path);

    match result {
        Ok(mut workbook) => {
            match workbook.worksheet_range(sheet_name) {
                Ok(range) => Ok(range
                    .rows()
                    .map(|row| row.iter().map(extract_column).collect::<Vec<_>>())
                    .collect()),
                Err(_e) => {
                    // We don't want to return an error for invalid columns,
                    // so let us just ignore them rather than failing for the
                    // entire file. In the future we might want to show this
                    // as a warning.
                    Ok(Vec::new())
                }
            }
        }
        Err(e) => Err(e.to_string()),
    }
}

#[rustler::nif]
fn parse_from_binary(content: Binary, sheet_name: &str) -> Result<Vec<Vec<ColumnData>>, String> {
    let result = open_workbook_auto_from_rs(Cursor::new(content.as_slice()));

    match result {
        Ok(mut workbook) => {
            match workbook.worksheet_range(sheet_name) {
                Ok(range) => Ok(range
                    .rows()
                    .map(|row| row.iter().map(extract_column).collect::<Vec<_>>())
                    .collect()),
                Err(_e) => {
                    // We don't want to return an error for invalid columns,
                    // so let us just ignore them rather than failing for the
                    // entire file. In the future we might want to show this
                    // as a warning.
                    Ok(Vec::new())
                }
            }
        }
        Err(e) => Err(e.to_string()),
    }
}

#[derive(NifTaggedEnum)]
enum ColumnData {
    Int(i64),
    Float(f64),
    String(String),
    Bool(bool),
    DateTime(String),
    DateTimeIso(String),
    DurationIso(String),
    Error(String),
    Empty,
}

fn extract_column(cell: &Data) -> ColumnData {
    match cell {
        Data::Int(val) => ColumnData::Int(*val),
        Data::Float(val) => ColumnData::Float(*val),
        Data::String(val) => ColumnData::String(val.to_string()),
        Data::Bool(val) => ColumnData::Bool(*val),
        Data::DateTime(val) => {
            if let Some(ndt) = val.as_datetime() {
                ColumnData::DateTime(ndt.format("%Y-%m-%dT%H:%M:%S").to_string())
            } else {
                ColumnData::DateTime("Invalid DateTime".to_string())
            }
        }
        Data::DateTimeIso(val) => ColumnData::DateTimeIso(val.to_string()),
        Data::DurationIso(val) => ColumnData::DurationIso(val.to_string()),
        Data::Error(val) => ColumnData::Error(val.to_string()),
        Data::Empty => ColumnData::Empty,
    }
}

rustler::init!("Elixir.Spreadsheet.Calamine");
