defmodule Issues.CLI do
  @default_count 4

  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generating a
  table of the last _n_ issues in a github project
  """

  @doc """
  The main functionality of this application
  """
  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help.

  Otherwise it is a github user name, project name, and (optionally)
  the number of entries to format.

  Return a tuple of `{ user, project, count }`, or `:help` if help was given.
  """

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean],
                                     aliases: [ h: :help ])

    case parse do

    { [ help: true ], _, _ }
      -> :help

    { _, [ user, project, count ], _ }
      -> { user, project, String.to_integer(count) }

    { _, [ user, project ], _ }
      -> { user, project, @default_count }

    _ -> :help

    end
  end

  @doc """
  Process the parsed commandline options
  """
  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [ count | #{@default_count} ]
    """
    System.halt(0)
  end

  def process({user, project, count}) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response
    |> convert_to_list_of_maps
    |> sort_into_ascending_order
    |> Enum.take(count)
    |> Issues.TableFormatter.format_table_for_columns(["number", "created_at", "title"])
    |> IO.puts
  end

  defp decode_response({:ok, body}), do: body

  defp decode_response({:error, error}) do
    { _, message } = List.keyfind(error, "message", 0)
    IO.puts "Error fetching from Github: #{message}"
    System.halt(2)
  end

  def convert_to_list_of_maps(list) do
    list
    |> Enum.map(&Enum.into(&1, Map.new))
  end

  @doc """
  Sort a map by its created_at key

  ## Examples

      iex> Issues.CLI.sort_into_ascending_order([
      ...>   %{ "created_at" => "2014-01-23T23:31:32Z" },
      ...>   %{ "created_at" => "2014-03-29T16:42:38Z" },
      ...>   %{ "created_at" => "2014-01-23T23:14:26Z" }
      ...> ])
      [%{"created_at" => "2014-01-23T23:14:26Z"},
       %{"created_at" => "2014-01-23T23:31:32Z"},
       %{"created_at" => "2014-03-29T16:42:38Z"}]
  """
  def sort_into_ascending_order(list_of_issues) do
    Enum.sort list_of_issues,
      fn i1, i2 -> i1["created_at"] <= i2["created_at"] end
  end
end
