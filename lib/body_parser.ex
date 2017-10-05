defmodule BodyParser do
  
  def get_body(%{:"Content-Length" => lenght}, socket) do
    len = List.to_integer(lenght)
    :inet.setopts(socket, [packet: :raw])
    :gen_tcp.recv(socket, len)
    |> handle_body()
  end

  def get_body(_, _) do
    ''
  end

  defp handle_body({:ok, body}) do
    IO.inspect body
    body
  end

  defp handle_body({:error, reason}) do
    IO.puts 'Error while reading message body! Reason: #{reason}'
  end

end
