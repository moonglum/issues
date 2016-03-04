defmodule TableFormatterTest do
  use ExUnit.Case
  doctest Issues

  import Issues.TableFormatter, only: [ format_table_for_columns: 2 ]

  test "format an example table" do
    issues = [
      %{ "number" => 13, "created_at" => "2014-01-24T09:38:59Z", "title" => "Big issue" },
      %{ "number" => 14, "created_at" => "2014-02-24T09:38:59Z", "title" => "Another issue" },
    ]

    header = ["number", "created_at", "title"]

    expected_output = String.strip("""
    number | created_at           | title        
    -------+----------------------+--------------
    13     | 2014-01-24T09:38:59Z | Big issue    
    14     | 2014-02-24T09:38:59Z | Another issue
    """)
    actual_output = format_table_for_columns(issues, header)

    assert actual_output == expected_output
  end
end
