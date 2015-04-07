# encoding: utf-8

require 'httpkit'
require 'oj'

module VISP
  class Client
    Connection = Struct.new(:server, :direction, :ipv4, :ipv4_prefix) do
      def outgoing?
        direction == 'out'
      end

      def lease?
        ipv4 != '-'
      end
    end

    def initialize(cjdns, options)
      @cjdns = cjdns
      @options = options
    end

    def run
      announcements.each do |tunnel|
        @cjdns.call(:IpTunnel_connectTo, publicKeyOfNodeToConnectTo: tunnel[:public_key])
      end

      conn = connections.first
      net, gw = network(conn), gateway(conn)

      ip "addr #{@cjdns.interface} #{conn[:ipv4]}"

      if net == '0.0.0.0/0'
        # traffic to UDP peers needs to stay outside the tunnel, add host routes
        @options[:peers].each { |ipv4| ip "gw #{ipv4} #{@options[:original_gateway]}" }

        # send all other traffic through the tunnel
        ip "route #{@cjdns.interface} #{gw}/32"
        ip "gw default #{gw}"
      else
        ip "route #{@cjdns.interface} #{net}"
      end
    end

    def announcements
      [{ public_key: 'qphnptqz9zv5tupr67njnsjtqtj62spun26798kuw3kq2hwlgu80.k' }]
    end

    def connections
      sh("#{@options[:dir]}/tools/iptunnel -t -1").each_line
        .map { |line| Connection.new(*line.split(/\s+/)) }
        .select(&:outgoing?).select(&:lease?)
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
      puts command
      `#{command}`
    end

    def maintain_tunnels
    end
  end
end
