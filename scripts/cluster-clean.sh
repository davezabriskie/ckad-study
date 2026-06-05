#!/usr/bin/env bash
# cluster-clean.sh
# Deletes practice resources in default + known test namespaces.
# Leaves kube-system, local-path-storage, metrics-server, and the
# kubernetes ClusterIP service intact.
# Usage: ./scripts/cluster-clean.sh [--dry-run]

set -euo pipefail

DRY_RUN=${1:-}
KU="kubectl"
[[ "$DRY_RUN" == "--dry-run" ]] && KU="kubectl --dry-run=client"

echo "=== cluster-clean: removing practice resources ==="
[[ "$DRY_RUN" == "--dry-run" ]] && echo "    (DRY RUN — nothing will actually be deleted)"

# ── default namespace ──────────────────────────────────────────────────────
echo ""
echo "-- default namespace --"

# Resource types created during practice (namespace-scoped)
# Skip the built-in 'kubernetes' Service by excluding it explicitly
TYPES="pods,deployments,statefulsets,daemonsets,jobs,cronjobs,\
replicasets,services,ingresses,networkpolicies,\
persistentvolumeclaims,configmaps,secrets,\
resourcequotas,limitranges"

$KU delete $TYPES \
  --all \
  --namespace=default \
  --ignore-not-found \
  --field-selector='metadata.name!=kubernetes' \
  2>/dev/null || true

# The kubernetes service doesn't match the field-selector on all types —
# delete services more carefully to preserve it
$KU delete services \
  --namespace=default \
  --ignore-not-found \
  --field-selector='metadata.name!=kubernetes' \
  2>/dev/null || true

# ── test namespaces (delete the whole ns) ─────────────────────────────────
echo ""
echo "-- test namespaces --"
TEST_NS="quota-demo secure data app app5 web-dev"
for ns in $TEST_NS; do
  if kubectl get namespace "$ns" &>/dev/null; then
    echo "  deleting namespace: $ns"
    $KU delete namespace "$ns" --ignore-not-found 2>/dev/null || true
  fi
done

# ── cluster-scoped: PVs ───────────────────────────────────────────────────
echo ""
echo "-- persistent volumes (cluster-scoped) --"
# Only delete PVs that are Available or Released (not Bound to system PVCs)
for pv in $(kubectl get pv --no-headers 2>/dev/null | awk '$5 == "Available" || $5 == "Released" {print $1}'); do
  echo "  deleting pv: $pv"
  $KU delete pv "$pv" --ignore-not-found 2>/dev/null || true
done

# ── cluster-scoped: Ingress classes created during practice ───────────────
# (none expected, but belt-and-suspenders)

echo ""
echo "=== done. core cluster state: ==="
kubectl get pods -A --no-headers | grep -v "^default " | grep -v "Completed"
