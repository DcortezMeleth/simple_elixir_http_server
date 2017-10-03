defmodule Utils.HttpStatuses do
  
  @doc ~S"""
  This method returns HTTP message headers with status code and it's description for
  given code as number.

  ## Examples

      iex> Utils.HttpStatuses.get_status_by_code(200)
      '200 OK\r\n'

      iex> Utils.HttpStatuses.get_status_by_code(404)
      '404 Not Found\r\n'

      iex> Utils.HttpStatuses.get_status_by_code(400)
      '400 Bad Request\r\n'
  """  
  def get_status_by_code(status_code) do
    '#{status_code} #{Map.get(status_codes, status_code)}\r\n'
  end

  defp status_codes do
      %{200 => 'OK', 
      201 => 'Created', 
      202 => 'Accepted', 
      304 => 'Not Modified',
      400 => 'Bad Request', 
      401 => 'Unauthorized', 
      404 => 'Not Found',
      411 => 'Length Required', 
      412 => 'Precondition Failed',
      500 => 'Internal Error'}
  end
end