#!/bin/bash

echo "=== NAD Rendering Diagnostics ==="
echo ""

# Approach A
echo "=== APPROACH A: Checking network-intents + nad-renderer ==="
echo ""

echo "1. NetworkIntents PackageRevision:"
kubectl get packagerevisions | grep network-intents
echo ""

echo "2. NAD Renderer PackageRevision:"
kubectl get packagerevisions | grep nad-renderer
echo ""

echo "3. Injector config in PackageVariant:"
kubectl get packagevariant nad-renderer-my-ran -o jsonpath='{.spec.injectors}' 2>/dev/null
echo ""
echo ""

echo "4. Checking if NetworkIntents were injected into nad-renderer package:"
PR_NAME=$(kubectl get packagerevisions -o name | grep nad-renderer | grep my-ran | head -1)
if [ -n "$PR_NAME" ]; then
  kubectl get $PR_NAME -o yaml | grep -c "kind: NetworkIntent"
  echo "NetworkIntents found in nad-renderer package (count above)"
else
  echo "No nad-renderer PackageRevision found"
fi
echo ""

# Approach B
echo "=== APPROACH B: Checking network-config all-in-one ==="
echo ""

echo "1. Network-config PackageRevision:"
kubectl get packagerevisions | grep network-config
echo ""

PR_NAME=$(kubectl get packagerevisions -o name | grep network-config | grep my-core | head -1)
if [ -n "$PR_NAME" ]; then
  echo "2. NetworkIntents in package:"
  kubectl get $PR_NAME -o yaml | grep -c "kind: NetworkIntent"
  echo "(count above)"
  
  echo ""
  echo "3. NADRendererConfig in package:"
  kubectl get $PR_NAME -o yaml | grep -c "kind: NADRendererConfig"
  echo "(count above)"
  
  echo ""
  echo "4. NADs generated:"
  kubectl get $PR_NAME -o yaml | grep -c "kind: NetworkAttachmentDefinition"
  echo "(count above - should be 2 for control-plane and user-plane)"
fi
echo ""

# Function runner logs
echo "=== Function Runner Logs (last 50 lines) ==="
kubectl logs -n porch-system -l app=porch-function-runner --tail=50 2>/dev/null || \
kubectl logs -n porch-system -l app=porch-server --tail=50 2>/dev/null || \
echo "Could not find function runner logs"
echo ""

echo "=== Diagnostic Complete ==="
