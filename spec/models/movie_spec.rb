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
  end
end
