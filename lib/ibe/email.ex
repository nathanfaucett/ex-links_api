defmodule LinksApi.Email do
  use Bamboo.Phoenix, view: LinksApi.EmailView

  def confirmation_text_email(params = %{email: email, token: _token}) do
    new_email()
      |> to(email)
      |> from("admin@faucette.com")
      |> subject("Links Confirmation Email")
      |> put_text_layout({LinksApi.LayoutView, "email.text"})
      |> render("confirmation.text", params)
  end

  def confirmation_html_email(params = %{email: _email, token: _token}) do
    confirmation_text_email(params)
      |> put_text_layout({LinksApi.LayoutView, "email.html"})
      |> render("confirmation.html", params)
  end
end
