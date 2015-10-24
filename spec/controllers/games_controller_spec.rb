require "spec_helper"

describe GamesController do
  let(:current_user) { create(:user) }
  let(:game) { create(:game, user_id: current_user.id) }

  before { controller.instance_variable_set("@current_user", current_user) }

  describe "POST create" do
    let(:make_request) { post :create, params }
    let(:params) { {} }
    context "populating scores" do
      it { should use_before_filter(:populate_scores) }
    end

    it "creates a game" do
      expect { make_request }.to change(Game, :count).by(1)
    end

    context "session" do
      before { make_request }
      it "sets round to 1" do
        expect(controller.session[:round]).to eq 1
      end

      it "sets player_score 0" do
        expect(controller.session[:player_score]).to eq 0
      end

      it "sets computer_score 0" do
        expect(controller.session[:computer_score]).to eq 0
      end
    end

    it "redirects to the start game path" do
      make_request
      expect(response).to redirect_to("/games/#{assigns(:game).id}/start")
    end
  end

  describe "GET start" do
    let(:make_request) { get :start, params }
    let(:params) { { id: game.id } }

    context "populating scores" do
      it { should use_before_filter(:populate_scores) }
    end

    it "should render the start page" do
      expect(make_request).to render_template(:start)
    end

    it "should set the game instance var" do
      make_request
      expect(controller.instance_variable_get("@game")).to eq game
    end
  end

  describe "POST play" do
    let(:make_request) { post :play, params }
    let(:params) { { id: game.id }.merge!(addtl_params) }
    let(:addtl_params) { { actor_id: actor.tmdb_id, movie_id: movie.tmdb_id } }
    let(:actor) { create(:actor) }
    let(:movie) { create(:movie) }
    let(:response_body) { JSON(response.body) }
    let(:computer_total) { response_body["scores"].inject(0) { |t, x| t += x["computer"] } }
    let(:player_total) { response_body["scores"].inject(0) { |t, x| t += x["player"] } }

    before { controller.session[:round] = 0 }

    context "populating scores" do
      it { should use_before_filter(:populate_scores) }
      it { should use_before_filter(:increment_round) }
      it { should use_before_filter(:add_movie_to_game) }
      it { should use_before_filter(:increment_movie_times_said) }
    end

    it "increments the round" do
      make_request
      expect(controller.session[:round]).to eq 1
    end

    it "adds the movie to the game" do
      make_request
      expect(game.reload.movies).to include(movie)
    end

    it "bumps up the times said of the movie" do
      make_request
      expect(movie.reload.times_said).to eq 1
    end

    context "when the actor is not in the movie" do
      before { make_request }

      it "gives the computer a point" do
        expect(computer_total).to eq 1
      end

      it "does not give the player a point" do
        expect(player_total).to eq 0
      end

      it "returns a message with an explanation" do
        expect(response_body["message"]).to eq "#{actor.name} is not in #{movie.title}"
      end
    end

    context "when the actor is in the movie" do
      before { movie.actors << actor }

      context "when the actor has already been said" do
        before do
          game.actors << actor
          make_request
        end

        it "gives the computer a point" do
          expect(computer_total).to eq 1
        end

        it "does not give the player a point" do
          expect(player_total).to eq 0
        end

        it "returns a message with an explanation" do
          expect(response_body["message"]).to eq "#{actor.name} has already been said"
        end
      end

      context "when the actor has not already been said" do
        let(:filmography) { [] }
        before do
          allow(MovieDb).to receive(:get_actor_credits).with(actor.tmdb_id) { filmography }
        end

        it "adds the actor to the game" do
          make_request
          expect(game.reload.actors).to include(actor)
        end

        context "when all of the popular movies for that actor have been said" do
          before { make_request }

          it "gives the player a point" do
            expect(player_total).to eq 1
          end

          it "does not give the computer a point" do
            expect(computer_total).to eq 0
          end

          it "returns a message with an explanation" do
            expect(response_body["message"]).to eq "Nice! You out-witted a comptuer!"
          end
        end

        context "when not all of the popular movies for that actor have been said" do
          let(:movie_2) { HashWithIndifferentAccess.new(id: 0, release_date: "2006", title: "X2") }
          let(:filmography) { [movie_2] }
          let(:response_actor_ids) { response_body["actors"].map { |x| x["tmdb_id"] } }
          let(:new_actors) do
            [
              HashWithIndifferentAccess.new(id: 0, character: "Storm", name: "Halle Berry"),
              HashWithIndifferentAccess.new(id: 1, character: "Magneto", name: "Ian McKellan")
            ]
          end
          before do
            allow(MovieDb).to receive(:get_movie).with(movie_2[:id]) { movie_2 }
            allow(MovieDb).to receive(:get_movie_credits).with(movie_2[:id]) { new_actors }
            new_actors.each { |a| allow(MovieDb).to receive(:get_actor).with(a[:id]) { a } }
            make_request
          end

          it "does not give the computer a point" do
            expect(computer_total).to eq 0
          end

          it "does not give the player a point" do
            expect(player_total).to eq 0
          end

          it "returns the movie" do
            expect(response_body["movie"]["tmdb_id"]).to eq movie_2[:id]
          end

          it "returns the full list of actors" do
            expected_actors = new_actors.map { |x| x["id"] } + [actor.tmdb_id]
            expect(response_actor_ids).to match_array(expected_actors)
          end
        end
      end
    end
  end
end
