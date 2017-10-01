defmodule Handlers do

  def handle(request = %Request{http_method: :GET, headers: %{:"If-Modified-Since" => since}}) do
    modified_since?(request.path, since)
    |> case do
      # File modified since `If-Modified-Since`, we handle request as normal
      false -> 
        new_headers = Map.delete(request.headers, :"If-Modified-Since")
        Map.put(request, :headers, new_headers)
        |> handle
      # File unmodified, returning 304
      true -> 
        %Response{http_status: 304, body: "<html><body>304 Not Modifed</body></html>"}
    end
  end
  
  def handle(request = %Request{headers: %{:"If-Unmodified-Since" => since}}) do
    modified_since?(request.path, since)    
    |> case do
      # File unmodified since `If-Modified-Since`, we handle request as normal
      true -> 
        new_headers = Map.delete(request.headers, :"If-Unmodified-Since")
        Map.put(request, :headers, new_headers)
        |> handle
        # File modified, returning 304
      false -> 
        %Response{http_status: 412, body: "<html><body>412 Precondition Failed!</body></html>"}
    end
  end

  def handle(%Request{http_method: :GET, path: path}) do
    file_path = path 
                |> Utils.FileUtils.get_file_path 
    case file_path |> File.read do
      {:ok, content} ->
        mdate = file_path
        |> Utils.FileUtils.get_file_modification_date
        |> Timex.format!("{RFC1123}")
        %Response{http_status: 200, headers: %{'Last-Modified' => mdate}, body: content}
      {:error, :eaccess} -> 
        %Response{http_status: 401, body: "<html><body>401 Unauthorized</body></html>"}
      {:error, :enoent} -> 
        %Response{http_status: 404, body: "<html><body>404 Not Found</body></html>"}
      {:error, :enomem} -> 
        %Response{http_status: 500, body: "<html><body>500 File too large</body></html>"}
      {:error, _} -> 
        %Response{http_status: 400, body: "<html><body>400 Bad Request</body></html>"}
    end
  end
  
  def handle(request) do
    IO.puts 'Default method'
    IO.inspect request.http_method
    IO.inspect request.path
    IO.inspect request.headers
    IO.inspect request.params
    IO.inspect request.body
    %Response{http_status: 200, body: "<html><body>SimpleHTTPServer/0.0.1!</body></html>"}
  end

  defp modified_since?(file_path, since) do
    since_date = since
                  |> Utils.DateUtils.parse_date
    file_path
    |> Utils.FileUtils.get_file_path
    |> Utils.FileUtils.get_file_modification_date
    |> Timex.before?(since_date) 
  end
  
end
