# Release Guide

> **Status: currently disabled.** `.github/workflows/sdk-release.yml` must not be run until the
> npm trusted publisher is re-registered for the monorepo (see Prerequisites) and the tag prefix is agreed.

The SDK (`@agglayer/sdk`, in `sdk/`) is released only through the manually dispatched workflow
`.github/workflows/sdk-release.yml` (Actions -> "SDK Release Packages" -> Run workflow). There are no tag-triggered releases.

## Channels

| Channel  | npm dist-tag | Source ref                        |
| -------- | ------------ | --------------------------------- |
| `dev`    | `dev`        | any branch, tag or commit         |
| `alpha`  | `alpha`      | any branch, tag or commit         |
| `beta`   | `beta`       | any branch, tag or commit         |
| `latest` | `latest`     | `main` only (enforced by the job) |

Inputs: `channel`, `ref` (default `main`), `force` (skip the "version already exists" check),
`use_package_version` (publish the exact `package.json` version on dev/alpha/beta instead of a
generated `<base>-<channel>.<timestamp>.<sha>` one; no effect on `latest`, which always uses `package.json`).

## What the workflow does

1. Validates inputs, checks out `ref` (full history) and runs in `sdk/`.
2. `bun install --frozen-lockfile`, typecheck, lint, format check, build, tests.
3. Computes or validates the version for the channel; for `latest` / `use_package_version` it fails if the
   version is already on npm or the git tag `sdk-v<version>` already exists (unless `force`).
4. Stages the package with `npm stage publish --tag <channel>` using OIDC trusted publishing (no `NPM_TOKEN`).
5. Creates the GitHub release and tag `sdk-v<version>` (pre-release for every channel except `latest`).

## Staged publish and 2FA

Nothing is public after the workflow finishes: the package sits in npm's staging queue. A maintainer must
approve it with a 2FA challenge (see `npm stage --help`). A failed run does not expose a partial release; if a
GitHub release/tag was created before the failure, delete it manually before retrying the same version.

## Prerequisites (before re-enabling)

- On npmjs.com, register a trusted publisher for `@agglayer/sdk` pointing at this repository
  (`joanestebanr/aggkit-mono`), workflow filename `sdk-release.yml`, and the environment (if any).
- Agree on the `sdk-v` tag prefix (it avoids collisions with aggkit tags in the monorepo).
- Remove the "disabled" header from the workflow and this note.

## Releasing

1. Bump `version` in `sdk/package.json` through a PR (stable and `use_package_version` releases use it as-is).
2. Dispatch the workflow with the desired channel and ref.
3. Approve the staged package on npm with 2FA.
4. Verify: `npm view @agglayer/sdk@<channel>` and the GitHub release `sdk-v<version>`.
