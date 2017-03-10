defmodule LinksApi.Endpoint do
  use Phoenix.Endpoint, otp_app: :links_api

  socket "/socket", LinksApi.UserSocket

  plug Plug.RequestId
  plug Plug.Logger
  plug CORSPlug, origins: ["*"], headers: ["*"]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug LinksApi.Router
end
