A legacy application running in the `synergy-deployment` writes its logs to a file instead of to standard output. To integrate it with Kubernetes' built-in logging, you need to add a sidecar container to stream its log file.

**Task:**

Update the existing `synergy-deployment` by adding a co-located container that meets the following requirements:

1.  The new container must be named `sidecar`.
2.  It must use the `busybox:stable` image.
3.  It must run the command: `/bin/sh -c "tail -n+1 -f /var/log/synergy-deployment.log"`.
4.  Use a shared `Volume` mounted at `/var/log` to make the `synergy-deployment.log` file available to both the main container and the sidecar.
5.  Do not modify the specification of the existing `synergy-app` container, other than adding the required volume mount.
