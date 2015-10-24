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
  end

  describe "Class Methods" do
    subject { described_class }

    describe ".create_or_find_actor" do
      let(:id) { 1234 }
      let(:call) { subject.create_or_find_actor(id) }
      context "when the id does not exist in the database" do
        before { allow(MovieDb).to receive(:get_actor).with(id) { { "id" => id, "name" => "x" } } }
        it "does create a new one" do
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

      context "when the id does exist in the database" do
        before { create(:actor, tmdb_id: id) }

        it "does not create a new one" do
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
  end
end
