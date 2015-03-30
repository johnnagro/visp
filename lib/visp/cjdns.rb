# encoding: utf-8

module VISP
  class Cjdns
    DEFAULT_INTERFACE = 'tun0'

    def initialize(options)
      @options = options
    end

    def interface
      @options[:interface] || DEFAULT_INTERFACE
    end
  end
end
