# GitHub Action: Contains tag

[![Docker Image CI](https://github.com/rickstaa/action-contains-tag/workflows/Docker%20Image%20CI/badge.svg)](https://github.com/rickstaa/action-contains-tag/actions)
[![Code quality CI](https://github.com/rickstaa/action-contains-tag/workflows/Code%20quality%20CI/badge.svg)](https://github.com/rickstaa/action-contains-tag/actions?query=workflow%3A%22Code+quality+CI%22)
[![release](https://github.com/rickstaa/action-contains-tag/workflows/release/badge.svg)](https://github.com/rickstaa/action-contains-tag/actions?query=workflow%3Arelease)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/rickstaa/action-contains-tag?logo=github&sort=semver)](https://github.com/rickstaa/action-contains-tag/releases)

Simple GitHub action that can be used to check if a commit or branch contains a given tag.

## Inputs

### `tag`

**Required**. The tag you want to check.

### `reference`

**Required**. Branch or commit for which you want to check the tag existence.

### `verbose`

**Optional**. Log action information to the console. By default `true`.

## Outputs

### `retval`

Boolean specifying whether the reference contained the tag.

### `linked_commit`

The commit that is currently linked to the tag.

## Example usage

```yml
name: Create/update tag
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

## Limitations & Gotchas

When use [Checkout@v2](https://github.com/actions/checkout), only a single commit is fetched by default. You must therefore set the right `fetch_depth` in order to be able to access all the tags.
