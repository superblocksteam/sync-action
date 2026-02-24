# sync-action

This repo contains a GitHub Action that syncs `main` branch code into
Superblocks DBFS by running the `superblocks sync` CLI command.

## Description

Sync Superblocks app snapshots from Git `main` into DBFS and create a `main`
`application_commit`.

## Usage

```yaml
name: Sync Superblocks DBFS on merge to main

on:
  pull_request:
    branches: [main]
    types: [closed]

jobs:
  superblocks-sync:
    if: ${{ github.event.pull_request.merged == true }}
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          ref: ${{ github.event.pull_request.merge_commit_sha }}

      - name: Sync
        uses: superblocksteam/sync-action@v1
        with:
          token: ${{ secrets.SUPERBLOCKS_TOKEN }}
          domain: app.superblocks.com
          path: .
          sha: ${{ github.event.pull_request.merge_commit_sha }}
```

## Inputs

| INPUT | TYPE | REQUIRED | DEFAULT | DESCRIPTION |
| --- | --- | --- | --- | --- |
| token | string | true |  | Superblocks access token used by CLI auth |
| domain | string | false | `"app.superblocks.com"` | Superblocks domain (host or full URL) |
| path | string | false | `"."` | Relative path from repo root to sync root |
| sha | string | false | `"HEAD"` | Git SHA to sync from `main` snapshot |
| cli_version | string | false | `"latest"` | Superblocks CLI version to install |

## Outputs

No outputs.
