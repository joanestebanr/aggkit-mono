# aggkit-mono

Experimental monorepo that groups three projects. Each one keeps its own README, license(s) and tooling in its folder.

| Folder | Project | Stack | Source |
| --- | --- | --- | --- |
| [`aggkit/`](aggkit/) | aggkit | Go | this repository (history preserved) |
| [`sdk/`](sdk/) | `@agglayer/sdk` | TypeScript, bun | snapshot of [agglayer/sdk](https://github.com/agglayer/sdk) |
| [`agglayer-dev-ui/`](agglayer-dev-ui/) | Agglayer Dev UI | Next.js, pnpm | snapshot of [agglayer/agglayer-dev-ui](https://github.com/agglayer/agglayer-dev-ui) (`feat/aggkit-backend`) |

The snapshot commit messages record the source repository, branch and commit SHA.
Licenses differ per project; see the `LICENSE*` files inside each folder.

## Layout

```
/
├── .github/        workflows, CODEOWNERS, dependabot, PR/issue templates (shared)
├── aggkit/
├── sdk/
└── agglayer-dev-ui/
```

GitHub only reads workflows from the root `.github/workflows/`, so every project's workflows live there with a prefix: `aggkit-*`, `sdk-*`, `devui-*`. Workflows without prefix (`codeql`, `lint-pr`, `claude-interactive`) apply to the whole repository.

## CI: what runs for a PR

Each project workflow runs on every pull request but starts with a `changes` job (`dorny/paths-filter`) that checks whether the PR touches that project's folder (or the workflow file itself). The real jobs are skipped otherwise, and a final `... ok` job always reports a status, so required checks never stay pending.

| Changed paths | Workflows that run their jobs |
| --- | --- |
| `aggkit/**` | `aggkit-*` |
| `sdk/**` | `sdk-test` |
| `agglayer-dev-ui/**` | `devui-ci`, `devui-e2e`, `devui-docker-pr` |
| `.github/workflows/<name>.yml` | that workflow |

Branch protection should require the `... ok` jobs, not the individual jobs.

## Disabled workflows

Publishing and deploy workflows are ported but only run with `workflow_dispatch` until tag prefixes, secrets and environments are defined for this repository:
`aggkit-release`, `aggkit-release-published`, `aggkit-build-push-docker-image`, `aggkit-mdbook`, `sdk-release`, `devui-deploy`, `devui-docker-publish`, `devui-loadtest-image`, `devui-loadtest-e2e`.

Pending configuration:
- Secrets used by aggkit e2e and release jobs (Slack, Datadog, OpenAI, `CLAUDE_API_KEY`).
- Dev UI: `production` environment and `CF_WORKER_ACCOUNT_ID`, `CF_WORKER_API_TOKEN`, `NEXT_PUBLIC_PROJECT_ID`, `NEXT_PUBLIC_AGGKIT_PROXY`.
- sdk: npm trusted publisher for the new repository and workflow filename.
- Tag prefixes per project (for example `sdk-v1.2.3`).

## Working on a project

Run commands from the project folder, for example `cd aggkit && make build`, `cd sdk && bun install`, `cd agglayer-dev-ui && pnpm install`. Per-project git hooks (husky) are not active in this layout.
