defmodule HTTPServer do
  @port 8888

  def hello do
    :world
  end

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

  defp handle_msg({:ok, {:http_request, :GET, {:abs_path, abs_path}, {1,1}}}, socket) do
    IO.puts 'Parsing HTTP 1.1 GET request...'
    IO.puts 'Path: #{abs_path}'
    
    [path, params] = abs_path |> to_string |> parse_path()
    IO.puts "Request path params:"
    IO.inspect params
    IO.puts "Splited path:"
    IO.inspect path

    headers = %{}
    :gen_tcp.recv(socket, 0)
    |> handle_header(headers, socket)
  end

  defp parse_path(abs_path) do
    case String.split(abs_path, "?", trim: :true) do
      [path, params] ->
        params_map = String.split(params, "&", trim: :true)
                     |> parse_params()
        splited_path = String.split(path, "/", trim: :true)
        [splited_path, params_map]
      [path] ->
        splited_path = String.split(path, "/", trim: :true)
        [splited_path, %{}]
    end

  end

  defp parse_params([param|tail]) do
    [name, value] = String.split(param, "=", trim: :true) 
    Map.merge(%{name => value}, parse_params(tail))
  end

  defp parse_params([]) do
    %{}
  end

  defp handle_header({:error, reason}, _, socket) do
    IO.puts 'Error while receiving message header part!'
    :gen_tcp.close(socket)
    # handle errorand close process
  end

  defp handle_header({:ok, {:http_header, _, name, _, value}}, headers, socket) do
    Map.put(headers, name, value)
    IO.puts 'Header: #{name}\t Value: #{value}' 
    :gen_tcp.recv(socket, 0)
    |> handle_header(headers, socket)
  end

  defp handle_header({:ok, :http_eoh}, headers, _) do
    IO.puts 'No more headers'
    headers
  end
end
