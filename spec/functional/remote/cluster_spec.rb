# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Remote::Cluster do
  context 'with ubuntu' do
    it 'gets hostname for cluster' do
      cluster = described_class.new([{
                                      host: 'localhost',
                                      username: 'ubuntu',
                                      keys: ['~/.ssh/id_rsa']
                                    }, {
                                      host: '127.0.0.1',
                                      username: 'ubuntu',
                                      keys: ['~/.ssh/id_rsa']
                                    }])

      expect(cluster.hostname).to match([
                                          { host: 'localhost', result: 'ubuntu' },
                                          { host: '127.0.0.1', result: 'ubuntu' }
                                        ])

      cluster.disconnect
    end

    it 'can ping host cluster' do
      cluster = described_class.new([{
                                      host: 'localhost',
                                      username: 'ubuntu',
                                      keys: ['~/.ssh/id_rsa']
                                    }, {
                                      host: '127.0.0.1',
                                      username: 'ubuntu',
                                      keys: ['~/.ssh/id_rsa']
                                    }])

      expect(cluster.ping?).to match([
                                       { host: 'localhost', result: true },
                                       { host: '127.0.0.1', result: true }
                                     ])

      cluster.disconnect
    end
  end
end
