#!/bin/bash
set -eu

cd "${GITHUB_WORKSPACE}" || exit

if [[ -z "${INPUT_TAG}" ]]; then
  echo "[action-create-tag] No-tag was supplied! Please supply a tag."
  exit 1
fi

# Set up variables.
TAG="${INPUT_TAG}"

# Check if input is commit or branch
if [[ $(git branch --list "${INPUT_REFERENCE}") ]]; then
  input_type="branch"
else
  if git cat-file -e "${INPUT_REFERENCE}"^{commit} 2>/dev/null; then
    input_type="commit"
  else
    echo "[action-contains-tag] Please specify a valid branch/commit."
    exit 1
  fi
fi

# Check if tag exists
if [[ $(git tag -l "${INPUT_TAG}") ]]; then
  tag_commit="$(git rev-parse tags/${INPUT_TAG}~0)"
  if [[ "${input_type}" == "commit" ]]; then
    regex="${INPUT_REFERENCE}.*"
    [[ "${tag_commit}" =~ $regex ]] && is_tag_commit="true" || is_tag_commit="false"
    if [[ "${is_tag_commit}" == 'true' ]]; then
      echo "[action-contains-tag] Tag '${INPUT_TAG}' is linked to commit '${INPUT_REFERENCE}'."
    else
      echo "[action-contains-tag] Tag '${INPUT_TAG}' is not linked to commit '${INPUT_REFERENCE}' but to commit '${tag_commit}'."
    fi
    echo "::set-output value=linked_commit::${tag_commit}"
    echo "::set-output value=retval::${is_tag_commit}"
  else
    branch_has_tag="$(git branch ${INPUT_REFERENCE} --contains ${tag_commit} 2>/dev/null || echo '')"
    if [[ ! -z "${branch_has_tag}" ]]; then
      echo "[action-contains-tag] Branch '${INPUT_REFERENCE}' contains tag ${INPUT_TAG}."
      echo "::set-output value=linked_commit::${tag_commit}"
      echo "::set-output value=retval::true"
    else
      echo "[action-contains-tag] Branch '${INPUT_REFERENCE}' does not contain tag ${INPUT_TAG}."
      echo "::set-output value=linked_commit::${tag_commit}"
      echo "::set-output value=retval::false"
    fi
  fi
else
  echo "[action-contains-tag] Tag '${INPUT_TAG}' does not exist on your repository."
  echo "::set-output value=linked_commit::"
  echo "::set-output value=retval::false"
fi
