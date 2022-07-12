#!/bin/bash
set -e

SRC_REPO="${1?err}"
shift
TARGET_REPO="${1?err}"
shift

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ -d "${SCRIPT_DIR}/${TARGET_REPO}" ]; then
	echo "Error: ${TARGET_REPO} already exists locally"
	exit 1
fi

docker build -t clarin/svn2git:latest .

docker run -ti --rm \
  --name svn2git \
  -v "${SCRIPT_DIR}/${TARGET_REPO}:/svn2git" \
  -v "${SCRIPT_DIR}/authors.txt:/tmp/authors.txt" \
  -w /svn2git \
  clarin/svn2git:latest \
  svn2git "https://svn.clarin.eu/${SRC_REPO}" --authors /tmp/authors.txt $*

(
	cd "${SCRIPT_DIR}/${TARGET_REPO}"
	git remote add origin "git@github.com:clarin-eric/${TARGET_REPO}.git"
	git checkout -b main && git branch -d master
	git push --all origin
	git push --tags origin
)

echo "Done: ${TARGET_REPO}"
