defmodule DocTest do
  use ExUnit.Case
  doctest Issues.TableFormatter
  doctest Issues.CLI
  doctest Issues.GithubIssues
end
