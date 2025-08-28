You have an existing web application deployed in the `gateway-migration` namespace, exposed via a standard `Ingress` resource named `web`. Your task is to migrate this configuration to the new Kubernetes Gateway API.

**Note**: A `GatewayClass` named `nginx-class` is already available in the cluster.

**Tasks:**

1.  **Create a Gateway**: Create a `Gateway` resource named `web-gateway` that:
    *   Uses the `nginx-class` `GatewayClass`.
    *   Listens on port `443` for `HTTPS` traffic.
    *   Uses the existing `web-tls` secret for its TLS termination.
    *   Specifies the hostname `gateway.web.k8s.local`.

2.  **Create an HTTPRoute**: Create an `HTTPRoute` resource named `web-route` that:
    *   Attaches to the `web-gateway` Gateway.
    *   Matches the hostname `gateway.web.k8s.local`.
    *   Routes traffic for the path `/` to the `web-service` on port `80`.
