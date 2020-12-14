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

if [[ -z "${1}" ]]; then
	echo "ERROR: You must supply a username"
	exit 1
fi

if [[ -n "${2}" ]]; then
	case ${2} in
		"ubuntu")
			EXTRA_OPTS+="script-security 2\n"
			EXTRA_OPTS+="up /etc/openvpn/update-systemd-resolved\n"
			EXTRA_OPTS+="down /etc/openvpn/update-systemd-resolved"
			;;
		*)
			echo "ERROR: Unknown option ${2}"
			exit 1
			;;
	esac
fi

ovpn_getclient ${1}

if [[ ${#EXTRA_OPTS} -gt 0 ]]; then
	echo -e ${EXTRA_OPTS}
fi
