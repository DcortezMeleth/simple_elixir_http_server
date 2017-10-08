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
        %Response{http_status: 304}
    end
  end
  
  def handle(request = %Request{headers: %{:"If-Unmodified-Since" => since}}) do
    modified_since?(request.path, since)    
    |> case do
      # File unmodified since `If-Umnodified-Since`, we handle request as normal
      true -> 
        new_headers = Map.delete(request.headers, :"If-Unmodified-Since")
        Map.put(request, :headers, new_headers)
        |> handle
        # File modified, returning 412
      false -> 
        %Response{http_status: 412, body: "<html><body>412!</body></html>"}
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

  def handle(%Request{http_method: :DELETE, path: path}) do
    path
    |> Utils.FileUtils.get_file_path
    |> File.rm
    |> case do
      :ok ->
        %Response{http_status: 204} 
      {:error, :eaccess} -> 
        %Response{http_status: 401, body: "<html><body>401 Unauthorized</body></html>"}
      {:error, :eperm} 
        %Response{http_status: 401, body: "<html><body>401 Unauthorized</body></html>"}
      {:error, :enoent} ->
        %Response{http_status: 404, body: "<html><body>404 Not Found</body></html>"}
      {:error, _} -> 
        %Response{http_status: 400, body: "<html><body>400 Bad Request</body></html>"}
    end
  end

  def handle(request = %Request{http_method: :POST, params: %{"filename" => _}}) do
    request
    |> handle_save
    |> case do
      :ok ->
        %Response{http_status: 201}
      {:error, :eaccess} -> 
        %Response{http_status: 401, body: "<html><body>401 Unauthorized</body></html>"}
      {:error, :enoent} -> 
        %Response{http_status: 400, body: "<html><body>400 Wrong Path</body></html>"}
      {:error, :enospc} -> 
        %Response{http_status: 500, body: "<html><body>500 No space left on drive</body></html>"}
      {:error, :eisdir} -> 
        %Response{http_status: 400, body: "<html><body>400 Filename is directory</body></html>"}
    end
  end

  def handle(request = %Request{http_method: :PUT, params: %{"filename" => _}}) do
    request
    |> handle_save
    |> case do
      :ok ->
        %Response{http_status: 200}
      {:error, :eaccess} -> 
        %Response{http_status: 401, body: "<html><body>401 Unauthorized</body></html>"}
      {:error, :enoent} -> 
        %Response{http_status: 400, body: "<html><body>400 Wrong Path</body></html>"}
      {:error, :enospc} -> 
        %Response{http_status: 500, body: "<html><body>500 No space left on drive</body></html>"}
      {:error, :eisdir} -> 
        %Response{http_status: 400, body: "<html><body>400 Filename is directory</body></html>"}
    end
  end
  
  def handle(%Request{http_method: http_method}) when http_method == :POST or http_method == :PUT do
    %Response{http_status: 400, body: "<html><body>To save file send filename param.</body></html>"}
  end
  
  def handle(request) do
    IO.puts 'Default method'
    IO.inspect request.http_method
    IO.inspect request.path
    IO.inspect request.headers
    IO.inspect request.params
    IO.inspect request.body
    %Response{http_status: 200, body: "<html><body>Unsupported request type! SimpleHTTPServer/0.0.1!</body></html>"}
  end
  
  defp modified_since?(file_path, since) do
    since_date = since
    |> Utils.DateUtils.parse_date
    file_path
    |> Utils.FileUtils.get_file_path
    |> Utils.FileUtils.get_file_modification_date
    |> Timex.before?(since_date) 
  end

  defp handle_save(%Request{http_method: http_method, path: path, params: %{"filename" => filename}, body: body}) do
    file_path = path 
                |> Utils.FileUtils.get_file_path
    file_path
    |> File.mkdir_p

    write_params = case http_method do
      :POST -> []
      :PUT -> [:append]
    end

    "#{file_path}/#{filename}"
    |> File.write(body, write_params)
  end
  
end
