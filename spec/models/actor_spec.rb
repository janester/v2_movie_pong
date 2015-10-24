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

    describe ".create_or_find_actor" do
      let(:id) { 1234 }
      let(:call) { subject.create_or_find_actor(id) }
      context "when the id does not exist in the database" do
        context "when all the info is passed in" do
          let(:params) { HWIA.new(id: id, name: "Hugh Jackman") }
          let(:call) { subject.create_or_find_actor(id, params) }
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
      context "when the api call is successful" do
      end

      context "when the api call is not successful" do
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
      context "when some of the films are in the future" do
      end

      it "returns an array" do
      end

      it "returns a sorted array" do
      end

      it "returns the most recent first" do
      end
    end

    describe '#get_movies!' do
      it "returns a list of 15 movies" do
      end

      context "when some movies are new" do
        it "creates the record for it" do
        end
      end

      context "when all movies are not new" do
        it "finds the records" do
        end
      end

      context "when some of the movies already are associated" do
        it "does not duplicate the association" do
        end
      end

      context "when none are already associated" do
        it "creates the association" do
        end
      end
    end
  end
end
