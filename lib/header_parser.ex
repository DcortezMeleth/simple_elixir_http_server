defmodule HeaderParser do
  
  def get_headers(socket) do
    :gen_tcp.recv(socket, 0)
    |> handle_header(socket)
  end

  defp handle_header({:error, reason}, socket) do
    IO.puts 'Error while receiving message header part! Reason: #{reason}'
    :gen_tcp.close(socket)
    # handle errorand close process
  end

  defp handle_header({:ok, {:http_header, _, name, _, value}}, socket) do
    :gen_tcp.recv(socket, 0)
    |> handle_header(socket)
    |> Map.merge(%{name => value})
  end

  defp handle_header({:ok, :http_eoh}, _) do
    %{}
  end

end
