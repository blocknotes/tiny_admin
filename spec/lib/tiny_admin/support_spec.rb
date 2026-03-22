# frozen_string_literal: true

RSpec.describe TinyAdmin::Support do
  describe ".call" do
    it "chains method calls on the value" do
      expect(described_class.call("Hello World", options: ["downcase", "strip"])).to eq("hello world")
    end

    it "returns nil when value is nil" do
      expect(described_class.call(nil, options: ["downcase"])).to be_nil
    end

    it "returns nil when options are empty" do
      expect(described_class.call("test", options: [])).to be_nil
    end
  end

  describe ".downcase" do
    it "downcases the value" do
      expect(described_class.downcase("HELLO")).to eq("hello")
    end

    it "returns nil when value is nil" do
      expect(described_class.downcase(nil)).to be_nil
    end
  end

  describe ".upcase" do
    it "upcases the value" do
      expect(described_class.upcase("hello")).to eq("HELLO")
    end

    it "returns nil when value is nil" do
      expect(described_class.upcase(nil)).to be_nil
    end
  end

  describe ".format" do
    it "formats the value using the format string" do
      expect(described_class.format(3.14159, options: ["%.2f"])).to eq("3.14")
    end

    it "returns nil when value is nil" do
      expect(described_class.format(nil, options: ["%.2f"])).to be_nil
    end

    it "returns nil when options are empty" do
      expect(described_class.format(42, options: [])).to be_nil
    end
  end

  describe ".round" do
    it "rounds to the specified precision" do
      expect(described_class.round(3.14159, options: ["2"])).to eq(3.14)
    end

    it "defaults to 2 decimal places when options are empty" do
      expect(described_class.round(3.14159, options: [])).to eq(3.14)
    end

    it "returns nil when value is nil" do
      expect(described_class.round(nil, options: [])).to be_nil
    end
  end

  describe ".strftime" do
    let(:time) { Time.new(2024, 6, 15, 10, 30, 0) }

    it "formats with the given pattern" do
      expect(described_class.strftime(time, options: ["%Y%m%d"])).to eq("20240615")
    end

    it "uses the default format when no option given" do
      expect(described_class.strftime(time, options: [])).to eq("2024-06-15 10:30")
    end

    it "returns nil when value is nil" do
      expect(described_class.strftime(nil, options: [])).to be_nil
    end
  end

  describe ".to_date" do
    it "converts a datetime to a date string" do
      time = Time.new(2024, 6, 15, 10, 30, 0)
      expect(described_class.to_date(time)).to eq("2024-06-15")
    end

    it "returns nil when value is nil" do
      expect(described_class.to_date(nil)).to be_nil
    end

    it "falls back to to_s when to_date raises an error" do
      value = "not-a-date"
      expect(described_class.to_date(value)).to eq("not-a-date")
    end
  end

  describe ".label_for" do
    it "returns the value unchanged" do
      expect(described_class.label_for("Password")).to eq("Password")
    end
  end
end
