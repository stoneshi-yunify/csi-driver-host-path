#!/bin/bash

if [[ $# -ne 1 ]]
then
  echo "usage: $0 <suffix>"
  echo "this script will generate chart values.yaml to deploy a new csi hostpath driver. The new driver will have its own data dir, storage class, snapshot class, driver name etc, so that you can deploy multiple hostpath csi drivers in one cluster."
  echo "e.g. $0 -a"
  exit 1
fi

chart=../deploy/chart
out="/tmp/values-$RANDOM.yaml"
suffix="$1"

echo "
storageClass:
  name: csi-hostpath${suffix}
  isDefaultStorageClass: false

snapshotClass:
  name: csi-hostpath${suffix}
  isDefaultSnapshotClass: false

driver:
  name: hostpath.csi.k8s.io${suffix}

snapshot-controller:
  enabled: false
  repository: csiplugin/snapshot-controller
  tag: v2.0.1

attacher:
  clusterRoleName: external-attacher-runner${suffix}
  clusterRoleBindingName: csi-attacher-role${suffix}
  repository: csiplugin/csi-attacher
  tag: v3.2.1

plugins:
  healthMonitorAgent:
    repository: csistorage/csi-external-health-monitor-agent
    tag: v0.2.0
  nodeDriverRegistrar:
    repository: csistorage/k8scsi-csi-node-driver-registrar
    tag: v2.1.0
  livenessProbe:
    repository: csistorage/k8scsi-livenessprobe
    tag: v2.2.0
  healthMonitorController:
    clusterRoleName: external-health-monitor-controller-runner${suffix}
    clusterRoleBindingName: csi-health-monitor-controller-role${suffix}
    repository: csistorage/csi-external-health-monitor-controller
    tag: v0.2.0
  hostPathPlugin:
    repository: csistorage/hostpathplugin
    tag: v0.9.0
    dataDir: /var/lib/csi-hostpath-data${suffix}/

provisioner:
  clusterRoleName: external-provisioner-runner${suffix}
  clusterRoleBindingName: csi-provisioner-role${suffix}
  repository: csiplugin/csi-provisioner
  tag: v2.2.2

resizer:
  clusterRoleName: external-resizer-runner${suffix}
  clusterRoleBindingName: csi-resizer-role${suffix}
  repository: csiplugin/csi-resizer
  tag: v1.2.0

snapshotter:
  clusterRoleName: external-snapshotter-runner${suffix}
  clusterRoleBindingName: csi-snapshotter-role${suffix}
  repository: csiplugin/csi-resizer
  tag: v4.0.0

" > $out

echo "new values.yaml file: $out"

echo "to install: helm install csi-hostpath${suffix} $chart -n csi-hostpath${suffix} --create-namespace -f $out"