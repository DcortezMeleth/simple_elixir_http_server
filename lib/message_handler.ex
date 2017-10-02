defmodule MessageHandler do
  
  def handle_msg({:error, reason}, socket) do
    IO.puts 'Error while receiving message from socket. Error reason: #{reason}'
    :gen_tcp.close(socket)
    # handle error and close kill process
  end

  #Handler for HTTP 1.1 method.
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
    request = %Request{http_method: http_method, headers: headers, path: path, body: body, params: params}

    case request |> Validators.valid? do
      true ->
        request
        |> Handlers.handle
        |> send_response(socket)
      false ->
        {400, %{}, 'Bad request!'}
        |> send_response(socket)
    end
  end

  defp send_response(request, client_socket) do
    IO.puts 'Sending response ...'
    http_version = 'HTTP/1.1'
    http_status = Utils.HttpStatuses.get_status_by_code(request.http_status)
    headers_string = request.headers
                     |> Utils.HeaderUtils.merge_base_headers
                     |> Utils.HeaderUtils.headers_to_string
              #String.length(request.body)
              #|> get_base_headers_as_string(request.headers)
    response = '#{http_version} #{http_status}#{headers_string}\r\n#{request.body}\r\n'
    IO.puts response
    :inet.setopts(client_socket, [packet: :http])
    res = {:http_respone, {1,1}, response}
    client_socket
    |> :gen_tcp.send(response)
  end
end
