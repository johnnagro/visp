# encoding: utf-8

module VISP
  class Tunnel
    def initialize(cjdns, options)
      @cjdns = cjdns
      @options = options
    end

    def run
      ip "addr #{@cjdns.interface} #{address}"
      ip "route #{@cjdns.interface} #{@options[:network]}"
      ip "nat #{@cjdns.interface} #{@options[:forward]}"
    end

    def address
      sh "ipcalc -n -b #{@options[:network]} | grep 'HostMin' | tr -d '[[:space:]]' | cut -d':' -f2"
    end

    def ip(args)
      path = File.expand_path('../../../bin/visp-ip', __FILE__)
      sh "sudo --non-interactive --reset-timestamp #{path} #{args}"
    end

    def sh(command)
      puts command
      `#{command}`
    end
  end
end
