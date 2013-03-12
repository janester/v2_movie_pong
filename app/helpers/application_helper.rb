module ApplicationHelper
  def intellinav
    links = ""
    if @current_user.present?
      links += "<li class='has-dropdown'>#{link_to(@current_user.name, user_path(@current_user.id))}<ul class='dropdown'>"
      links += "<li>#{link_to('Your Stats', user_path(@current_user.id))}</li>"
      links += "<li>#{link_to('Log Out', login_path, :method => :delete, :confirm => "Are you sure you want to log out?")}</li>"
      links += "</ul>"
    else
      links += "<li>#{link_to('Create Account', new_user_path)}</li>"
      links += "<li class='divider show-for-medium-and-up'></li>"
      links += "<li>#{link_to('Login', login_path)}</li>"
    end
  end
end
