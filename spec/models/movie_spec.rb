require "spec_helper"

describe Movie do
  describe "Validations" do
    it { should validate_uniqueness_of(:tmdb_id) }
  end

  describe "Class Methods" do
    subject { described_class }

    describe ".create_or_find_movie" do
      let(:id) { 1234 }
      let(:return_value) { subject.create_or_find_movie(id) }

      before { allow(MovieDb).to receive(:get_movie).with(id) { { "id" => id } } }

      context "when the id is already in the DB" do
        before { Movie.create(tmdb_id: id) }

        it "does not create a new record" do
          expect(Movie).not_to receive(:create)
          return_value
        end

        it "returns the found record" do
          expect(return_value.tmdb_id).to eq id
        end
      end

      context "when the is not already in the DB" do
        it "creates a new record" do
          expect(Movie).to receive(:create)
          return_value
        end

        it "returns the found record" do
          expect(return_value.tmdb_id).to eq id
        end
      end
    end

    describe ".format_from_api" do
      let(:keys) { [:tmdb_id, :tmdb_popularity, :year, :title] }
      it "returns a hash with the necessary keys" do
        expect(subject.format_from_api({})).to include(*keys)
      end
    end
  end

  describe "Instance Methods" do
    subject { build(:movie) }

    describe '#get_cast!' do
      it "retrieves the cast of the movie" do
        expect(MovieDb).to receive(:get_movie_credits).with(subject.tmdb_id) { [] }
        subject.get_cast!
      end

      context "with the api response" do
        let(:id) { 1 }
        let(:credits) { [HWIA.new(id: id, character: "Wolverine")] }

        before do
          allow(MovieDb).to receive(:get_movie_credits).with(subject.tmdb_id) { credits }
        end

        context "when an actor response is not a character" do
          let(:credits) { [HWIA.new(id: id)] }

          it "does not find or create an actor record for it" do
            expect(Actor).not_to receive(:create_or_find_actor).with(id)
            subject.get_cast!
          end
        end

        context "when an actor response is a character" do
          it "does find or create an actor record for it" do
            expect(Actor).to receive(:create_or_find_actor).with(id).and_call_original
            subject.get_cast!
          end
        end

        context "when the actor is already associated with the movie" do
          before { subject.actors << create(:actor, tmdb_id: id) }

          it "does not add the association again" do
            subject.get_cast!
            expect(subject.actors.uniq(&:id).length).to eq subject.actors.length
          end
        end

        context "when the actor is not already associated with the movie" do
          before { allow(MovieDb).to receive(:get_actor).with(id) { credits.first } }
          it "adds the association" do
            subject.get_cast!
            expect(subject.actors.map(&:tmdb_id)).to include(id)
          end
        end
      end
    end
  end
end
