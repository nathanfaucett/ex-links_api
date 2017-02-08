defmodule LinksApi.ErrorViewTest do
  use LinksApi.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render_to_string(LinksApi.ErrorView, "404.json", []) ==
           Poison.encode!(%{code: 404, message: "Page not found"})
  end

  test "render 500.json" do
    assert render_to_string(LinksApi.ErrorView, "500.json", []) ==
           Poison.encode!(%{code: 500, message: "Internal server error"})
  end

  test "render any other" do
    assert render_to_string(LinksApi.ErrorView, "500.json", []) ==
           Poison.encode!(%{code: 500, message: "Internal server error"})
  end
end
