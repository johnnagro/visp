# encoding: utf-8

require 'httpkit'
require 'oj'

module VISP
  class Leases
    def initialize(cjdns, options)
      @cjdns = cjdns
      @journal = {}
      @options = options
    end

    def replay_journal
    end

    def append_to_journal(public_key, lease)
    end

    # TODO
    def acq
      '172.23.23.2/24'
    end

    def knock(ipv6)
      return false if full?
      ipv4_address = acq
      @cjdns.allow_connection(@cjdns.public_key_for(ipv6), ipv4_address)
      update_last_seen
      true
    end

    def lease(ipv6)
      { 'ipv4_address' => '172.23.23.2/24',
        'routes' => ['0.0.0.0/0', '172.23.23.0/24'],
        'gateways' => ['172.23.23.1'] }
    end

    def full?
      false
    end

    def run
      HTTPkit::Server.start(address: @options[:address],
                            port: @options[:port],
                            handlers: [self])
    end

    def maintain_leases
    end

    def serve(request, served)
      served.fulfill(response(request))
    end

    def response(request)
      case request.uri
      when '/tunnels' then tunnels_response
      when '/knock' then knock_response(request)
      else not_found_response(request)
      end
    end

    # TODO get public key
    def tunnels_response
      json_response(200, [
        { 'publicKey' => 'asdf.k',
          'routes' => ['0.0.0.0/0', '172.23.23.0/24'],
          'gateways' => ['172.23.23.1'] }
      ])
    end

    def knock_response(request)
      if request.post? && !self.knock(request.remote_addr)
        json_response(503, { 'error' => 'server full' })
      else
        json_response(200, self.lease(request.remote_addr))
      end
    end

    def not_found_response(request)
      json_response(404, { 'error' => sprintf("%s not found", request.uri) })
    end

    def json_response(status, body)
      headers = { 'Content-Type' => 'application/json' }
      HTTPkit::Response.new(status, headers, Oj.dump(body) + "\n")
    end
  end
end
