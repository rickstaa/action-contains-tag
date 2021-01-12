# GitHub Action: Contains tag

[![Docker Image CI](https://github.com/rickstaa/action-contains-tag/workflows/Docker%20Image%20CI/badge.svg)](https://github.com/rickstaa/action-contains-tag/actions)
[![Code quality CI](https://github.com/rickstaa/action-contains-tag/workflows/Code%20quality%20CI/badge.svg)](https://github.com/rickstaa/action-contains-tag/actions?query=workflow%3A%22Code+quality+CI%22)
[![release](https://github.com/rickstaa/action-contains-tag/workflows/release/badge.svg)](https://github.com/rickstaa/action-contains-tag/actions?query=workflow%3Arelease)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/rickstaa/action-contains-tag?logo=github&sort=semver)](https://github.com/rickstaa/action-contains-tag/releases)

Simple GitHub action that can be used to check if a commit or branch contains a given tag.

## Inputs

### `tag`

**Required**. The tag you want to check. Also works with `${{ git.ref }}` if the workflow was triggered on a tag push.

### `reference`

**Required**. Branch or commit for which you want to check the tag existence.

### `verbose`

**Optional**. Log action information to the console. By default `true`.

## Outputs

### `retval`

Boolean specifying whether the reference contained the tag.

### `tag`

The (trimmed) input tag that as used as a input.

### `linked_commit`

The commit that is currently linked to the tag.

### `reference`

The reference that was used as a input.

## Example usage

```yml
name: Contains tag
on:
  push:
    branch: "main"
jobs:
  create-tag:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - uses: rickstaa/action-contains-tag@v1
        id: contains_tag
        with:
          reference: "main"
          tag: "Latest"
      - run: |
          if [[ ${{ steps.contains_tag.outputs.retval }} != 'true' ]]; then
            echo "Branch/commit did contain the tag."
          else
            echo "Branch/commit did not contain the tag."
          fi
```

## Use case

I created this action since I wanted to combine the `tag` and `push` to branch filters. I send a feature request to the GitHub support. Until this feature is released, this action can be used as a temporary workaround. The recipe below ensures that a workflow is only triggered when a tag is pushed to the master branch.

```yml
name: Create/update tag
on:
  tags:
    - "v*.*.*"
jobs:
  create-tag:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - uses: rickstaa/action-contains-tag@v1
        id: contains_tag
        with:
          reference: "main"
          tag: "Latest"
      - name: Run step only when tag is pushed to the main branch.
        if: ${{ steps.contains_tag.outputs.retval }} != 'true'
         run: |
          echo "Tag '${{ steps.contains_tag.outputs.tag }}' was pushed to the '${{ steps.contains_tag.outputs.reference }}' branch."
```

## Limitations & Gotchas

When use [Checkout@v2](https://github.com/actions/checkout), only a single commit is fetched by default. You must therefore set the right `fetch_depth` in order to be able to access all the tags.
