# frozen_string_literal: true

RSpec.describe TinyAdmin::Field do
  describe ".create_field" do
    it "creates a field with humanized title from name", :aggregate_failures do
      field = described_class.create_field(name: "author_name")
      expect(field.name).to eq("author_name")
      expect(field.title).to eq("Author name")
      expect(field.type).to eq(:string)
      expect(field.options).to eq({})
    end

    it "uses the provided title when given" do
      field = described_class.create_field(name: "email", title: "Email Address")
      expect(field.title).to eq("Email Address")
    end

    it "uses the provided type when given" do
      field = described_class.create_field(name: "age", type: :integer)
      expect(field.type).to eq(:integer)
    end

    it "uses the provided options when given" do
      options = { method: "downcase" }
      field = described_class.create_field(name: "name", options: options)
      expect(field.options).to eq(options)
    end

    it "converts symbol names to strings" do
      field = described_class.create_field(name: :user_id)
      expect(field.name).to eq("user_id")
    end

    it "handles nil options by defaulting to empty hash" do
      field = described_class.create_field(name: "test", options: nil)
      expect(field.options).to eq({})
    end
  end

  describe "#apply_call_option" do
    it "chains method calls on the target" do
      field = described_class.new(name: "title", title: "Title", type: :string, options: { call: "to_s, downcase" })
      expect(field.apply_call_option(42)).to eq("42")
    end

    it "returns nil when call option is not set" do
      field = described_class.new(name: "title", title: "Title", type: :string, options: {})
      expect(field.apply_call_option("test")).to be_nil
    end

    it "handles nil target safely via safe navigation" do
      field = described_class.new(name: "title", title: "Title", type: :string, options: { call: "nonexistent" })
      expect(field.apply_call_option(nil)).to be_nil
    end
  end

  describe "#translate_value" do
    it "returns value as string when no method option" do
      field = described_class.new(name: "name", title: "Name", type: :string, options: {})
      expect(field.translate_value(42)).to eq("42")
    end

    it "returns nil when value is nil and no method option" do
      field = described_class.new(name: "name", title: "Name", type: :string, options: {})
      expect(field.translate_value(nil)).to be_nil
    end

    it "applies the helper method from options" do
      field = described_class.new(name: "name", title: "Name", type: :string, options: { method: "downcase" })
      allow(TinyAdmin.settings).to receive(:helper_class).and_return(TinyAdmin::Support)
      expect(field.translate_value("HELLO")).to eq("hello")
    end

    it "uses the converter class when specified" do
      converter = Class.new do
        def self.upcase(value, options: [])
          value.upcase
        end
      end
      stub_const("TestConverter", converter)

      field = described_class.new(
        name: "name", title: "Name", type: :string,
        options: { method: "upcase", converter: "TestConverter" }
      )
      expect(field.translate_value("hello")).to eq("HELLO")
    end

    it "passes additional args to the method" do
      field = described_class.new(
        name: "value", title: "Value", type: :float,
        options: { method: "round, 1" }
      )
      allow(TinyAdmin.settings).to receive(:helper_class).and_return(TinyAdmin::Support)
      expect(field.translate_value(3.456)).to eq(3.5)
    end
  end
end
