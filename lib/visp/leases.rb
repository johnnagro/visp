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

    # TODO
    def update_last_seen(ipv6, public_key)
    end

    def knock(ipv6, public_key)
      return false if full?
      ipv4_address = acq
      @cjdns.allow_connection(public_key, ipv4_address)
      update_last_seen(ipv6, public_key)
      true
    end

    def lease(ipv6, public_key)
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
      begin
        puts "#{Time.now} #{request.http_method} #{request.uri}"
        case request.uri
          when '/tunnels' then tunnels_response(request)
          when '/knock' then knock_response(request)
          else not_found_response(request)
        end
      rescue StandardError => e
        puts e.inspect
        json_response(500, { 'error' => 'Server error' })
      end
    end

    # TODO get public key
    def tunnels_response(request)
      json_response(200, [
        { 'publicKey' => 'asdf.k',
          'routes' => ['0.0.0.0/0', '172.23.23.0/24'],
          'gateways' => ['172.23.23.1'] }
      ])
    end

    def knock_response(request)
      if request.http_method != 'post'
        json_response(400, { 'error' => 'GET not supported' })
      end

      # body: { 'ipv6' : '::1', 'public_key' : 'asdf.k' }
      post_data = Oj.load(request.body)

      if !self.knock(post_data[:ipv6], post_data[:public_key])
        json_response(503, { 'error' => 'server full' })
      else
        json_response(200, self.lease(post_data[:ipv6], post_data[:public_key]))
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
