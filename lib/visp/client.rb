# encoding: utf-8

require 'httpkit'
require 'oj'

module VISP
  class Client
    def initialize(cjdns, options)
    end

    def run
      $stderr.puts 'VISP::Client#run'
    end

    def maintain_tunnels
      $stderr.puts 'VISP::Client#maintain_tunnels'
    end
  end
end
