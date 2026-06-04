# Week 5 — Day 4 Answers

---

## Block 0 — Weekly Review

`matchExpressions` NP peer (rotate from `matchLabels`):
```yaml
  ingress:
    - from:
        - podSelector:
            matchExpressions:
              - key: role
                operator: In
                values: [frontend, worker]
```
Operators: `In`, `NotIn`, `Exists`, `DoesNotExist`. `Exists`/`DoesNotExist` take no `values:`.

---

## Block 1 — projected volume

Create sources first:
```bash
kubectl create configmap proj-cm --from-literal=app.conf="debug=true"
kubectl create secret generic proj-sec --from-literal=token=s3cr3t
```

`projected.yaml`:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: proj
spec:
  containers:
    - name: app
      image: busybox
      command: ["sleep", "3600"]
      volumeMounts:
        - name: all
          mountPath: /etc/all
          readOnly: true
  volumes:
    - name: all
      projected:
        sources:
          - configMap:
              name: proj-cm
          - secret:
              name: proj-sec
          - downwardAPI:
              items:
                - path: pod_name
                  fieldRef:
                    fieldPath: metadata.name
```
```bash
kubectl exec proj -- ls /etc/all              # app.conf  token  pod_name
kubectl exec proj -- cat /etc/all/pod_name    # proj
```
Shape: one `projected.sources:` list; each item is `configMap` / `secret` / `downwardAPI` / `serviceAccountToken`. No per-source `volumes:` entries — that's the whole point of `projected`.

---

## Block 2 — Dockerfile + CMD vs ENTRYPOINT

`app/hello.sh`:
```sh
#!/bin/sh
echo "hello ${1:-there}"     # echoes its first arg, so CMD/runtime args are observable
```
`app/Dockerfile`:
```dockerfile
FROM busybox
COPY hello.sh /hello.sh
RUN chmod +x /hello.sh
EXPOSE 8080                  # metadata only — documents the port, publishes nothing
ENTRYPOINT ["/hello.sh"]
CMD ["world"]                # default arg → "hello world"; `docker run img bob` → "hello bob"
```
`CMD ["world"]` is the default arg passed to the entrypoint. A runtime arg (or pod `args:`) replaces it; `ENTRYPOINT` stays. So the image prints `hello world` by default, `hello bob` if you override the arg.

**Answers:**
1. `ENTRYPOINT ["echo"]` + `CMD ["hello"]` → runs `echo hello`. CMD provides the **default args** appended to ENTRYPOINT. Start the container with `goodbye` → CMD is replaced → runs `echo goodbye`. (ENTRYPOINT stays; runtime args replace CMD.)
2. Pod `command:` overrides the image **ENTRYPOINT**; pod `args:` overrides the image **CMD**. (Mnemonic: command→ENTRYPOINT, args→CMD.)
3. `command: ["sleep 3600"]` is wrong — it looks for a binary literally named `sleep 3600` (one token). Right: `command: ["sleep", "3600"]` — argv, one token per element. `sh -c` only for shell features (`>`, `|`, `&&`, `$VAR`).

| Image (Dockerfile) | Pod override | Result |
|---|---|---|
| `ENTRYPOINT ["/app"]` `CMD ["--port=80"]` | (none) | `/app --port=80` |
| same | `args: ["--port=9090"]` | `/app --port=9090` |
| same | `command: ["/other"]` | `/other` (CMD dropped) |

---

## Block 3 — Build + kind load + run

```bash
docker build -t hello-app:v1 ./app
docker images | grep hello-app
kind load docker-image hello-app:v1        # push into the kind node(s)
```

`hello-pod.yaml`:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-pod
spec:
  restartPolicy: Never                     # it echoes once and exits
  containers:
    - name: hello
      image: hello-app:v1                  # non-latest tag
      imagePullPolicy: IfNotPresent        # don't try Docker Hub for a local image
```
```bash
kubectl apply -f yaml-practice/hello-pod.yaml
kubectl logs hello-pod                      # hello world  (CMD default arg; ENTRYPOINT + CMD)
```
If you see `ErrImagePull`/`ImagePullBackOff`: you either skipped `kind load`, used `:latest`, or left `imagePullPolicy: Always`. Fix the tag + policy, re-`kind load`, recreate the pod.

---

## Block 4 — Interpretation drill

- **A** → a `projected` volume with `configMap` + `secret` + `downwardAPI` sources.
- **B** → `command:` (overrides ENTRYPOINT) + `args:` (overrides CMD).
- **C** → (1) `kind load docker-image myimg:v2`; (2) pod uses the `:v2` tag + `imagePullPolicy: IfNotPresent`/`Never`.
- **D** → `command: ["sleep", "3600"]`.

---

## Block 5 — explain notes

- `projected.sources[]`: `configMap`, `secret`, `downwardAPI`, `serviceAccountToken`.
- `command` = argv overriding ENTRYPOINT; `args` = argv overriding CMD.
- `imagePullPolicy`: `Always` (default for `:latest` or no tag), `IfNotPresent`, `Never`.
