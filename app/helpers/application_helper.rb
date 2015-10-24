module ApplicationHelper
  def intellinav
    @current_user.present? ? authenticated_nav : unauthenticated_nav
  end

  def authenticated_nav
    "<li class='has-dropdown'>#{link_to(@current_user.name, user_path(@current_user.id))}<ul class='dropdown'>"\
    "<li>#{link_to("Your Stats", '#')}</li>"\
    "<li>#{link_to("Log Out", login_path, method: :delete, confirm: "Are you sure you want to log out?")}</li>"\
    "</ul>"
  end

  def unauthenticated_nav
    "<li>#{link_to("Create Account", new_user_path)}</li>"\
    "<li class='divider show-for-medium-and-up'></li>"\
    "<li>#{link_to("Login", login_path)}</li>"
  end
end
