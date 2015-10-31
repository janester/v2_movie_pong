require "spec_helper"

describe "Navbar" do
  let(:nav) { page.find("nav") }
  let(:go_home) { visit "/" }

  it "has a link to home" do
    go_home
    expect(nav).to have_link(nil, href: "/")
  end

  context "when the user is logged in" do
    let(:user) { create(:user) }

    before do
      sign_in_user(user)
      go_home
    end

    it "does not have the log in link" do
      expect(nav).to_not have_link("Login", href: "/login")
    end

    context "dropdown" do
      let(:dropdown) { nav.find("ul.dropdown") }

      it "has a dropdown" do
        expect(nav).to have_css("ul.dropdown")
      end

      it "has a logout link" do
        expect(dropdown).to have_link("Log Out", href: "/login")
      end
    end
  end

  context "when the user is not logged in" do
    before { go_home }
    it "has the log in link" do
      expect(nav).to have_link("Login", href: "/login")
    end
  end

  def sign_in_user(user)
    visit "/"
    click_link(nil, href: "/login")
    fill_in("username", with: user.username)
    fill_in("password", with: user.password)
    click_button("Login to Movie Pong")
  end
end
