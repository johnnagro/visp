Feature: IPTunnel leases

In order to have zero-conf Internet access
As a leaf node
I want to use IPTunnel leases

Scenario: requesting a lease

Given a peer
 When I get announcements from the peer
  And I request a lease
 Then the IPTunnel server allows me to connect

Scenario: applying a lease

Given a lease
 When I apply the lease
 Then I can ping the gateway

Scenario: applying a lease with default route

Given a lease with default route
 When I apply the lease
 Then I can ping the internet

Scenario: restricting leases to peers only

Given a peer of a peer
  And restricted leases
 When I request a lease
 Then I don't get a lease

Scenario: maintaining connections on the server

Given 253 leases
 When I request a lease
 Then I don't get a lease

Scenario: failing over to another gateway

Given a lease with two gateways
  And I process the lease
 When I can't ping the first gateway
 Then I can ping the second gateway
  And I can ping the internet
