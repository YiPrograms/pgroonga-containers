#!/usr/bin/env bash
#
# Copyright The CloudNativePG Contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=("$@")
if [ ${#versions[@]} -eq 0 ]; then
	for version in */; do
		[[ $version = src/ ]] && continue
		versions+=("$version")
	done
fi
versions=("${versions[@]%/}")


generate_postgres() {
	local version="$1"; shift
	versionFile="${version}/.versions.json"
	imageReleaseVersion=1

	dockerTemplate="Dockerfile.template"
	if [ "${version}" -gt '14' ]; then
		dockerTemplate="Dockerfile-beta.template"
	fi

	cp -r src/* "$version/"
	sed -e 's/%%PG_MAJOR%%/'"$version"'/g' \
		${dockerTemplate} \
		> "$version/Dockerfile"
}

for version in "${versions[@]}"; do
	generate_postgres "${version}"
done
