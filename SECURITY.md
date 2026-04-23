# Security policy

This is a methodology kit — a collection of markdown docs, bash scripts, and skeleton files. It does not ship runtime code that accepts user input, network traffic, or secrets. The kit's own attack surface is limited. Security concerns tend to fall into three categories:

## 1. Vulnerabilities in the kit itself

If you find a security issue in the kit (e.g., a shell-injection in a `run.sh` script, a prompt-injection payload in a `.mdc` rule that could escape sandboxing, a malicious instruction in a blueprint skeleton), please:

- **Do NOT open a public issue** that describes the exploit in detail
- Email the maintainer at the address in the repo's GitHub profile, or open a GitHub Security Advisory via the repo's Security tab
- Include: the file path, the vulnerable behavior, and a proof-of-concept if possible
- Allow up to 14 days for initial response; 30 days for a fix to land on `main`

The kit is CC BY-SA 4.0 with no warranty. A vulnerability report helps users, but the maintainer has no formal SLA obligation.

## 2. Dependency vulnerabilities in tools the kit recommends

The kit depends on `uv`, `specify-cli`, `npx tiged`, `node`, `git`, and optionally `gh`. A vulnerability in any of these is out of scope for this repo — report it to the respective upstream project.

The kit pins Spec-Kit to a specific tag (`v0.8.0` currently, see `docs/SPEC_KIT_PINNING.md`). If a security issue is found in the pinned version, the kit will bump the pin in a `chore(spec-kit)` commit. Subscribers to repo releases will see the bump advisory.

## 3. Security patterns in projects unfolded from the kit

The kit unfolds into target projects. Those targets have their own attack surface (the code they ship). The kit does not prescribe security practices for target projects — that's `CONSTITUTION.md` Article 10 territory, per-project.

Common items a team lead should add to Article 10 for security-sensitive projects:
- Secret management rules (no `.env` in git; use an allowlist)
- Input validation at system boundaries only (per CLAUDE.md guidance)
- Dependency pinning + vulnerability scanning in CI
- PR-review requirement from an approver NOT co-authored by an AI agent on that PR

The kit's own CI workflow (`.github/workflows/dna.yml`) runs enforcement gates but does not run dependency scanning — target teams should add their own `dependabot.yml` or equivalent.

## Scope

This policy covers:
- The kit repository (`agentic-dev-starter`)
- The published worked example (`team-project-scheduler-example`)

Not covered:
- Projects that adopters unfold from the kit
- The agent-token-meter companion repository (separate license, separate maintainer)
- Spec-Kit itself (report to `github/spec-kit`)

## Supported versions

Only the latest `main` branch is supported. Releases (e.g., `v0.9.0`) are snapshots for reference — fixes land on `main` and the next tagged release picks them up.
