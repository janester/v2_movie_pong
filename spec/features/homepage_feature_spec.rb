require "spec_helper"

describe "Home Page" do
  include LoginHelper

  let(:new_game_btn) { page.find_link("New Game") }
  let(:btn_disabled?) { new_game_btn[:class].include?("disabled") }

  it "has a navbar" do
    go_home
    expect(page).to have_css("nav")
  end

  context "when user is logged in" do
    let(:user) { create(:user) }
    before { sign_in_user(user) && go_home }

    it "has an active new game button" do
      expect(btn_disabled?).to eq false
    end

    it "starts a new game when clicked" do
      expect { new_game_btn.click }.to change(page, :current_path)
    end
  end

  context "when user is not logged in" do
    before { go_home }
    it "has a disabled new game button" do
      expect(btn_disabled?).to eq true
    end

    it "does not start a new game when the new game button is clicked" do
      expect { new_game_btn.click }.not_to change(page, :current_path)
    end
  end
end
