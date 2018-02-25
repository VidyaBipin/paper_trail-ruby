# frozen_string_literal: true

require "spec_helper"

RSpec.describe PaperTrail do
  describe "#config", versioning: true do
    it "allows for config values to be set" do
      expect(described_class.config.enabled).to eq(true)
      described_class.config.enabled = false
      expect(described_class.config.enabled).to eq(false)
    end

    it "accepts blocks and yield the config instance" do
      expect(described_class.config.enabled).to eq(true)
      described_class.config { |c| c.enabled = false }
      expect(described_class.config.enabled).to eq(false)
    end
  end

  describe "#configure" do
    it "is an alias for the `config` method" do
      expect(described_class.method(:configure)).to eq(
        described_class.method(:config)
      )
    end
  end

  describe ".gem_version" do
    it "returns a Gem::Version" do
      v = described_class.gem_version
      expect(v).to be_a(::Gem::Version)
      expect(v.to_s).to eq(::PaperTrail::VERSION::STRING)
    end
  end

  context "when enabled" do
    it "affects all threads" do
      Thread.new { described_class.enabled = false }.join
      assert_equal false, described_class.enabled?
    end

    after do
      described_class.enabled = true
    end
  end

  context "default" do
    it "has versioning off by default" do
      expect(described_class).not_to be_enabled
    end

    it "has versioning on in a `with_versioning` block" do
      expect(described_class).not_to be_enabled
      with_versioning do
        expect(described_class).to be_enabled
      end
      expect(described_class).not_to be_enabled
    end

    context "error within `with_versioning` block" do
      it "reverts the value of `PaperTrail.enabled?` to its previous state" do
        expect(described_class).not_to be_enabled
        expect { with_versioning { raise } }.to raise_error(RuntimeError)
        expect(described_class).not_to be_enabled
      end
    end
  end

  context "`versioning: true`", versioning: true do
    it "has versioning on by default" do
      expect(described_class).to be_enabled
    end

    it "keeps versioning on after a with_versioning block" do
      expect(described_class).to be_enabled
      with_versioning do
        expect(described_class).to be_enabled
      end
      expect(described_class).to be_enabled
    end
  end

  context "`with_versioning` block at class level" do
    it { expect(described_class).not_to be_enabled }

    with_versioning do
      it "has versioning on by default" do
        expect(described_class).to be_enabled
      end
    end
    it "does not leak the `enabled?` state into successive tests" do
      expect(described_class).not_to be_enabled
    end
  end

  describe ".version" do
    it "returns the expected String" do
      expect(described_class.version).to eq(described_class::VERSION::STRING)
    end
  end

  describe 'deprecated methods' do
    shared_examples 'it delegates to request' do |method, args|
      it do
        expect(ActiveSupport::Deprecation).to receive(:warn)
        arguments = args || [no_args]
        expect(PaperTrail.request).to receive(method).with(*arguments)
        PaperTrail.public_send(method, *args)
      end
    end

    it_behaves_like 'it delegates to request', :clear_transaction_id, nil
    it_behaves_like 'it delegates to request', :enabled_for_controller=, [true]
    it_behaves_like 'it delegates to request', :enabled_for_model, [Widget, true]
    it_behaves_like 'it delegates to request', :enabled_for_model?, [Widget]
    it_behaves_like 'it delegates to request', :whodunnit=, [:some_whodunnit]
    it_behaves_like 'it delegates to request', :whodunnit, nil
    it_behaves_like 'it delegates to request', :controller_info=, [:some_whodunnit]
    it_behaves_like 'it delegates to request', :controller_info, nil
    it_behaves_like 'it delegates to request', :transaction_id=, 123
    it_behaves_like 'it delegates to request', :transaction_id, nil

    describe 'whodunnit' do
      context 'with block' do
        it 'delegates to request' do
          expect(ActiveSupport::Deprecation).to receive(:warn)
          expect(PaperTrail.request).to receive(:with) do |*args, &block|
            expect(args).to eq([{:whodunnit=>:some_whodunnit}])
            expect(block.call).to eq :some_block
          end
          PaperTrail.whodunnit(:some_whodunnit) { :some_block }
        end
      end

      context 'invalid arguments' do
        it 'raises an error' do
          expect{PaperTrail.whodunnit(:some_whodunnit)}.to raise_error(ArgumentError) do |e|
            expect(e.message).to eq "Invalid arguments"
          end
        end
      end
    end
  end
end
