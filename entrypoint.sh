#!/bin/bash
set -eux

cd "${GITHUB_WORKSPACE}" || exit

echo "Commit that triggered: ${GITHUB_SHA}"
echo "The branches that are presetn on the remote:"
git branch -a
echo "${INPUT_TAG}"
tag="${INPUT_TAG#'refs/tags/'}" # Remove possible refs/tags prefix

# Check if tag exists
if [[ ! $(git tag -l "${tag}") ]]; then
  if [[ "${INPUT_VERBOSE}" == 'true' ]]; then
    echo "[action-contains-tag] Tag '${tag}' does not exist on your repository."
  fi
  echo "::set-output name=tag::${tag}"
  echo "::set-output name=reference::${INPUT_REFERENCE}"
  echo "::set-output name=linked_commit::"
  echo "::set-output name=retval::false"
  [[ "${INPUT_FRAIL}" != 'true' ]] && exit 0 || exit 1
fi

# Check if reference exists
regex="(remotes/.*/)*${INPUT_REFERENCE}$"
if [[ "$(git branch -a | grep -Eow $regex | wc -l)" -ne 0 ]]; then
  input_type="branch"
  INPUT_REFERENCE="$(git branch -a | grep -Ewom 1 $regex)" # Replace with full branch name
else
  if git cat-file -e "${INPUT_REFERENCE}"^{commit} 2>/dev/null; then
    input_type="commit"
  else
    echo "[action-contains-tag] Please specify a valid branch/commit."
    echo "::set-output name=tag::${tag}"
    echo "::set-output name=reference::${INPUT_REFERENCE}"
    echo "::set-output name=linked_commit::"
    echo "::set-output name=retval::false"
    [[ "${INPUT_FRAIL}" != 'true' ]] && exit 0 || exit 1
  fi
fi

# Check if reference contanis tag
tag_commit="$(git rev-parse tags/${tag}~0)"
if [[ "${input_type}" == "commit" ]]; then
  regex="${INPUT_REFERENCE}.*"
  [[ "${tag_commit}" =~ $regex ]] && is_tag_commit="true" || is_tag_commit="false"
  if [[ "${is_tag_commit}" == 'true' ]]; then
    if [[ "${INPUT_VERBOSE}" == 'true' ]]; then
      echo "[action-contains-tag] Tag '${tag}' is linked to commit '${INPUT_REFERENCE}'."
    fi
  else
    if [[ "${INPUT_VERBOSE}" == 'true' ]]; then
      echo "[action-contains-tag] Tag '${tag}' is not linked to commit '${INPUT_REFERENCE}' but to commit '${tag_commit}'."
    fi
  fi
  echo "::set-output name=linked_commit::${tag_commit}"
  echo "::set-output name=retval::${is_tag_commit}"
else
  if [[ "$(git rev-list ${INPUT_REFERENCE} 2>/dev/null | grep -w ${tag_commit} | wc -l)" -ne 0 ]]; then
    if [[ "${INPUT_VERBOSE}" == 'true' ]]; then
      echo "[action-contains-tag] Branch '${INPUT_REFERENCE}' contains tag '${tag}'."
    fi
    echo "::set-output name=linked_commit::${tag_commit}"
    echo "::set-output name=retval::true"
  else
    if [[ "${INPUT_VERBOSE}" == 'true' ]]; then
      echo "[action-contains-tag] Branch '${INPUT_REFERENCE}' does not contain tag '${tag}'."
    fi
    echo "::set-output name=linked_commit::${tag_commit}"
    echo "::set-output name=retval::false"
  fi
fi

echo "::set-output name=tag::${tag}"
echo "::set-output name=reference::${INPUT_REFERENCE}"
