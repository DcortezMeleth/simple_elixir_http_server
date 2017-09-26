defmodule Utils.FileUtils do

  @doc ~S"""
  Returnes path to file by joining elements and adding necessary base catalogues.

  ## Examples

      iex> Utils.FileUtils.get_file_path(["path", "to", "file"])
      "htdocs/path/to/file"
  """
  def get_file_path(path) do
    ["htdocs" | path] 
    |> Enum.join("/") 
  end

  def get_file_modification_date(file_path) do
    file_path
    |> File.stat!([])
    |> Map.get(:mtime)
    |> Timex.to_datetime
  end

end
