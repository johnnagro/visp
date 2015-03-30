# encoding: utf-8

require 'socket'
require 'bencode'
require 'digest'

module VISP
  class Cjdns
    CjdnsError = Class.new(StandardError)

    DEFAULT_INTERFACE = 'tun0'

    def initialize(options)
      @options = options
      @socket = UDPSocket.new
      @socket.connect(@options[:address], @options[:port])

      @debug = true
      call(:ping)
    end

    def call(func, args = nil)
      response = auth_send(func.to_s, args)

      if func == 'ping' && response['error'] != 'none'
        raise CjdnsError, response['error']
      end

      response
    end

    def interface
      @options[:interface] || DEFAULT_INTERFACE
    end

    # The rest is taken from cy's cjdns-lib which is MIT licensed.
    # Adapted to use a UDP socket instead of a TCP socket.
    # https://github.com/cyisfor/cjdns-lib/blob/c997f00dd2c8c6144839a10483cb727c19181ffd/lib/cjdns-lib/interface.rb#L137-L208

    # send an authenticated 'funcname' request to the admin interface
    #
    # @param [String] funcname
    # @param [Hash] args
    # @return [Hash]
    def auth_send(funcname, args)
      txid = get_txid

      # setup authenticated request if password given
      if @options[:password]
        cookie = get_cookie

        request = {
          'q' => 'auth',
          'aq' => funcname,
          'hash' => Digest::SHA256.hexdigest(@options[:password] + cookie),
          'cookie' => cookie,
          'txid' => txid
        }

        request['args'] = args if args
        request['hash'] = Digest::SHA256.hexdigest(BEncode.dump(request))

      # if no password is given, try request without auth
      else
        request = { 'q' => funcname, 'txid' => txid }
        request['args'] = args if args
      end

      response = send request
      raise 'wrong txid in reply' if response['txid'] and response['txid'] != txid
      response
    end

    # get a cookie from server
    #
    # @return [String]
    def get_cookie
      txid = get_txid
      response = send('q' => 'cookie', 'txid' => txid)
      raise 'wrong txid in reply' if response['txid'] and response['txid'] != txid
      response['cookie']
    end

    def get_txid
      rand(36**8).to_s(36)
    end

    # send a request to the admin interface
    #
    # @param [Hash] request
    # @return [Hash]
    def send(request)
      puts "flushing socket" if @debug
      @socket.flush

      puts "sending request: #{request.inspect}" if @debug
      @socket.send(BEncode.dump(request), 0)

      response = ''
      begin
        while r = @socket.recvfrom_nonblock(1024)
          response << r[0]
          break if r[0].length < 1024
        end
      rescue IO::EAGAINWaitReadable => ex
        retry
      end

      puts "bencoded reply: #{response.inspect}" if @debug
      response = BEncode.load(response)

      puts "bdecoded reply: #{response.inspect}" if @debug
      response
    end
  end
end
