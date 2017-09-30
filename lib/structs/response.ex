defmodule Response do
    
    @enforce_keys [:http_status]
    defstruct http_status: 200, headers: %{}, body: ""
end