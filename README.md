# deepseek-harness

Docker build of [deepseek-harness](https://github.com/deepseek-ai/dsh) — the AI agent UI used by **citadelMD** (https://github.com/akkrevsky/citadelMD) on the «Агент» home tab.

The build is intentionally separate from citadelMD: the harness is a developer preview with compatibility-breaking releases, so it is pinned, bumped, and shipped here — one version at a time — without touching the citadelMD repo.

## What's inside

- `Dockerfile` — pins the exact harness versions (`@deepseek-ai/dsh`, `@deepseek-ai/dsh-mcp-client`) with `pnpm add --save-exact`. Read it before bumping anything.
- `entrypoint.sh` — seeds `$DSH_HOME` (the `dsh_data` volume) with the profile below on first boot; launches the harness web server (`--expose-internals` for the HMR plugin).
- `profile/cordis.patch.yml` — home-level patch: DeepSeek provider + model, webserver on 3080, trusted host for the remote nginx, and the `citadelmd` MCP client pointing at the citadelMD mcp-server.
- `profile/AGENTS.md` — the agent persona (works with citadelMD notes only through `mcp__citadelmd__*` tools).

Secrets never live here — they are container env vars (`DEEPSEEK_API_KEY`, `DSH_MODEL`, `DSH_MCP_TOKEN`, `DEEPSEEK_BASE_URL`), provided by citadelMD's `infra/.env`.

## Versioning

- Every git tag `v*` builds and pushes `ghcr.io/akkrevsky/deepseek-harness:<tag>` (GitHub Actions).
- `main` pushes update `ghcr.io/akkrevsky/deepseek-harness:latest`.
- citadelMD pins a specific tag in its `infra/docker-compose.yml`; bumping is deliberate:
  1. check the latest versions: `npm view @deepseek-ai/dsh version`, `npm view @deepseek-ai/dsh-mcp-client version`
  2. bump the pins in `Dockerfile`
  3. tag (`git tag v0.x.y && git push --tags`) — CI builds and publishes
  4. in citadelMD: bump the pinned image tag and run `make -C infra dsh-update`

## Env vars consumed at runtime

| Variable | Purpose |
|---|---|
| `DSH_MODEL` | model id on the native DeepSeek API (default `deepseek-v4-pro`) |
| `DEEPSEEK_API_KEY` | DeepSeek platform key |
| `DEEPSEEK_BASE_URL` | optional API base override (empty = public API) |
| `DSH_MCP_TOKEN` | citadelMD `harness` user apiKey (`make -C infra agent-key` in citadelMD) |

## Notes

- The `dsh_data` volume keeps `cordis.patch.yml` and `AGENTS.md` after the first boot — an image bump does not refresh an existing volume's profile. To re-seed, remove the volume and let the entrypoint seed it again.
- The image itself is generic; all citadelMD-specific behavior comes from `profile/`.
