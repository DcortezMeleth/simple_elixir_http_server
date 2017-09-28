defmodule Validators do

  @doc """
  Validates request against set of conditions in form of functions defined in this module.
  """
  def valid?(http_method, headers, body) do 
    [&validate_host_header/3, &validate_content_length/3]
    |> Enum.reduce(true, &(&1.(http_method, headers, body) and &2))
  end

  defp validate_host_header(_, %{:'Host' => _}, _), do: true
  defp validate_host_header(_, _, _), do: false

  defp validate_content_length(:POST, %{:'Content-Length' => _}, _), do: true
  defp validate_content_length(:POST, _, _), do: false
  defp validate_content_length(:PUT, %{:'Content-Length' => _}, _), do: true
  defp validate_content_length(:PUT, _, _), do: false
  defp validate_content_length(_, _, _), do: true

end
