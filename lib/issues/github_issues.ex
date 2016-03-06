defmodule Issues.GithubIssues do
  @moduledoc """
  Fetches and parses the results from the Github API
  """

  require Logger

  @user_agent [ {"User-agent", "Elixir dave@pragprog.com"} ]
  @github_url Application.get_env(:issues, :github_url)

  @doc """
  Fetch and parse the API response from Github for the repository of the user `user` with
  the name `project`
  """
  def fetch(user, project) do
    Logger.info "Fetching user #{user}'s project #{project}"
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  @doc """
  Determines the Github API URI to get the list of issues for a given user and project

  ## Examples

      iex> Issues.GithubIssues.issues_url("moonglum", "dotfiles")
      "https://api.github.com/repos/moonglum/dotfiles/issues"
  """
  def issues_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  @doc """
  Interpret and parse the result from Github

  ### Examples

      iex> Issues.GithubIssues.handle_response({ :ok, %{ status_code: 200, body: "{ \\"a\\": 12 }" }})
      { :ok, %{ "a" => 12 } }

      iex> Issues.GithubIssues.handle_response({ :ok, %{ status_code: 404, body: "{ \\"error\\": \\"not found\\" }" }})
      { :error, %{ "error" => "not found" } }
  """
  def handle_response({ :ok, %{ status_code: 200, body: body}}) do
    Logger.info "Successful response"
    Logger.debug fn -> inspect(body) end
    { :ok, Poison.Parser.parse!(body) }
  end

  def handle_response({ _, %{ status_code: status, body: body}}) do
    Logger.error "Error #{status} returned"
    { :error, Poison.Parser.parse!(body) }
  end
end
