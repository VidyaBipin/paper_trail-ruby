require "spec_helper"

RSpec.describe PaperTrail::AttributeSerializers::ObjectAttribute do
  describe "postgres-specific column types", database: :postgres do
    describe "#serialize" do
      it "serializes a postgres array into a plain array" do
        attrs = { "post_ids" => [1, 2, 3] }
        described_class.new(PostgresUser).serialize(attrs)
        expect(attrs["post_ids"]).to eq [1, 2, 3]
      end
    end

    describe "#deserialize" do
      it "deserializes a plain array correctly" do
        attrs = { "post_ids" => [1, 2, 3] }
        described_class.new(PostgresUser).deserialize(attrs)
        expect(attrs["post_ids"]).to eq [1, 2, 3]
      end

      it "deserializes an array serialized with Rails <= 5.0.1 correctly" do
        attrs = { "post_ids" => "{1,2,3}" }
        described_class.new(PostgresUser).deserialize(attrs)
        expect(attrs["post_ids"]).to eq [1, 2, 3]
      end
    end
  end
end
