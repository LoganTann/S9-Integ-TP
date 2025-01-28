#!/bin/bash
# Must run from the parent dir.

cd istio-1.24.2
export PATH=$PWD/bin:$PATH
set -e
kubectl delete all --all -n="cloud-integ-tp"
kubectl delete -f samples/addons || true
istioctl uninstall -y --purge
minikube service list
cd ..
