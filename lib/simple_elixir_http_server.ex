defmodule HTTPServer do
  @port 8888

  def start do
    IO.puts 'Starting server...'
    :gen_tcp.listen(@port, [:binary, packet: :http, active: false, reuseaddr: true])
    |> handle_listen_response
  end

  defp handle_listen_response({:error, reason}) do
    IO.puts 'Error connectiong to #{@port}'
    IO.puts reason
  end

  defp handle_listen_response({:ok, socket}) do
    IO.puts 'Accepting connections on port #{@port}'
    loop_accept(socket)
  end

  defp loop_accept(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    work(client)
    loop_accept(socket)
  end

  defp work(client_socket) do
    client_socket
    |> read_msg()

    send_response(client_socket)
    #work(client_socket)
  end

  defp read_msg(client_socket) do
    :gen_tcp.recv(client_socket, 0)
    |> MessageHandler.handle_msg(client_socket)
  end

  defp send_response(client_socket) do
    http_version = 'HTTP/1.1'
    http_status = '200 OK\r\n'
    server = 'Server: SimpleElixirHttpServer/0.0.1\r\n'
    connection_header = 'Connection: close\r\n'
    content_type_header = 'Content-type: text/html;\r\n'
    charset_header = 'charset=UTF-8\r\n'
    cache_header = 'Cache-Control: no-cache\r\n'
    date = current_date()
    content = "<html><body>Hello World!</body></html>"
    c_length = String.length(content)
    content_length = 'Content-Length: #{c_length}\r\n'
    response = '#{http_version} #{http_status}Date: #{date}\r\n#{server}Last-Modified: #{date}\r\n#{content_length}#{connection_header}#{content_type_header}#{cache_header}\r\n#{content}\r\n'
    IO.puts response
    :inet.setopts(client_socket, [packet: :http])
    res = {:http_respone, {1,1}, response}
    client_socket
    |> :gen_tcp.send(response)
    #|> :gen_tcp.send([http_version, '200', "\r\n", [date, connection_header, content_type_header, charset_header, cache_header], "\r\n", <<>>])
  end

  defp current_date() do
    {:ok, date} = Timex.now("Europe/Warsaw")
                  |> Timex.format("{RFC1123}")
    date
  end
end
