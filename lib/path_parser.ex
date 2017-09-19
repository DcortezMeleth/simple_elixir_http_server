defmodule PathParser do

  @doc """
  Parses absolute path and returns touple with list of path elements as first element
  and map of query parameters as second element.
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

  """
  Gets list of parameters in form of 'a=x' and parses them.
  Returns a map of parameters like {param_name => param_value}
  """
  defp parse_params(query) when is_bitstring(query) do
    query
    |> URI.query_decoder
    |> Enum.into(%{})
  end
  
  """
  Gets list of parameters in form of 'a=x' and parses them.
  Returns a map of parameters like {param_name => param_value}
  """
  defp parse_params(query) do
    %{}
  end

end
