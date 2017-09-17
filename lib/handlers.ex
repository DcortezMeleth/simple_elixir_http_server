defmodule Handlers do

  def handle(:GET, path, _, _) do
    case ["htdocs" | path] |> Enum.join("/") |> File.read do
      {:ok, content} -> {200, %{}, content}
      {:error, :eaccess} -> {401, %{}, "<html><body>401 Unauthorized</body></html>"}
      {:error, :enoent} -> {404, %{}, "<html><body>404 Not Found</body></html>"}
      {:error, :enomem} -> {500, %{}, "<html><body>500 File too larg</body></html>"}
      {:error, _} -> {400, %{}, "<html><body>400 Bad Request</body></html>"}
    end
  end
  
  def handle(http_method, path, params, body) do
    IO.puts 'Default method'
    IO.inspect http_method
    IO.inspect path
    IO.inspect params
    IO.inspect body
    {200, %{}, "<html><body>SimpleHTTPServer/0.0.1!</body></html>"}
  end

end
