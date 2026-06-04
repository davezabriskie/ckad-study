# Week 5 — Day 4 (Friday June 5)

**Total time**: ~75 min | `projected` volumes + container image block (Dockerfile → build → kind load → run)

> Closes the ephemeral-volume set with `projected` (the combiner), then opens the **container image** thread — the heaviest net-new tooling of the week. This is the natural home for the **bare-argv carry**: Dockerfile `CMD`/`ENTRYPOINT` vs pod `command`/`args` is exactly the argv-tokenization distinction that's slipped 3×. Image build runs on **kind** — mind the `imagePullPolicy` footgun.

---

## Block 0 — Weekly Review Sprint (15 min)

### Step 1 — Scaffold sprint (~5 min)
Pod + Deployment + Service, one custom field each.

### Step 2 — Cold Ingress + NP (~10 min)
One Ingress cold (still no `explain` — keep closing the metric) + one NP cold (rotate: try a `matchExpressions` peer this time, e.g. `role In [frontend, worker]`).

Check against `day-4-answers.md` → Block 0.

---

## Block 1 — `projected` volume (15 min)

`projected` combines multiple sources into one mount: ConfigMap + Secret + downwardAPI + ServiceAccount token, all under one directory.

**Rep — combined projection.** Pod `proj` (`busybox`, kept alive) with a `projected` volume at `/etc/all` combining:
- ConfigMap `proj-cm` (key `app.conf`)
- Secret `proj-sec` (key `token`)
- downwardAPI exposing `metadata.name` as `pod_name`

Create the CM + Secret first, then the pod. Verify all three files land under `/etc/all`.

> Hint only: it's ONE volume with a `sources:` list, each entry a single source type — find which via `kubectl explain pod.spec.volumes.projected.sources`. No `medium`, no separate volumes.

Save to `yaml-practice/projected.yaml`. Check against `day-4-answers.md` → Block 1.

---

## Block 2 — Dockerfile basics + CMD vs ENTRYPOINT (15 min)

Read/watch the Docker basics. Hand-write a Dockerfile `app/Dockerfile` exercising all six core instructions:
- `FROM busybox`
- `COPY hello.sh /hello.sh` (write a 1-line `hello.sh` that echoes something)
- `RUN chmod +x /hello.sh`
- `EXPOSE 8080` (documentation only — does NOT publish a port)
- `ENTRYPOINT ["/hello.sh"]`
- `CMD ["world"]` (default arg appended to the entrypoint — observe how a runtime arg replaces it)

Answer these before checking (the carry is here):
1. If the Dockerfile has `ENTRYPOINT ["echo"]` and `CMD ["hello"]`, what runs? What runs if you start the container with arg `goodbye`?
2. How does a pod's `command:` map to `ENTRYPOINT`? How does `args:` map to `CMD`?
3. Why is `command: ["sleep 3600"]` wrong, and what's right?

Check against `day-4-answers.md` → Block 2.

---

## Block 3 — Build + kind load + run (20 min)

The full local image cycle on kind.

**Rep 1 — build.** `docker build -t hello-app:v1 ./app`. Confirm `docker images | grep hello-app`.

**Rep 2 — load into kind.** `kind load docker-image hello-app:v1`. (Without this, the kind nodes can't see your locally-built image.)

**Rep 3 — run in a pod.** Pod `hello-pod` using `hello-app:v1`. **Set `imagePullPolicy: IfNotPresent`** (or `Never`) and use the non-`latest` tag `v1` — otherwise kind tries Docker Hub and you get `ErrImagePull`. Confirm the container runs your script (`kubectl logs hello-pod`).

> The kind footgun, restated: locally-built image + `latest` tag → `imagePullPolicy: Always` default → pull attempt → `ErrImagePull`. Tag `:v1` + `imagePullPolicy: IfNotPresent` fixes it.

Save to `yaml-practice/hello-pod.yaml`. Check against `day-4-answers.md` → Block 3.

---

## Block 4 — Interpretation drill (recall test, AFTER the reps) (5 min)

**Prompt A**: "Mount a ConfigMap, a Secret, and the pod name into a single directory."
**Prompt B**: "A pod must override the image's ENTRYPOINT and its default arguments — which two pod fields?"
**Prompt C**: "You built `myimg:v2` locally; the pod shows `ErrImagePull` on kind — two fixes?"
**Prompt D**: "Run `sleep 3600` as a container command — write the argv."

Check against `day-4-answers.md` → Block 4.

---

## Block 5 — kubectl explain drill (5 min)

```bash
kubectl explain pod.spec.volumes.projected
kubectl explain pod.spec.volumes.projected.sources
kubectl explain pod.spec.containers.command
kubectl explain pod.spec.containers.imagePullPolicy
```

Note: `command` overrides the image ENTRYPOINT; `args` overrides CMD. `imagePullPolicy` defaults to `Always` for `:latest`, else `IfNotPresent`.

---

## End-of-Session Checklist

- [ ] `projected` volume combined CM + Secret + downwardAPI under one mount
- [ ] Dockerfile written; CMD vs ENTRYPOINT and the pod `command`/`args` mapping answered correctly
- [ ] `docker build` → `kind load docker-image` → pod ran the built image
- [ ] Pod used a non-`latest` tag + `imagePullPolicy: IfNotPresent` (no `ErrImagePull`)
- [ ] Zero `sh -c` wraps on plain-binary commands; argv tokenized one-per-element
- [ ] Areas to improve logged in `notes.md`
