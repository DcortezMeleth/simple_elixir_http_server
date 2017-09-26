defmodule Handlers do

  def handle(:GET, path, headers = %{:"If-Modified-Since" => since}, p, b) do
    modified_since?(path, since)
    |> case do
      # File modified since `If-Modified-Since`, we handle request as normal
      false -> 
        handle(:GET, path, headers |> Map.delete(:"If-Modified-Since"), p, b)
      # File unmodified, returning 304
      true -> 
        {304, %{}, "<html><body>304 Not Modifed</body></html>"}
    end
  end
  
  def handle(method, path, headers = %{:"If-Unmodified-Since" => since}, p, b) do
    modified_since?(path, since)    
    |> case do
      # File unmodified since `If-Modified-Since`, we handle request as normal
      true -> 
        handle(method, path, headers |> Map.delete(:"If-Unmodified-Since"), p, b)
        # File modified, returning 304
      false -> 
        {412, %{}, "<html><body>412 Precondition Failed!</body></html>"}
    end
  end

  def handle(:GET, path, _, _, _) do
    file_path = path 
                |> Utils.FileUtils.get_file_path 
    case file_path |> File.read do
      {:ok, content} ->
        mdate = file_path
        |> Utils.FileUtils.get_file_modification_date
        |> Timex.format!("{RFC1123}")
        {200, %{'Last-Modified' => mdate}, content}
      {:error, :eaccess} -> 
        {401, %{}, "<html><body>401 Unauthorized</body></html>"}
      {:error, :enoent} -> 
        {404, %{}, "<html><body>404 Not Found</body></html>"}
      {:error, :enomem} -> 
        {500, %{}, "<html><body>500 File too large</body></html>"}
      {:error, _} -> 
        {400, %{}, "<html><body>400 Bad Request</body></html>"}
    end
  end
  
  def handle(http_method, path, headers, params, body) do
    IO.puts 'Default method'
    IO.inspect http_method
    IO.inspect path
    IO.inspect headers
    IO.inspect params
    IO.inspect body
    {200, %{}, "<html><body>SimpleHTTPServer/0.0.1!</body></html>"}
  end

  defp modified_since?(file_path, since) do
    since_date = since
                  |> Utils.DateUtils.parse_date
    mdate = file_path
            |> Utils.FileUtils.get_file_path
            |> Utils.FileUtils.get_file_modification_date
            |> Timex.before?(since_date) 
  end
  
end
