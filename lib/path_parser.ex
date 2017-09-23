defmodule PathParser do

  @doc ~S"""
  Parses absolute path and returns touple with list of path elements as first element
  and map of query parameters as second element.

  ## Examples

      iex> PathParser.parse_path("/path/to/resource")
      {["path", "to", "resource"], %{}}

      iex> PathParser.parse_path("https://host:port/path")
      {["path"], %{}}

      iex> PathParser.parse_path("/path?param=1&x=2")
      {["path"], %{"param" => "1", "x" => "2"}}
  """
  def parse_path(abs_path) do
    splited_path = abs_path
                   |> URI.parse
                   |> Map.get(:path)
                   |> String.split("/", trim: :true)

    params = abs_path
             |> URI.parse
             |> Map.get(:query)
             |> parse_params()

    {splited_path, params}
  end

  defp parse_params(query) when is_bitstring(query) do
    query
    |> URI.query_decoder
    |> Enum.into(%{})
  end
  
 defp parse_params(query) do
    %{}
  end

end
