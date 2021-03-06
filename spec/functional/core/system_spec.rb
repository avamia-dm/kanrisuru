# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::System do
  TestHosts.each_os do |os_name|
    context "with #{os_name}" do
      let(:host_json) { TestHosts.host(os_name) }
      let(:host) do
        Kanrisuru::Remote::Host.new(
          host: host_json['hostname'],
          username: host_json['username'],
          keys: [host_json['ssh_key']]
        )
      end

      after do
        host.disconnect
      end

      it 'gets environment variables' do
        result = host.load_env

        expect(result.success?).to be(true)
        expect(result.data).to be_instance_of(Hash)
      end

      it 'gets uptime' do
        result = host.uptime
        expect(result.success?).to eq(true)

        expect(result).to respond_to(
          :boot_time, :uptime, :seconds,
          :hours, :minutes, :days
        )

        expect(result.seconds).to be > 0
        expect(result.minutes).to be >= 0
        expect(result.hours).to be >= 0
        expect(result.days).to be >= 0
      end

      it 'kills pids' do
        command = 'sleep 100000 > /dev/null 2>&1 &'

        host.execute_shell("nohup #{command}")
        result = host.ps(user: host_json['username'])
        expect(result.success?).to eq(true)

        process = result.select do |proc|
          proc.command == 'sleep 100000'
        end

        pids = process.map(&:pid)
        result = host.kill('SIGKILL', pids)
        expect(result.success?).to eq(true)

        result = host.ps(user: host_json['username'])
        process = result.select do |proc|
          proc.command == 'sleep 100000'
        end

        expect(process).to be_empty
      end

      it 'gets process details' do
        result = host.ps

        expect(result.data).to be_instance_of(Array)
        process = result[0]

        expect(process).to respond_to(
          :uid, :user, :gid, :group,
          :pid, :ppid, :cpu_usage, :memory_usage,
          :stat, :priority, :flags, :policy_abbr, :policy,
          :cpu_time, :command
        )

        result = host.ps(user: [host_json['username']])

        expect(result.data).to be_instance_of(Array)

        process = result.find do |proc|
          proc.command == result.command.raw_command
        end

        expect(process.command).to eq(result.command.raw_command)
      end

      it 'gets information for users' do
        result = host.who
        expect(result.success?).to eq(true)
      end
    end
  end
end
