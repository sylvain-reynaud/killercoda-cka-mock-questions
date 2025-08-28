An NGINX deployment named `nginx-static` is running in the `nginx-static` namespace. It is configured using a ConfigMap named `nginx-config`.

Your task is to update the `nginx-config` ConfigMap to allow **only** TLSv1.3 connections.

You may need to re-create, restart, or scale the deployment for the changes to take effect.

To verify your changes, you can use the following command, which attempts a connection using TLSv1.2. Since TLSv1.2 should no longer be allowed, the command should fail:

`curl --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt --resolve web.k8s.local:443:$(kubectl get ingress nginx-ingress -n nginx-static -o jsonpath='{.status.loadBalancer.ingress[0].ip}') https://web.k8s.local --tls-max 1.2 -v`
