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

X_OVPN_ENV="${OPENVPN}/ovpn_env.sh"
X_OVPN_CONF=${OPENVPN}/openvpn.conf
X_OVPN_AUTOCONF="${OPENVPN}/.autoconf"
X_OVPN_VERSION=$(openvpn --version | head -n1 | cut -d' ' -f2)

external_address=${EXTERNAL_ADDRESS:-0.0.0.0}
external_port=${EXTERNAL_PORT:-1194}

## Scripting server-side strategy
if [[ "$1" = "bash" ]]; then
  exec "$@"
  exit "$?"
fi

## Init openvpn
echo "Initialize..."
echo "Server version: ${X_OVPN_VERSION}"
echo "External address: ${external_address}"
echo "External port: ${external_port}"
echo "Looking for '${X_OVPN_ENV}'"
if [[ -f "${X_OVPN_ENV}" ]]; then
  echo "Testing configuration integrity"
  if grep -qE "declare -x OVPN_CN=${external_address}$" "${X_OVPN_ENV}"; then
    echo "Recreating configuration due to different external address"
    rm -fr "${X_OVPN_ENV}" "${X_OVPN_AUTOCONF}"
  elif grep -qE "declare -x OVPN_PORT=${external_port}$" "${X_OVPN_ENV}"; then
    echo "Recreating configuration due to different external port"
    rm -fr "${X_OVPN_ENV}" "${X_OVPN_AUTOCONF}"
  fi
fi

## Processing configuration
if [[ -f "${X_OVPN_ENV}" ]]; then
  echo "Use default configuration"
else
  echo "Loading extended configuration from environment variables"
  if [[ "${OVPN_DEFROUTE}" = "0" ]] && [[ "${#OVPN_PUSH[@]}" = "0" ]]; then
    OVPN_PUSH+=("route 0.0.0.0 128.0.0.0 net_gateway")
    OVPN_PUSH+=("route 128.0.0.0 128.0.0.0 net_gateway")
  fi
  (set | grep '^OVPN_') | while read -r var; do
    echo "declare -x $var" >> "${X_OVPN_ENV}"
  done
fi

## Processing autoconfig
if [[ -f "${X_OVPN_AUTOCONF}" ]]; then
  echo "Autoconfig already done"
else
  echo "Processing autoconfig..."
  #ovpn_genconfig -u udp://${external_address} -n ${DNS_IP:-8.8.8.8}
  ovpn_genconfig -u udp://${external_address}:${external_port}
  echo "explicit-exit-notify 1" >> ${X_OVPN_CONF}
  touch "${X_OVPN_AUTOCONF}"
fi

## Waiting passphrase
echo "Waiting passphrase..."
while [[ ! -f /etc/openvpn/pki/ta.key ]]; do sleep 2; done

## Waiting DNS
echo "Waiting DNS..."
while [[ ! -f "/etc/openvpn/pki/issued/${external_address}.crt" ]]; do sleep 2; done

## Client forwarding
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
