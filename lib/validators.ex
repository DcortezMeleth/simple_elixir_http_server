defmodule Validators do

  @doc """
  Validates request against set of conditions in form of functions defined in this module.
  """
  def valid?(request) do 
    [&validate_host_header/1, &validate_content_length/1]
    |> Enum.reduce(true, &(&1.(request) and &2))
  end

  defp validate_host_header(%Request{headers: %{:'Host' => _}}), do: true
  defp validate_host_header(_), do: false

  defp validate_content_length(%Request{http_method: :POST, headers: %{:'Content-Length' => _}}), do: true
  defp validate_content_length(%Request{http_method: :POST}), do: false
  defp validate_content_length(%Request{http_method: :PUT, headers: %{:'Content-Length' => _}}), do: true
  defp validate_content_length(%Request{http_method: :PUT}), do: false
  defp validate_content_length(_), do: true

end
