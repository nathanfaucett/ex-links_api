defmodule LinksApi.Web.Router do
  use LinksApi.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LinksApi.Web do
    pipe_through :api

    resources "/posts", PostController
    post "/posts/:id/star", PostController, :star

    get "/users/create_from_token", UserController, :create_from_token
    delete "/users", UserController, :delete
    get "/users/:provider", UserController, :index
    get "/users/:provider/callback", UserController, :callback
  end
end
