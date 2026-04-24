#!/usr/bin/env bash
#
# cross-spec-conflict fixture setup. Creates two open spec dirs that both
# claim write access to the same path WITHOUT (SHARED) markers. the cross-
# spec-ownership check must BLOCK.
#
# Run inside the harness's temp dir. Echoes the feature dir to validate.

set -u

mkdir -p specs/901-feature-a specs/902-feature-b

cat > specs/901-feature-a/spec.md <<'EOF'
# Feature Specification: Feature A (claims tasks.ts exclusively)

**Feature Branch**: `901-feature-a`

## Depth

`[W]`

## Files this feature will touch

- `src/api/routes/tasks.ts` (new)
EOF

cat > specs/902-feature-b/spec.md <<'EOF'
# Feature Specification: Feature B (also claims tasks.ts exclusively)

**Feature Branch**: `902-feature-b`

## Depth

`[W]`

## Files this feature will touch

- `src/api/routes/tasks.ts` (new)
EOF

# Initialize git so the merged-branch filter has something to query.
git init -q -b main
git add -A
git -c user.email=test@test -c user.name=test commit -q -m initial >/dev/null 2>&1

# Validate against feature A; the check enumerates ALL open specs.
echo "specs/901-feature-a"
