defmodule SpreadsheetTest do
  use ExUnit.Case

  @base_path Path.join(__DIR__, "/files")

  describe "sheet_names/1" do
    test "gets the sheet_names" do
      content = File.read!(Path.join(@base_path, "test_file_1.xlsx"))

      assert Spreadsheet.sheet_names_from_binary(content) == {:ok, ["Sheet1"]}
    end

    test "gets the sheet_names from a path" do
      path = Path.join(@base_path, "test_file_1.xlsx")

      assert Spreadsheet.sheet_names(path) == {:ok, ["Sheet1"]}
    end

    test "gets the sheet_names from a path for xls" do
      path = Path.join(@base_path, "test_file_1.xls")

      assert Spreadsheet.sheet_names(path) == {:ok, ["Sheet1"]}
    end

    test "gets the sheet_names from a path for ods" do
      path = Path.join(@base_path, "test_file_1.ods")

      assert Spreadsheet.sheet_names(path) == {:ok, ["Sheet1"]}
    end

    test "reads xls files from content" do
      content = File.read!(Path.join(@base_path, "test_file_1.xls"))

      assert Spreadsheet.sheet_names_from_binary(content) ==
               {:ok, ["Sheet1"]}
    end

    test "reads ods files from content" do
      content = File.read!(Path.join(@base_path, "test_file_1.ods"))

      assert Spreadsheet.sheet_names_from_binary(content) ==
               {:ok, ["Sheet1"]}
    end
  end

  describe "parse/2" do
    test "parses the content" do
      content = File.read!(Path.join(@base_path, "test_file_1.xlsx"))
      sheet_name = "Sheet1"

      {:ok, [header | rows]} =
        Spreadsheet.parse_from_binary(content, sheet_name)

      assert header == ["Dates", "Numbers", "Percentages", "Strings"]

      assert rows == [
               [~N[2024-12-12 00:00:00], 1234.0, 0.12, "Foobar"],
               [~N[1993-11-21 00:00:00], "00012345", 0.1212, nil],
               [~N[1987-05-08 00:00:00], 1122.0, "12", nil],
               [~N[1994-05-22 00:00:00], "12,12", 12.0, nil],
               ["2024-01-01", 11.12, "33.12%", "123"],
               [~N[1987-05-08 20:10:12], nil, nil, nil],
               [~N[1987-05-08 20:10:12], nil, nil, nil]
             ]
    end

    test "parses the path for xls" do
      path = Path.join(@base_path, "test_file_1.xls")
      sheet_name = "Sheet1"

      {:ok, [header | rows]} = Spreadsheet.parse(path, sheet_name)

      assert header == ["Dates", "Numbers", "Percentages", "Strings"]

      assert rows == [
               [~N[2024-12-12 00:00:00], 1234, 0.12, "Foobar"],
               [
                 ~N[1993-11-21 00:00:00],
                 "00012345",
                 0.12119999999999999,
                 nil
               ],
               [~N[1987-05-08 00:00:00], 1122, "12", nil],
               [~N[1994-05-22 00:00:00], "12,12", 12, nil],
               ["2024-01-01", 11.12, "33.12%", "123"],
               [~N[1987-05-08 20:10:12], nil, nil, nil],
               [~N[1987-05-08 20:10:12], nil, nil, nil]
             ]
    end

    test "parses the content from a path" do
      path = Path.join(@base_path, "test_file_1.xlsx")
      sheet_name = "Sheet1"

      assert {:ok, _} = Spreadsheet.parse(path, sheet_name)
    end

    test "reads xls files" do
      content = File.read!(Path.join(@base_path, "test_file_1.xls"))

      assert Spreadsheet.parse_from_binary(content, "Sheet1") == {
               :ok,
               [
                 ["Dates", "Numbers", "Percentages", "Strings"],
                 [~N[2024-12-12 00:00:00], 1234, 0.12, "Foobar"],
                 [
                   ~N[1993-11-21 00:00:00],
                   "00012345",
                   0.12119999999999999,
                   nil
                 ],
                 [~N[1987-05-08 00:00:00], 1122, "12", nil],
                 [~N[1994-05-22 00:00:00], "12,12", 12, nil],
                 ["2024-01-01", 11.12, "33.12%", "123"],
                 [~N[1987-05-08 20:10:12], nil, nil, nil],
                 [~N[1987-05-08 20:10:12], nil, nil, nil]
               ]
             }
    end

    test "reads ods files" do
      content = File.read!(Path.join(@base_path, "test_file_1.ods"))

      assert Spreadsheet.parse_from_binary(content, "Sheet1") ==
               {
                 :ok,
                 [
                   ["Dates", "Numbers", "Percentages", "Strings"],
                   ["2024-12-12", 1234.0, 0.12, "Foobar"],
                   ["1993-11-21", "00012345", 0.1212, nil],
                   ["1987-05-08", 1122.0, "12", nil],
                   ["1994-05-22", "12,12", 12.0, nil],
                   ["2024-01-01", 11.12, "33.12%", "123"],
                   ["1987-05-08T20:10:12", nil, nil, nil],
                   ["1987-05-08T20:10:12", nil, nil, nil]
                 ]
               }
    end
  end
end
