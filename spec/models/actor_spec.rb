require "spec_helper"

describe Actor do
  describe "Associations" do
    it { should have_and_belong_to_many(:movies) }
    it { should have_and_belong_to_many(:games) }
  end

  describe "Validations" do
    it { should validate_uniqueness_of(:tmdb_id) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:tmdb_id) }
    it { should_not validate_presence_of(:popularity) }
  end

  describe "Class Methods" do
    subject { described_class }

    describe ".create_or_find" do
      let(:id) { 1234 }
      let(:call) { subject.create_or_find(id) }
      context "when the id does not exist in the database" do
        context "when all the info is passed in" do
          let(:params) { HWIA.new(id: id, name: "Hugh Jackman") }
          let(:call) { subject.create_or_find(id, params) }
          it "creates a new record" do
            expect(subject).to receive(:create)
            call
          end

          it "returns the correct record" do
            expect(call.tmdb_id).to eq id
          end

          it "returns a valid record" do
            expect(call.valid?).to eq true
          end
        end

        context "when the info is not passed in" do
          before { allow(MovieDb).to receive(:get_actor).with(id) { { "id" => id, "name" => "x" } } }
          it "does create a new record" do
            expect(subject).to receive(:create)
            call
          end

          it "returns the correct record" do
            expect(call.tmdb_id).to eq id
          end

          it "returns a valid record" do
            expect(call.valid?).to eq true
          end
        end
      end

      context "when the id does exist in the database" do
        before { create(:actor, tmdb_id: id) }

        it "does not create a new record" do
          expect(subject).not_to receive(:create)
          call
        end

        it "returns the correct record" do
          expect(call.tmdb_id).to eq id
        end
      end
    end
  end

  describe "Instance Methods" do
    describe '#retrieve_filmography' do
      subject { build(:actor) }
      let(:result) { subject.retrieve_filmography }
      before { allow(MovieDb).to receive(:get_actor_credits).with(subject.tmdb_id) { response } }

      context "when the api call is successful" do
        let(:response) { [HWIA.new(id: 1, title: "X2")] }

        it "returns an array" do
          expect(result).to be_kind_of(Array)
        end

        it "returns the api response" do
          expect(result).to eq response
        end
      end

      context "when the api call is not successful" do
        let(:response) {}
        it "returns an array" do
          expect(result).to be_kind_of(Array)
        end

        it "returns an empty array" do
          expect(result).to be_empty
        end
      end
    end

    describe '#future_year?' do
      subject { build(:actor) }
      let(:result) { subject.future_year?(release_date) }
      context "when the release_date is nil" do
        let(:release_date) {}
        it "returns true" do
          expect(result).to eq true
        end
      end

      context "when the release_date is not nil" do
        context "when the release year is next year" do
          let(:release_date) { (DateTime.now.year + 1).to_s }
          it "returns true" do
            expect(result).to eq true
          end
        end

        context "when the release year is this year" do
          let(:release_date) { (DateTime.now.year).to_s }
          it "returns false" do
            expect(result).to eq false
          end
        end

        context "when the release year is in the past" do
          let(:release_date) { (DateTime.now.year - 1).to_s }
          it "returns false" do
            expect(result).to eq false
          end
        end
      end
    end

    describe '#ordered_filmography' do
      subject { build(:actor) }
      let(:result) { subject.ordered_filmography }
      before { allow(MovieDb).to receive(:get_actor_credits).with(subject.tmdb_id) { response } }
      let(:release_date) { 2.years.ago.to_s }
      let(:response) do
        (0..2).map { |i| HWIA.new(id: i, release_date: release_date) }
      end

      context "when some of the films are in the future" do
        let(:release_date) { (DateTime.now.year + 1).to_s }
        it "they do not get returned" do
          expect(result).to be_empty
        end
      end

      it "returns an array" do
        expect(result).to be_kind_of(Array)
      end

      context "sorting" do
        let(:records) do
          (1..3).map { |i| HWIA.new(id: i, release_date: i.years.ago.to_s) }
        end
        let(:response) { records.shuffle }

        it "returns a sorted array" do
          expect(result).to eq records
        end

        it "returns the most recent first" do
          expect(result.first).to eq records.first
        end

        it "returns the oldest last" do
          expect(result.last).to eq records.last
        end
      end
    end

    describe '#get_movies!' do
      subject { build(:actor) }
      let(:result) { subject.get_movies! }
      let(:max) { 0 }
      let(:api_response) do
        (0...max).map { |i| HWIA.new(id: i, release_date: 3.years.ago.to_s) }
      end

      before { allow(MovieDb).to receive(:get_actor_credits).with(subject.tmdb_id) { api_response } }

      context "when there are 15 or more results" do
        before { allow(subject).to receive(:add_movie) }
        let(:max) { 20 }
        it "returns only 15" do
          expect(result.length).to eq 15
        end
      end

      context "whent here are less than 15 results" do
        before { allow(subject).to receive(:add_movie) }
        let(:max) { 10 }
        it "returns all of them" do
          expect(result.length).to eq 10
        end
      end

      context "when some movies are new" do
        let(:max) { 1 }
        after { result }

        it "creates the record for it" do
          expect(Movie).to receive(:create).and_call_original
        end
      end

      context "when all movies are not new" do
        let(:movie) { create(:movie) }
        let(:api_response) { [HWIA.new(id: movie.tmdb_id, release_date: 3.years.ago.to_s)] }

        it "does not create new ones" do
          expect(Movie).not_to receive(:create)
          result
        end

        it "finds the records" do
          expect(result).to eq [movie]
        end

        context "when some of the movies already are associated" do
          before do
            subject.movies << movie
            result
          end

          it "does not duplicate the association" do
            expect(subject.movies.uniq).to eq subject.movies
          end
        end

        context "when none are already associated" do
          before { result }
          it "creates the association" do
            expect(subject.movies).to eq [movie]
          end
        end
      end
    end
  end
end
