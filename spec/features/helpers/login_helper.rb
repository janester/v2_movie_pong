module LoginHelper
  def sign_in_user(user)
    go_home
    click_link(nil, href: "/login")
    fill_in("username", with: user.username)
    fill_in("password", with: user.password)
    click_button("Login to Movie Pong")
  end

  def on_root?
    page.current_path == "/"
  end

  def go_home
    visit "/" unless on_root?
  end
end
