defmodule Validators do

  @doc """
  Validates request against set of conditions in form of functions defined in this module.
  """
  def valid?(request) do 
    [&validate_host_header/1, &validate_content_length/1]
    |> Enumerable.reduce({:cont, true}, fn x,_ -> x.(request) end)
  end

  defp validate_host_header(%Request{headers: %{:'Host' => _}}), do: {:cont, true}
  defp validate_host_header(_), do: {:halt, %Response{http_status: 400, body: "<html><body>400 Bad Request</body></html>"}}

  defp validate_content_length(%Request{http_method: :POST, headers: %{:'Content-Length' => _}}), do: {:cont, true}
  defp validate_content_length(%Request{http_method: :POST}), do: {:halt, %Response{http_status: 411, body: "<html><body>411 Length Required</body></html>"}}
  defp validate_content_length(%Request{http_method: :PUT, headers: %{:'Content-Length' => _}}), do: {:cont, true}
  defp validate_content_length(%Request{http_method: :PUT}), do: {:halt, %Response{http_status: 411, body: "<html><body>411 Length Required</body></html>"}}
  defp validate_content_length(_), do: {:cont, true}

end
