#!/usr/bin/env node
/* -*- Mode:js */
/* vim: set expandtab ts=4 sw=4: */
/*
 * You may redistribute this program and/or modify it under the terms of
 * the GNU General Public License as published by the Free Software Foundation,
 * either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

var CJDNS_DIR = '/home/lars/workspace/cjdns';
var RETRY_INTERVAL = 1000;
var TUN = 'tun0';

var Cjdns = require(CJDNS_DIR + '/contrib/nodejs/cjdnsadmin/cjdnsadmin');
var nThen = require(CJDNS_DIR + '/contrib/nodejs/cjdnsadmin/nthen');
var Spawn = require('child_process').spawn;

var main = function(argv) {

    var cjdns;
    nThen(function(waitFor) {

        Cjdns.connectWithAdminInfo(waitFor(function(c) { cjdns = c; }));

    }).nThen(function(waitFor) {

        var setupRoutes = function(conn) {
            var route = conn.ip4Address + '/' + parseInt(conn.ip4Prefix);

            console.log('ipv4', route);
            console.log('direction', (conn.outgoing == '1') ? 'outgoing' : 'incoming');
            console.log('pubkey', conn.key);

            var args = ['route', 'add', 'dev', TUN, route];
            var ip = Spawn('ip', args, {stdio: 'inherit'});
            ip.on('error', function(err) {
                waitFor.abort();
                throw err;
            });
            ip.on('close', waitFor(function(code) {
                if (code == 0) {
                    console.log('Added ' + route + ' via ' + TUN);
                } else {
                    throw new Error('ip route exited with ' + code);
                }
            }));
        };

        var listConnections = function() {
            cjdns.IpTunnel_listConnections(waitFor(function(err, ret) {
                if (err) { throw err; }

                if (ret.connections.length > 0) {
                    var conn = parseInt(ret.connections[0]);
                    cjdns.IpTunnel_showConnection(conn, waitFor(function(err, ret) {
                        if (err) { throw err; }
                        setupRoutes(ret);
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
