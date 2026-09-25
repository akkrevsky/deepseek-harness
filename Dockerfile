FROM node:22-alpine

WORKDIR /app

# dsh is a developer preview with compatibility-breaking changes: pin EXACT
# versions and re-check `npm view @deepseek-ai/dsh version` before bumping.
# mcp-client is not a dependency of dsh — it must be resolvable from
# node_modules for the profile patch's insert row to load it.
# The whole dependency tree is frozen in pnpm-lock.yaml (extracted from the
# last proven-good build): transitive drift has broken boot before (a
# cordis-plugin-hmr bump killed the HMR service), so install with
# --frozen-lockfile and never edit node_modules by hand. To bump: edit
# package.json, run `pnpm install` locally, commit the new lockfile.
# pnpm (the harness's own package manager) resolves this giant dependency
# tree in minutes; npm's arborist takes hours on it.
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm@9 > /dev/null \
  && pnpm install --frozen-lockfile

COPY profile/ /opt/dsh-profile/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV DSH_HOME=/data/dsh
EXPOSE 3080

ENTRYPOINT ["/entrypoint.sh"]
