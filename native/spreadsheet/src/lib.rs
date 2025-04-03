use calamine::{
    open_workbook_auto, open_workbook_auto_from_rs, Data, Reader,
};
use rustler::{Binary, NifTaggedEnum};
use std::io::Cursor;

#[rustler::nif]
fn sheet_names_from_binary(content: Binary) -> Result<Vec<String>, String> {
    let cursor = Cursor::new(content.as_slice());

    open_workbook_auto_from_rs(cursor)
        .map(|workbook| workbook.sheet_names().to_owned())
        .map_err(|e| e.to_string())
}

#[rustler::nif]
fn sheet_names_from_path(path: &str) -> Result<Vec<String>, String> {
    open_workbook_auto(path)
        .map(|workbook| workbook.sheet_names().to_owned())
        .map_err(|e| e.to_string())
}

#[rustler::nif]
fn parse_from_path(
    path: &str,
    sheet_name: &str,
) -> Result<Vec<Vec<ColumnData>>, String> {
    let result = open_workbook_auto(path);

    match result {
        Ok(mut workbook) => workbook
            .worksheet_range(sheet_name)
            .map_err(|e| e.to_string())
            .map(|range| {
                range
                    .rows()
                    .map(|row| row.iter().map(extract_column).collect::<Vec<_>>())
                    .collect()
            }),
        Err(e) => Err(e.to_string()),
    }
}

#[rustler::nif]
fn parse_from_binary(
    content: Binary,
    sheet_name: &str,
) -> Result<Vec<Vec<ColumnData>>, String> {
    let result = open_workbook_auto_from_rs(Cursor::new(content.as_slice()));

    match result {
        Ok(mut workbook) => workbook
            .worksheet_range(sheet_name)
            .map_err(|e| e.to_string())
            .map(|range| {
                range
                    .rows()
                    .map(|row| row.iter().map(extract_column).collect::<Vec<_>>())
                    .collect()
            }),
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
