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

echo "-- Docker info --"
echo "CMD: $@"
echo ""

echo "-- OpenVPN --"

## Init openvpn
echo "Initialize..."
if [[ ! -f /etc/openvpn/.config.lock ]]; then
  ovpn_genconfig -u udp://${EXTERNAL_ADDRESS:-0.0.0.0} -n ${DNS_IP:-8.8.8.8}
  touch /etc/openvpn/.config.lock
fi

echo "Waiting passphrase..."
while [[ ! -f /etc/openvpn/pki/ta.key ]]; do sleep 2; done

echo "Waiting DNS..."
while [[ ! -f "/etc/openvpn/pki/issued/${EXTERNAL_ADDRESS}.crt" ]]; do sleep 2; done

echo "Client forwarding..."
if [[ -n "${CLIENT_FORWARD}" ]]; then
  IFS=',' read -r -a rules <<< "${CLIENT_FORWARD}"
  for rule in "${rules[@]}"; do
    host="$(echo ${rule} | cut -s -d':' -f1)"
    port="$(echo ${rule} | cut -s -d':' -f2)"
    plan="socat -v tcp-listen:${port:-21},reuseaddr,fork tcp:${host:-0.0.0.0}:${port:-21}"
    echo "FORWARD: ${plan}"
    ${plan} &
  done
fi

## Start foreground server
echo "Server is ready!"
ovpn_run
