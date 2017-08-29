defmodule PathParser do

  @doc """
  Parses absolute path and returns touple with list of path elements as first element
  and map of query parameters as second element.
  """
  def parse_path(abs_path) do
    case String.split(abs_path, "?", trim: :true) do
      [path, params] ->
        params_map = String.split(params, "&", trim: :true)
                     |> parse_params()
        splited_path = String.split(path, "/", trim: :true)
        {splited_path, params_map}
      [path] ->
        splited_path = String.split(path, "/", trim: :true)
        {splited_path, %{}}
    end
  end

  """
  Gets list of parameters in form of 'a=x' and parses them.
  Returns a map of parameters like {param_name => param_value}
  """
  defp parse_params([param|tail]) do
    [name, value] = String.split(param, "=", trim: :true) 
    parse_params(tail)
    |> Map.merge(%{name => value})
  end
  
  """
  Gets list of parameters in form of 'a=x' and parses them.
  Returns a map of parameters like {param_name => param_value}
  """
  defp parse_params([]) do
    %{}
  end

end
