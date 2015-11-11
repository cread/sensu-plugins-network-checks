#!/usr/bin/awk -f 
#
# TCP socket state metrics
# ===
#
# Fetch metrics on TCP socket states from netstat. This is particularly useful
# on high-traffic web or proxy servers with large numbers of short-lived TCP
# connections coming and going.
#
# Example
# -------
#
# $ ./metrics-netstat-tcp.awk -v scheme=servers.hostname < /proc/net/tcp
#  servers.hostname.UNKNOWN      0     1350496466
#  servers.hostname.ESTABLISHED  235   1350496466
#  servers.hostname.SYN_SENT     0     1350496466
#  servers.hostname.SYN_RECV     1     1350496466
#  servers.hostname.FIN_WAIT1    0     1350496466
#  servers.hostname.FIN_WAIT2    53    1350496466
#  servers.hostname.TIME_WAIT    10640 1350496466
#  servers.hostname.CLOSE        0     1350496466
#  servers.hostname.CLOSE_WAIT   7     1350496466
#  servers.hostname.LAST_ACK     1     1350496466
#  servers.hostname.LISTEN       16    1350496466
#  servers.hostname.CLOSING      0     1350496466
#
# Acknowledgements
# ----------------
# - Inspired by the metrics-netstat-tcp.rb plugin from Joe Miller <https://github.com/joemiller>
#
# Copyright 2015 Chris Read <https://github.com/cread>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

BEGIN {
  name["01"] = "ESTABLISHED"
  name["02"] = "SYN_SENT"
  name["03"] = "SYN_RECV"
  name["04"] = "FIN_WAIT1"
  name["05"] = "FIN_WAIT2"
  name["06"] = "TIME_WAIT"
  name["07"] = "CLOSE"
  name["08"] = "CLOSE_WAIT"
  name["09"] = "LAST_ACK"
  name["0A"] = "LISTEN"
  name["0B"] = "CLOSING"

  for (st in name) {
    state[st] = 0
  }

  if (scheme == "") {
    "hostname" | getline scheme
    scheme = scheme ".os.tcp"
  }

  "date +%s" | getline stamp
}

$4 in name { 
  state[$4] += 1
}

END {
  for (st in name) {
    print scheme "." name[st] " " state[st] " " stamp
  }
}
