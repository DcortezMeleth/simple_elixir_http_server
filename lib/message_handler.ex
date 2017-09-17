defmodule MessageHandler do
  
  def handle_msg({:error, reason}, socket) do
    IO.puts 'Error while receiving message from socket. Error reason: #{reason}'
    :gen_tcp.close(socket)
    # handle error and close kill process
  end

  #Handler for HTTP 1.1 GET method.
  #This method receives request and parses it.
  def handle_msg({:ok, {:http_request, http_method, {:abs_path, abs_path}, {1,1}}}, socket) do
    IO.puts 'Parsing HTTP 1.1 #{http_method} request...'
    IO.puts 'Path: #{abs_path}'
    
    {path, params} = abs_path |> to_string |> PathParser.parse_path
    IO.puts "Request path params:"
    IO.inspect params
    IO.puts "Splited path:"
    IO.inspect path

    headers = HeaderParser.get_headers(socket)
    IO.inspect headers

    body = BodyParser.get_body(headers, socket)

    Handlers.handle(http_method, path, params, body)
    |> send_response(socket)
  end

  defp send_response({status_code, content}, client_socket) do
    IO.puts 'Sending response ...'
    http_version = 'HTTP/1.1'
    http_status = get_status_by_code(status_code)
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

  defp get_status_by_code(status_code) do
    statuses = %{200 => 'OK', 
      201 => 'Created', 
      202 => 'Accepted', 
      400 => 'Bad Request', 
      401 => 'Unauthorized', 
      404 => 'Not Found', 
      500 => 'Internal Error'}
    '#{status_code} #{statuses[status_code]}\r\n'
  end
end
