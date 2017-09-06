defmodule MessageHandler do
  
  def handle_msg({:error, reason}, socket) do
    IO.puts 'Error while receiving message from socket. Error reason: #{reason}'
    :gen_tcp.close(socket)
    # handle error and close kill process
  end

  #Handler for HTTP 1.1 GET method.
  #This method receives request and parses it.
  def handle_msg({:ok, {:http_request, :GET, {:abs_path, abs_path}, {1,1}}}, socket) do
    IO.puts 'Parsing HTTP 1.1 GET request...'
    IO.puts 'Path: #{abs_path}'
    
    {path, params} = abs_path |> to_string |> PathParser.parse_path
    IO.puts "Request path params:"
    IO.inspect params
    IO.puts "Splited path:"
    IO.inspect path

    headers = HeaderParser.get_headers(socket)
    IO.inspect headers

    # send response
    send_response(socket)
  end

  #Handler for HTTP 1.1 POST method.
  #This method receives request and parses it.
  def handle_msg({:ok, {:http_request, :POST, {:abs_path, abs_path}, {1,1}}}, socket) do
    IO.puts 'Parsing HTTP 1.1 POST request...'
    IO.puts 'Path: #{abs_path}'
    
    {path, params} = abs_path |> to_string |> PathParser.parse_path
    IO.puts "Request path params:"
    IO.inspect params
    IO.puts "Splited path:"
    IO.inspect path

    headers = HeaderParser.get_headers(socket)
    IO.inspect headers

    %{"Content-Length": len} = headers
    body = len
           |> List.to_integer()
           |> BodyParser.get_body(socket)
  end

  defp send_response(client_socket) do
    http_version = 'HTTP/1.1'
    http_status = '200 OK\r\n'
    content = "<html><body>Hello World!</body></html>"
    headers = String.length(content)
              |> get_base_headers_as_string()
    response = '#{http_version} #{http_status}#{headers}\r\n#{content}\r\n'
    IO.puts response
    :inet.setopts(client_socket, [packet: :http])
    res = {:http_respone, {1,1}, response}
    client_socket
    |> :gen_tcp.send(response)
  end

  defp current_date() do
    {:ok, date} = Timex.now("Europe/Warsaw")
                  |> Timex.format("{RFC1123}")
    date
  end

  defp get_base_headers_as_string(content_length) do
    date = current_date()
    ['Date: #{date}\r\n', 'Server: SimpleElixirHttpServer/0.0.1\r\n', 'Last-Modified: #{date}\r\n', 'Content-Length: #{content_length}\r\n', 'Connection: close\r\n', 'Content-type: text/html;\r\n', 'Cache-Control: no-cache\r\n']
    |> Enum.join("")
  end
end
