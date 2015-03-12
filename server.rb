# encoding: utf-8

require 'httpkit'
require 'oj'

class VISP
  def initialize(options)
    @leases = {}
    @cjdns = Cjdns.new(options)
    replay_journal(options[:journal])
  end

  def replay_journal(journal)
  end

  def append_to_journal(lease)

  def knock(ipv6)
    return false if full?
    ipv4_address = acq
    @cjdns.allow_connection(@cjdns.public_key_for(ipv6), ipv4_address)
    update_last_seen
    true
  end

  def lease(ipv6)
    { ipv4_address: '172.23.23.2/24',
      routes: ['0.0.0.0/0', '172.23.23.0/24'],
      gateways: ['172.23.23.1'] }
  end

  def full?
    false
  end
end

class VISPServer
  def initialize(visp)
    @visp = visp
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

  def tunnels_response
    json_response(200, [
      { publicKey: 'asdf.k',
        routes: ['0.0.0.0/0', '172.23.23.0/24'],
        gateways: ['172.23.23.1'] }
    ])
  end

  def knock_response(request)
    if request.post? && !@visp.knock(request.remote_addr)
      json_response(503, { error: 'server full' })
    else
      json_response(200, @visp.lease(request.remote_addr))
    end
  end

  def not_found_response(request)
    json_response(404, { error: sprintf("%s not found\n", request.uri) })
  end

  def json_response(status, body)
    headers = { 'Content-Type' => 'application/json' }
    HTTPkit::Response.new(status, headers, Oj.dump(body))
  end
end

HTTPkit.start do
  visp = VISP.new(address: '127.0.0.1', port: 11234, password: 'foo')
  HTTPkit::Server.start(address: 'fc06:c135:28a5:8c0b:dd4e:bcb6:d4d6:c96d',
                        port: 3000,
                        handlers: [VISPServer.new(visp)])

  EM.add_periodic_timer(5) do
    Fiber.new { visp.evict_dead_leases }.resume
  end
end
