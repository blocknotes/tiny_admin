# frozen_string_literal: true

RSpec.describe TinyAdmin do
  describe ".configure_from_file" do
    let(:config_file) { Tempfile.new(["tiny_admin", ".yml"]) }

    before do
      config_file.write("---\nroot_path: '/dashboard'\n")
      config_file.flush
    end

    after { config_file.close! }

    it "resets settings by default" do
      TinyAdmin.configure { |s| s.root_path = "/custom" }
      TinyAdmin.configure_from_file(config_file.path)
      expect(TinyAdmin.settings.root_path).to eq("/dashboard")
    end

    it "preserves programmatic settings when reset: false" do
      TinyAdmin.settings.reset!
      TinyAdmin.configure { |s| s.extra_styles = "body { color: red; }" }
      TinyAdmin.configure_from_file(config_file.path, reset: false)
      expect(TinyAdmin.settings.root_path).to eq("/dashboard")
      expect(TinyAdmin.settings.extra_styles).to eq("body { color: red; }")
    end
  end
end
