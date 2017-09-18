defmodule Validators do

  def validate(headers, body) do 
    [&Validators.validate_host_header/2]
    |> Enum.reduce(true, &(&1.(headers, body) and &2))
  end

  def validate_host_header(%{:'Host' => _}, _) do
    true
  end

  def validate_host_header(_, _) do
    false
  end

end
