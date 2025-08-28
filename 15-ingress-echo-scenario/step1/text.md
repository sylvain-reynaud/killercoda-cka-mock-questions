An `echoserver-service` has been deployed in the `echo-sound` namespace and needs to be exposed to external traffic.

Your task is to create an `Ingress` resource to route traffic to this service.

**Task:**

1.  Create a new `Ingress` resource named `echo` in the `echo-sound` namespace.
2.  Configure the Ingress to handle requests for the host `example.org`.
3.  Route traffic for the path `/echo` to the `echoserver-service` on its service port `8080`.

After applying your Ingress, the following command should return a `200` HTTP status code:
`curl -o /dev/null -s -w "%{http_code}\n" http://example.org/echo`
