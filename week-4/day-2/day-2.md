# Week 4 — Day 2 (Tuesday May 26)

**Total time**: 75 min | Ingress deep — cold-write reps begin

> Slipped from Mon May 25; Tuesday rest day absorbs it cleanly. Day 3 stays Wednesday.
>
> Ingress is the first Week 4 resource with no imperative scaffold and no usable `kubectl explain` shortcut under time pressure. Today's load: 3+ cold reps of the Ingress YAML shape, with the third rep wired with TLS so the multi-doc + Secret pattern also gets practiced. The Day 2 opener checklist gates the session.

---

## Day 2 Opener (2 min, before any block)

Read from `notes.md` → Day 2 Opener Checklist. Then:

- [ ] **Commit**: drill `kubectl apply -f` (full form), not `kubectl create -f`. Zero `create -f` slips today.
- [ ] **Commit**: strip dry-run artifacts (`strategy: {}`, `status: {}`, unused port `name:`) on save. `:wq` is the gate, not future cleanup.
- [ ] **Commit**: one failed flag → `--help` immediately. No retry-with-variations.

---

## Block 0 — Scaffold + Refine Sprint (15 min)

Three reps, networking flavor. Apply each.

1. Pod `db` with image `redis:7`, label `app: db`. Add an **`exec` readinessProbe** that runs `redis-cli ping` (closes the probe-variety carry — `exec` probe owed this week).
2. Deployment `api` with image `nginx:1.21`, 2 replicas, label `app: api`. Add a `httpGet` readinessProbe on `/` port 80.
3. ClusterIP Service `api-svc` targeting `app: api` on port 80 — imperative scaffold + selector fix.

Save to `yaml-practice/sprint-{1,2,3}.yaml`. Strip dry-run artifacts before save. Apply all three.

> The `exec` probe rep is the carry-forward closer. `httpGet` is the default; if `tcpSocket` (Day 1) and `exec` (today) both happen, the probe-variety success metric is closed by end of Day 2.

---

## Block 1 — Task Interpretation Drills (5 min)

15 seconds each. Write the **field name and value type only** — no full YAML.

**Prompt A**: "Route HTTP requests for `shop.example.com/` to Service `web` on port 80"

**Prompt B**: "Route `shop.example.com/api/*` to Service `api` and `shop.example.com/*` to Service `web` — `/api` matches first"

**Prompt C**: "Terminate TLS at the Ingress for `shop.example.com` using TLS Secret `shop-tls`"

**Prompt D**: "Route all traffic that doesn't match any rule to Service `fallback` port 8080"

Check against `day-2-answers.md` → Block 1.

---

## Block 2 — Udemy: Ingress (15 min)

Watch the **Ingress** section. Focus on:

- Why Ingress is needed (LoadBalancer per Service doesn't scale)
- Ingress controller vs Ingress resource — the controller does the work; the resource is config
- `host` rules vs `path` rules vs combined
- `pathType: Prefix` vs `Exact` vs `ImplementationSpecific`
- `tls:` block — what `secretName` references
- `defaultBackend` — what catches unmatched traffic

---

## Block 3 — Ingress Reps (25 min)

Three reps. **First exposure: reference is fair game.** Keep `day-2-answers.md` → Block 3 open as you work. Goal here is to understand *how* the Ingress YAML wires together — `rules` ↔ `paths` ↔ `backend.service`, the `tls` block, where things sit relative to each other.

Cold-recall framing is reserved for Day 5 weak-spot drilling and the Day 6 milestone — by then the shape should be familiar enough that "cold" is the natural next step.

Apply each rep, then read it back with `kubectl get ingress` and `kubectl describe ingress`.

**Rep 1 — Path-based, single host, single backend**

Ingress `web-ing` routes `http://shop.example.com/` (path `/`, prefix) to Service `web-svc` on port 80. Save to `yaml-practice/ing-1.yaml`. Apply.

**Rep 2 — Multi-path, single host, two backends**

Ingress `multi-ing` on host `shop.example.com`:
- `/api` (prefix) → Service `api-svc` port 80
- `/` (prefix) → Service `web-svc` port 80

`/api` must match before `/`. Save to `yaml-practice/ing-2.yaml`. Apply.

**Rep 3 — TLS termination, multi-doc with Secret**

Ingress `tls-ing` on host `shop.example.com`:
- `/` (prefix) → Service `web-svc` port 80
- TLS for `shop.example.com` using Secret `shop-tls`

Same YAML file holds **both** the TLS Secret (type `kubernetes.io/tls`) AND the Ingress, separated by `---`. Use a self-signed dummy cert (any base64 strings — won't actually validate, just needs to parse). Save to `yaml-practice/ing-3.yaml`. Apply.

> Rep 3 is the YAML triage rep: if the apply fails, **read the parse error message first** before reaching for `kubectl explain`. Multi-doc files reset line numbers at `---` separators — if the error says "line 26," that may be line 26 of the second document, not the file. This is the W3 milestone Task 3 lesson.

After all three apply, run:

```bash
kubectl get ingress
kubectl describe ingress tls-ing
```

`describe` shows how the controller resolved the rules. On a local cluster without an Ingress controller installed, the Ingress resource will exist but won't route anything. That's expected — you're verifying YAML shape, not end-to-end traffic.

---

## Block 4 — Mixed Tasks (10 min)

3-minute skip rule. 15-second literal interpretation per task.

### Quick
Write an Ingress YAML for: host `api.example.com`, path `/v1` prefix → Service `api-v1` port 8080. No TLS. Reference open if needed. Save to `yaml-practice/quick-ing.yaml`. Apply.

### Medium — cross-domain (Deployment + Service + Ingress)
Build the full chain for `shop.example.com`:
- Deployment `shop`, image `nginx:1.21`, 2 replicas, label `app: shop`. Resources `cpu: 100m, memory: 128Mi`.
- ClusterIP Service `shop-svc` selecting `app: shop`, port 80.
- Ingress `shop-ing` on `shop.example.com/` → `shop-svc:80`.

Multi-doc file is fine. Save to `yaml-practice/shop-stack.yaml`. Apply. Verify:

```bash
kubectl get all -l app=shop
kubectl get endpoints shop-svc       # should list 2 pod IPs once probes pass
kubectl describe ingress shop-ing    # backend wired correctly?
```

Check against `day-2-answers.md` → Block 4.

---

## Block 5 — kubectl explain drill (5 min)

No syntax lookup before trying.

```bash
kubectl explain ingress.spec
kubectl explain ingress.spec.rules
kubectl explain ingress.spec.rules.http.paths
kubectl explain ingress.spec.tls
kubectl explain ingress.spec.defaultBackend
```

Note: `kubectl explain` on Ingress IS available (unlike Kustomize) — `networking.k8s.io/v1 Ingress` is a real API resource. Useful as a structural reminder under exam pressure, even though writing it cold is faster than walking the tree.

---

## End-of-Session Checklist

Fill in `week-4/notes.md` Day 2 tracking:
- [x] Zero `kubectl create -f` slips today ✓ (full `apply` form throughout)
- [x] Dry-run artifacts stripped on save — partial: `deploy.yaml` clean, `svc.yaml` had `name: 80-80` slip through
- [x] Three Ingress reps written with structure understood (reference open) ✓
- [x] `exec` probe used (sprint-1.yaml with `redis-cli ping`) — wrapped in `sh -c` initially, direct form is cleaner
- [x] TLS multi-doc Ingress applied cleanly — no parse errors. Content slip: missing `type: kubernetes.io/tls` on Secret (defaults to Opaque)
- [x] Cross-domain shop stack: chain wired after patch (Service `selector` missing in v1; Ingress name `medium` vs `shop-ing` was the literal-prompt slip)
- [x] Areas to improve logged in `notes.md` Day 2

**Big find of the night**: `kubectl create ingress NAME --rule="host/path*=svc:port" --dry-run=client -o yaml` — imperative scaffold for Ingress exists. The W4 plan claimed it didn't. Drops a lot of cold-write pressure. Logged into `notes.md` Key Concepts.
