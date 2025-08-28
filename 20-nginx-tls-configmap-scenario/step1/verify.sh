#!/bin/bash

# Allow a few seconds for the NGINX pods to restart and load the new config
sleep 10

# Test that TLSv1.2 connection fails. We expect a non-zero exit code.
echo "Verifying that TLSv1.2 connection fails..."
if curl -k --resolve web.k8s.local:443:127.0.0.1 https://web.k8s.local --tls-max 1.2 --connect-timeout 5 &> /tmp/tls_test.log; then
    echo "Verification FAILED: Connection with TLSv1.2 succeeded but should have failed."
    exit 1
fi

# Check for a specific TLS handshake failure message in the curl output
if ! grep -q "alert handshake failure" /tmp/tls_test.log; then
    echo "Verification FAILED: Connection using TLSv1.2 did not fail with the expected handshake error."
    exit 1
fi

echo "OK: TLSv1.2 connection correctly failed as expected."

# Test that TLSv1.3 connection succeeds. We expect a zero exit code.
echo "Verifying that TLSv1.3 connection succeeds..."
if ! curl -k --resolve web.k8s.local:443:127.0.0.1 https://web.k8s.local --tls-min 1.3 --connect-timeout 5 > /dev/null 2>&1; then
    echo "Verification FAILED: Connection with TLSv1.3 failed but should have succeeded."
    exit 1
fi

echo "OK: TLSv1.3 connection correctly succeeded."

echo "done"
exit 0
