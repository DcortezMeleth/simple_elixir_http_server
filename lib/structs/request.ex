defmodule Request do
    
    @enforce_keys [:http_method]
    defstruct http_method: :GET, path: [], headers: %{}, params: %{}, body: ""
end