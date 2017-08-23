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
    |> handle_response()
  end

  defp handle_response({:error, reason}) do
    IO.puts 'Error while reading from socket. Reason: #{reason}'
  end

  defp handle_response({:ok, data}) do
    data
    |> handle_successful_response()
  end

  defp handle_successful_response({:http_request, method, {:abs_path, path}, {http_version}}) do
    IO.puts 'Request START'
    IO.puts 'Method: #{method}'
    IO.puts 'Path: #{path}'
    {major, minor} = http_version
    IO.puts 'Http version: #{major}.#{minor}'
  end

  defp handle_successful_response({:http_header, sth, header_name, sth2, header_value}) do
    IO.puts 'Header'
    IO.puts 'Header name: #{header_name}'
    IO.puts 'Header value: #{header_value}'
    IO.puts 'Sth: #{sth}'
    IO.puts 'Sth2: #{sth2}'
    IO.puts ''
  end

  defp handle_successful_response(:http_eoh) do
    IO.puts 'Request END'
    IO.puts ''
  end
end
