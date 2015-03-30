# encoding: utf-8

module VISP
  class Tunnel
    def initialize(options)
      @options = options
    end

    def run
      ip "addr #{@options[:interface]} #{address}"
      ip "route #{@options[:interface]} #{@options[:network]}"
      ip "nat #{@options[:interface]} #{@options[:forward]}"
    end

    def address
      sh "ipcalc -n -b #{@options[:network]} | grep 'HostMin' | tr -d '[[:space:]]' | cut -d':' -f2"
    end

    def ip(args)
      path = File.expand_path('../../../bin/visp-ip', __FILE__)
      puts "sudo --non-interactive --reset-timestamp -- #{path} #{args}"
    end

    def sh(command)
      `#{command}`
    end
  end
end
