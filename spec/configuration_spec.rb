require 'spec_helper'

RSpec.describe Uninterruptible::Configuration do
  include EnvironmentalControls

  let(:configuration) { described_class.new }

  describe "#bind" do
    it 'falls back to a TCP address with #bind_address and #bind_port' do
      configuration.bind_port = 1024
      configuration.bind_address = '127.0.0.2'

      expect(configuration.bind).to eq('tcp://127.0.0.2:1024')
    end

    it 'returns the value set by #bind=' do
      configuration.bind = "unix:///tmp/server.sock"
      expect(configuration.bind).to eq("unix:///tmp/server.sock")
    end
  end

  describe "#bind_port" do
    it "falls back to PORT in ENV when unset" do
      within_env("PORT" => "1000") do
        expect(configuration.bind_port).to eq(1000)
      end
    end

    it "raises an exception when no port is set" do
      expect { configuration.bind_port }.to raise_error(Uninterruptible::ConfigurationError)
    end

    it "returns the value set by bind_port=" do
      # PORT should be ignored as it is superceded by bind_port=
      within_env("PORT" => "1000") do
        configuration.bind_port = 1001
        expect(configuration.bind_port).to eq(1001)
      end
    end
  end

  describe "#bind_address" do
    it 'defaults to 0.0.0.0 if unset' do
      expect(configuration.bind_address).to eq('0.0.0.0')
    end

    it 'returns the value set by bind_address=' do
      configuration.bind_address = '127.0.0.1'
      expect(configuration.bind_address).to eq('127.0.0.1')
    end
  end

  describe "#pidfile_path" do
    it 'falls back to PID_FILE in ENV whjen unset' do
      within_env("PID_FILE" => "/tmp/server.pid") do
        expect(configuration.pidfile_path).to eq("/tmp/server.pid")
      end
    end

    it 'returns the value set by pidfile_path=' do
      # PID_FILE should be ignored since it is superceded by pidfile_path=
      within_env("PID_FILE" => "/tmp/server.pid") do
        configuration.pidfile_path = '/tmp/server2.pid'
        expect(configuration.pidfile_path).to eq("/tmp/server2.pid")
      end
    end
  end

  describe "#start_command" do
    it 'returns the value set by start_command=' do
      configuration.start_command = 'rake myapp:run'
      expect(configuration.start_command).to eq('rake myapp:run')
    end

    it 'raises an exception when unset' do
      expect { configuration.start_command }.to raise_error(Uninterruptible::ConfigurationError)
    end
  end

  describe '#log_path' do
    it 'returns the value set by log_path=' do
      configuration.log_path = 'log/server.log'
      expect(configuration.log_path).to eq('log/server.log')
    end

    it 'defaults to STDOUT when unset' do
      expect(configuration.log_path).to eq(STDOUT)
    end
  end

  describe "#log_level" do
    it 'returns the value set by log_level=' do
      configuration.log_level = Logger::FATAL
      expect(configuration.log_level).to eq(Logger::FATAL)
    end

    it 'defaults to Logger::INFO when unset' do
      expect(configuration.log_level).to eq(Logger::INFO)
    end
  end
end
