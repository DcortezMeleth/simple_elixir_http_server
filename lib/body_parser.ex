defmodule BodyParser do
  
  def get_body(len, socket) do
    :inet.setopts(socket, [packet: :raw])
    :gen_tcp.recv(socket, len)
    |> handle_body()
  end

  defp handle_body({:ok, body}) do
    IO.inspect body
    body
  end

  defp handle_body({:error, reason}) do
    IO.puts 'Error while receiving message header part! Reason: #{reason}'
  end


end
