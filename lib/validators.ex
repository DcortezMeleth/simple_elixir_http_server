defmodule Validators do

  @doc """
  Validates request against set of conditions in form of functions defined in this module.
  """
  def valid?(headers, body) do 
    [&validate_host_header/2]
    |> Enum.reduce(true, &(&1.(headers, body) and &2))
  end

  defp validate_host_header(%{:'Host' => _}, _) do
    true
  end

  defp validate_host_header(_, _) do
    false
  end

end
