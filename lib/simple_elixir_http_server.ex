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

    work(client_socket)
  end

  defp read_msg(client_socket) do
    :gen_tcp.recv(client_socket, 0)
    |> handle_msg(client_socket)
  end

  defp handle_msg({:error, reason}, socket) do
    IO.puts 'Error while receiving message from socker. Error reason: #{reason}'
    :gen_tcp.close(socket)
    # handle error and close kill process
  end

  #Handler for HTTP 1.1 GET method.
  #This method receives request and parses it.
  defp handle_msg({:ok, {:http_request, :GET, {:abs_path, abs_path}, {1,1}}}, socket) do
    IO.puts 'Parsing HTTP 1.1 GET request...'
    IO.puts 'Path: #{abs_path}'
    
    {path, params} = abs_path |> to_string |> PathParser.parse_path()
    IO.puts "Request path params:"
    IO.inspect params
    IO.puts "Splited path:"
    IO.inspect path

    headers = get_headers(socket)
    IO.inspect headers

    # send response
  end

  
  #Handler for HTTP 1.1 POST method.
  #This method receives request and parses it.
  defp handle_msg({:ok, {:http_request, :POST, {:abs_path, abs_path}, {1,1}}}, socket) do
    IO.puts 'Parsing HTTP 1.1 POST request...'
    IO.puts 'Path: #{abs_path}'
    
    {path, params} = abs_path |> to_string |> PathParser.parse_path()
    IO.puts "Request path params:"
    IO.inspect params
    IO.puts "Splited path:"
    IO.inspect path

    headers = get_headers(socket)
    IO.inspect headers

    %{"Content-Length": len} = headers
    body = len
           |> List.to_integer()
           |> get_body(socket)
  end

  defp get_body(len, socket) do
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

  defp get_headers(socket) do
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
