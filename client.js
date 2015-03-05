var CJDNS_DIR = '/home/lars/workspace/cjdns';
var RETRY_INTERVAL = 1000;

var Cjdns = require(CJDNS_DIR + '/contrib/nodejs/cjdnsadmin/cjdnsadmin');
var nThen = require(CJDNS_DIR + '/contrib/nodejs/cjdnsadmin/nthen');

var main = function(argv) {

    var cjdns;
    nThen(function(waitFor) {

        Cjdns.connectWithAdminInfo(waitFor(function(c) { cjdns = c; }));

    }).nThen(function(waitFor) {

        var listConnections = function() {
            cjdns.IpTunnel_listConnections(waitFor(function(err, ret) {
                if (err) { throw err; }

                if (ret.connections.length > 0) {
                    var conn = parseInt(ret.connections[0]);
                    cjdns.IpTunnel_showConnection(conn, waitFor(function(err, ret) {
                        console.log('ipv4', ret.ip4Address + '/' + (32 - parseInt(ret.ip4Prefix)));
                        console.log('direction', (ret.outgoing == '1') ? 'outgoing' : 'incoming');
                        console.log('pubkey', ret.key);
                    }));
                } else {
                    console.log('Waiting for IPTunnel connection...');
                    setTimeout(waitFor(listConnections), RETRY_INTERVAL);
                }
            }));
        };

        listConnections();

    }).nThen(function(waitFor) {

        cjdns.disconnect();

    });
};

main(process.argv);
