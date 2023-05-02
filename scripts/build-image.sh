#!/usr/bin/env bash
set -e
CURL="curl -sSf"
FLANNEL_CNI_ROOT=$(git rev-parse --show-toplevel)
IMAGE_NAME=rancher/flannel-cni
VERSION=$($FLANNEL_CNI_ROOT/scripts/git-version)
CNI_VERSION="v0.6.0"
CNI_PLUGIN_VERSION="v1.2.0"
FLANNEL_VERSION="v1.1.2"

ARCH=amd64
OS_TYPE=linux

case "$(uname -m)" in
  x86_64*)
    ARCH=amd64
    ;;
  i?86_64*)
    ARCH=amd64
    ;;
  amd64*)
    ARCH=amd64
    ;;
  aarch64*)
    ARCH=arm64
    ;;
  arm64*)
    ARCH=arm64
    ;;
  *)
    echo "Unsupported host arch. Must be x86_64, arm64." >&2
    exit 1
    ;;
esac

mkdir -p dist
$CURL -L --retry 5 https://github.com/containernetworking/cni/releases/download/$CNI_VERSION/cni-${ARCH}-$CNI_VERSION.tgz | tar -xz -C dist/
$CURL -L --retry 5 https://github.com/containernetworking/plugins/releases/download/$CNI_PLUGIN_VERSION/cni-plugins-${OS_TYPE}-${ARCH}-$CNI_PLUGIN_VERSION.tgz | tar -xz -C dist/
$CURL -L --retry 5 https://github.com/flannel-io/cni-plugin/releases/download/$FLANNEL_VERSION/flannel-${ARCH} -o dist/flannel
chmod +x dist/flannel

case ${ARCH} in
    amd64) BASEIMAGE_ARCH="amd64" ;;
    arm64) BASEIMAGE_ARCH="arm64v8" ;;
esac
sed -i "s|BASEIMAGE_ARCH|$BASEIMAGE_ARCH|g" Dockerfile
docker build --no-cache -t $IMAGE_NAME:$VERSION-linux-${ARCH} .
