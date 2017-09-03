defmodule MessageHandler do
  
  def handle_msg({:error, reason}, socket) do
    IO.puts 'Error while receiving message from socker. Error reason: #{reason}'
    :gen_tcp.close(socket)
    # handle error and close kill process
  end

  #Handler for HTTP 1.1 GET method.
  #This method receives request and parses it.
  def handle_msg({:ok, {:http_request, :GET, {:abs_path, abs_path}, {1,1}}}, socket) do
    IO.puts 'Parsing HTTP 1.1 GET request...'
    IO.puts 'Path: #{abs_path}'
    
    {path, params} = abs_path |> to_string |> PathParser.parse_path()
    IO.puts "Request path params:"
    IO.inspect params
    IO.puts "Splited path:"
    IO.inspect path

    headers = HeaderParser.get_headers(socket)
    IO.inspect headers

    # send response
  end

  
  #Handler for HTTP 1.1 POST method.
  #This method receives request and parses it.
  def handle_msg({:ok, {:http_request, :POST, {:abs_path, abs_path}, {1,1}}}, socket) do
    IO.puts 'Parsing HTTP 1.1 POST request...'
    IO.puts 'Path: #{abs_path}'
    
    {path, params} = abs_path |> to_string |> PathParser.parse_path()
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

end
