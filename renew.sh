#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "Usage: $0 /path/to/lego /path/to/cert example.com ca.url" >&2
  exit 1
fi

lego_path="$1"
cert_path="$2"
domain="$3"
ca_url="$4"

# Default is 30 days (30d * 24h * 60m * 60s)
threshold_seconds=$((30 * 24 * 60 * 60))

if [[ ! -f "$lego_path" ]]; then
  echo "Error: file not found: $lego_path" >&2
  exit 1
fi

if [[ ! -d "$cert_path" ]]; then
  echo "Error: file not found: $cert_path (assume first run)" >&2
fi

if [[ ! -f "$cert_path/$domain.crt" ]]; then
  echo "Error: certificate not found: $cert_path/$domain.crt (assuming new cert)" >&2
fi

# Check certificate file
if ! openssl x509 -in "$cert_path/$domain.crt" -noout -checkend "$threshold_seconds"; then
  echo "Certificate file expires within 30 days (or is expired): $cert_path. LETS RENEW!"
  
  # Request the certificate
  $lego_path --server=$ca_url --accept-tos -domains $domain --key-type rsa2048 --http --http.webroot /share/Web --email=admin@$domain run
  cat $cert_path/$domain.key $cert_path/$domain.crt > $cert_path/$domain.pem
  cp $cert_path/$domain.pem /etc/stunnel/stunnel.pem
  
  # Restart both of the QNAP HTTP Services
  /etc/init.d/Qthttpd.sh restart
  /etc/init.d/stunnel.sh restart

fi

