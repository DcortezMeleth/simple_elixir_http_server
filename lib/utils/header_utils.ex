defmodule Utils.HeaderUtils do
  
  @version Mix.Project.config[:version]

  def headers_to_string(headers) do
    headers
    |> Enum.reduce("", fn({k,v}, acc) -> Enum.join([acc, k, ": ", v, "\r\n"]) end)
  end

  def merge_base_headers(headers) do
    base_headers()
    |> Map.merge(headers)
  end

  def get_content_length_header(content_length) do
    %{'Content-Length' => '#{content_length}'} 
  end
  
  defp base_headers do
    %{'Date' => '#{Utils.DateUtils.current_date}', 
    'Server' => 'SimpleElixirHttpServer/#{@version}', 
    'Connection' => 'close', 
    'Content-type' => 'text/html;', 
    'Cache-Control' => 'no-cache'}
  end
      
end