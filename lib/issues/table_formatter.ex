defmodule Issues.TableFormatter do
  def format_table_for_columns(rows, header) do
    max_length = calculate_max_length(rows, header)
    [ print_header(header, max_length), print_seperator(max_length) | print_rows(rows, header, max_length) ]
    |> Enum.join("\n")
  end

  defp calculate_max_length(_, []), do: []

  defp calculate_max_length(rows, [header | headers]) do
    [ max_for_column(header, String.length(header), rows) | calculate_max_length(rows, headers) ]
  end

  defp max_for_column(_, max, []), do: max

  defp max_for_column(header_name, max, [row | rows]) do
    %{ ^header_name => val } = row
    len = String.length(to_string(val))
    max_for_column(header_name, Enum.max([ max, len ]), rows)
  end

  defp print_header(header, max_length) do
    Enum.zip(header, max_length)
    |> Enum.map(&ljust/1)
    |> Enum.join(" | ")
  end

  defp print_seperator(max_length) do
    max_length
    |> Enum.map(&String.duplicate("-", &1))
    |> Enum.join("-+-")
  end

  defp ljust({header, length}) do
    String.ljust(header, length)
  end

  defp print_rows([], _, _), do: []

  defp print_rows([row | rest], header, max_length) do
    [ print_row(row, header, max_length) |> Enum.join(" | ") | print_rows(rest, header, max_length)]
  end

  defp print_row(_, [], []), do: []

  defp print_row(row, [h | hs], [m | ms]) do
    { :ok, value } = Map.fetch(row, h)
    [ to_string(value) |> String.ljust(m) | print_row(row, hs, ms) ]
  end
end
