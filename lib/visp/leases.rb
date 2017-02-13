# encoding: utf-8

require 'httpkit'
require 'oj'

module VISP
  class Leases
    def initialize(cjdns, visp, options)
      @cjdns = cjdns
      @visp = visp
      @options = options
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
      if request.post? && !@visp.knock(request.remote_addr)
        json_response(503, { 'error' => 'server full' })
      else
        json_response(200, @visp.lease(request.remote_addr))
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
