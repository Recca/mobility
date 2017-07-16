require "spec_helper"

describe Mobility::Backend::Default do
  let(:default) { 'default foo' }
  let(:backend_double) { double("backend") }
  let(:backend) { backend_class.new("model", "title", default: default) }
  let(:backend_class) do
    backend_double_ = backend_double
    backend_class = Class.new(Mobility::Backend::Null) do
      define_method :read do |*args|
        backend_double_.read(*args)
      end

      define_method :write do |*args|
        backend_double_.write(*args)
      end
    end
    Class.new(backend_class).include(described_class)
  end

  describe "#read" do
    it "returns value if not nil" do
      expect(backend_double).to receive(:read).once.with(:fr, {}).and_return("foo")
      expect(backend.read(:fr)).to eq("foo")
    end

    it "returns value if value is false" do
      expect(backend_double).to receive(:read).once.with(:fr, {}).and_return(false)
      expect(backend.read(:fr)).to eq(false)
    end

    it "returns default if backend return value is nil" do
      expect(backend_double).to receive(:read).once.with(:fr, {}).and_return(nil)
      expect(backend.read(:fr)).to eq("default foo")
    end

    it "returns value of default override if passed as option to reader" do
      expect(backend_double).to receive(:read).once.with(:fr, {}).and_return(nil)
      expect(backend.read(:fr, default: "default bar")).to eq("default bar")
    end

    it "returns nil if passed default: nil as option to reader" do
      expect(backend_double).to receive(:read).once.with(:fr, {}).and_return(nil)
      expect(backend.read(:fr, default: nil)).to eq(nil)
    end

    it "returns false if passed default: false as option to reader" do
      expect(backend_double).to receive(:read).once.with(:fr, {}).and_return(nil)
      expect(backend.read(:fr, default: false)).to eq(false)
    end

    context "default is a Proc" do
      let(:default) { lambda { |model:, attribute:| "#{model} #{attribute}" } }

      it "calls default with model and attribute as args if default is a Proc" do
        expect(backend_double).to receive(:read).once.with(:fr, {}).and_return(nil)
        expect(backend.read(:fr)).to eq('model title')
      end

      it "calls default with model and attribute as args if default option is a Proc" do
        expect(backend_double).to receive(:read).once.with(:fr, {}).and_return(nil)
        expect(backend.read(:fr, default: lambda do |model:, attribute:|
          "#{model} #{attribute} from options"
        end)).to eq('model title from options')
      end
    end
  end
end