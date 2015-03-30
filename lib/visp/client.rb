# encoding: utf-8

require 'httpkit'
require 'oj'

module VISP
  class Client
    Connection = Struct.new(:server, :direction, :ipv4, :ipv4_prefix) do
      def outgoing?
        direction == 'out'
      end
    end

    def initialize(cjdns, options)
      @cjdns = cjdns
      @options = options
    end

    def run
      conn = connections.first
      net, gw = network(conn), gateway(conn)

      ip "addr #{@cjdns.interface} #{conn[:ipv4]}"

      if net == '0.0.0.0/0'
        # traffic to UDP peers needs to stay outside the tunnel, add host routes
        @options[:peers].each { |ipv4| ip "gw #{ipv4} #{@options[:original_gateway]}" }

        # send all other traffic through the tunnel
        ip "route #{@cjdns.interface} #{net}"
        ip "gw default #{gw}"
      else
        ip "route #{@cjdns.interface}"
      end
    end

    def connections
      sh("#{@options[:dir]}/tools/iptunnel -t -1").each_line
        .map { |line| Connection.new(*line.split(/\s+/)) }
        .select(&:outgoing?)
    end

    def network(conn)
      sh("ipcalc -n -b #{conn.ipv4}/#{conn.ipv4_prefix} | grep Network" +
        " | tr -d '[[:space:]]' | cut -d':' -f2").strip
    end

    def gateway(conn)
      sh("ipcalc -n -b #{conn.ipv4}/24 | grep HostMin" +
        " | tr -d '[[:space:]]' | cut -d':' -f2").strip
    end

    def ip(args)
      path = File.expand_path('../../../bin/visp-ip', __FILE__)
      sh "sudo --non-interactive --reset-timestamp #{path} #{args}"
    end

    def sh(command)
      `#{command}`
    end

    def maintain_tunnels
      $stderr.puts 'VISP::Client#maintain_tunnels'
    end
  end
end
