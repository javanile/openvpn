#!/usr/bin/env bash
set -e

##
# OpenVPN
#
# Best free VPN server for Docker
#
# Copyright (c) 2020 Francesco Bianco <bianco@javanile.org>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
##

## Init openvpn
echo "Initialize..."
if [[ ! -f /etc/openvpn/.config.lock ]]; then
  echo ovpn_genconfig -u udp://${EXTERNAL_ADDRESS:-0.0.0.0} -n ${DNS_IP:-0.0.0.0}
  ovpn_genconfig -u udp://${EXTERNAL_ADDRESS:-0.0.0.0} -n ${DNS_IP:-0.0.0.0}
  touch /etc/openvpn/.config.lock
fi

echo ">>> Waiting Passphrase"
while [[ ! -f /etc/openvpn/pki/ta.key ]]; do echo -n "."; sleep 2; done; echo "."

echo "IP"
while [[ ! -f "/etc/openvpn/pki/issued/${EXTERNAL_ADDRESS}.crt" ]]; do echo -n "."; sleep 2; done; echo "."


## Start foreground server
echo "Server Ready"
ovpn_run
