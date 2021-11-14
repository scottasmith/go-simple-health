# Go simeple health
This go application does nothing more that return 'working 😀' with a HTTP status code 200.

That is it, nothing more and nothing less.

# Uses
I mainly created it to use with a Kubernetes Ingress to use with HAProxy external Ingress proxy(s) and keepalived.

You can use vrrp with keepalived to keep two proxy servers running side by side and if the master one falls the backup will take over as they both know about the same IP.
Keepalive can be configured to check that the haproxy (or haproxy-ingress) is up, but it doesn't check that its setup after it starts back up.
This leads to 503 pages (Service Unavailable) until it reaches out to the Kubernetes API and sets itself up.

The following demonstrates using this image to return a simple 200 response to use with a keepalived `vrrp_script`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cluster-healthz
  namespace: default
  labels:
    app: cluster-healthz
spec:
  selector:
    matchLabels:
      app: cluster-healthz
  template:
    metadata:
      labels:
        app: cluster-healthz
    spec:
      containers:
        - name: cluster-healthz
          image: scottsmith/go-simple-health:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: cluster-healthz
  namespace: default
  labels:
    app: cluster-healthz
spec:
  ports:
    - port: 8080
      protocol: TCP
  selector:
    app: cluster-healthz
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: cluster-healthz
  namespace: default
  annotations:
    # Whitelist only internal IP's on subnet 102.168.0.0
    haproxy.org/whitelist: "192.168.0.0/24"
spec:
  rules:
    - http:
        paths:
          - path: /my-cluster-healthz
            pathType: ImplementationSpecific
            backend:
              service:
                name: cluster-healthz
                port:
                  number: 8080
```

