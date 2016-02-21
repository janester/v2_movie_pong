require "spec_helper"

describe "Start Game", js: true do
  include LoginHelper

  context "when a user is logged in" do
    let(:user) { create(:user) }
    let(:score_board) { page.find_by_id("pageScoreboard") }
    let(:computer_score) { score_board.find_by_id("computer_score") }
    let(:player_score) { score_board.find_by_id("player_score") }
    let(:starting_movies) { (1..2).map { create(:movie, :as_starting_movie) } }

    let(:create_movies) do
      starting_movies
      2.times { create(:movie) }
    end

    let(:create_actors) do
      Movie.all.map do |m|
        2.times { m.actors << create(:actor) }
      end
    end

    let(:new_movie_btn) { page.find_by_id("new_movie_btn") }
    let(:entered_actor_btn) { page.find_by_id("entered_actor_btn") }

    before do
      create_movies && create_actors
      sign_in_user(user)
      page.click_link("New Game")
    end

    it "starts with computer and player score 0" do
      expect(computer_score).to have_text("0")
      expect(player_score).to have_text("0")
    end

    it "shows the ask for a new movie button" do
      expect(new_movie_btn.visible?).to eq true
    end

    it "shows the entered actor button" do
      expect(new_movie_btn.visible?).to eq true
    end

    context "starting movies" do
      let(:movie_title) { page.find_by_id("movie_title", visible: false) }
      let(:movie_tmdb_id) { page.find_by_id("movie_tmdb", visible: false) }

      it "loads a starting movie to start" do
        expect(movie_title.text).to_not be_blank
        expect(starting_movies.map(&:tmdb_id)).to include(movie_tmdb_id.text.to_i)
      end
    end

    context "actors" do
      let(:actor_items) { page.all("a.ui-corner-all") }
      let(:starting_actors) { Actor.pluck("name") }

      before do
        fill_in("entered_actor", with: "h")
        sleep 1
      end

      it "lists all the actors" do
        expect(actor_items.map(&:text)).to eq starting_actors
      end
    end
  end
end
