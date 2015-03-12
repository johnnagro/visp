# encoding: utf-8

require 'visp/cjdns'
require 'visp/server'

class VISP
  # @param cjdns [VISP::Cjdns] The admin API
  # @param journal [File] The leases journal
  def initialize(cjdns, journal)
    @cjdns = cjdns
    @journal, @leases = journal, {}
  end

  def replay_journal
  end

  def append_to_journal(public_key, lease)
  end

  def maintain_leases
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
end
