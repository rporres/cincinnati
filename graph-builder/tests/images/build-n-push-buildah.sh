#!/usr/bin/env bash
set -xe

unused=${1:?"Please provide at least one target directory in the arguments"}

REPO_BASE="${REPO_BASE:-quay.io/redhat/openshift-cincinnati}"

for target in "${@}"; do
  arch_file="${target}/.arch"
  repo="${target%-*}"
  tag_raw="${target##*-}"
  tag="${tag_raw/_/-}"

  full_tag="${REPO_BASE}-${repo}:${tag}"
  buildah bud -t "${full_tag}" "${target}"

  if [[ -e "${arch_file}" ]]; then
    img_arch="$(head -n1 ${arch_file})"
    build_container="$(buildah from ${full_tag})"
    buildah config --arch "${img_arch}" "${build_container}"
    buildah commit "${build_container}" "${full_tag}"
    buildah rm "${build_container}"
  fi

  buildah push "${full_tag}"
done
