# dbt v2 Stable migration report — jaffle_shop (Snowflake)

**Starting version:** 1.7 → **Target:** v2 Stable (dbt 2.0.11, "Fusion" engine)
**Branch:** `fix/v2-stable-migration`
**Outcome: completed_partial** — parse and compile are fully verified clean; `dbt test` failed on a warehouse permissions issue unrelated to the migration, so `dbt build` did not run.

## Summary

This project was already in excellent shape for the 1.7 → 1.12 jump. Of the 22 known breaking/behavior changes between those versions, **none were found to be present** in this codebase — it already uses `data_tests:`, wraps all generic test arguments under `arguments:`, has no spaces in resource names, no duplicate primary-key constraints, no custom materializations or microbatch strategies, and no behavior-flag-gated features that would change semantics. No code changes, file renames, or `dbt_project.yml` flag pins were necessary.

## Verification gate

| Check | Result |
|---|---|
| `dbt parse --no-partial-parse` | ✅ Passed — clean, no deprecation warnings |
| `dbt compile` | ✅ Passed — 40/40 nodes (13 models, 27 tests) |
| `dbt test` | ❌ Failed — see below |
| `dbt build` | ⏸️ Not run (gate stopped after test failure) |

**Why the gate stopped at `test`:** every failing test errored with the same Snowflake message:

```
[Snowflake] 002003 (02000): SQL compilation error:
Schema 'JULIEN.CSG_SA_JULIEN_HACKATHON' does not exist or not authorized.
```

This is a warehouse access/schema-provisioning issue — the dev schema either hasn't been created yet or your role lacks `USAGE` on it — not a dbt v2 compatibility problem. None of the 22 known 1.7→1.12 issues explain it, so per the migration runbook I stopped rather than guessing at a fix. **Action needed from you:** confirm the `SALES_ENGINEERING` role (or your active role) has `USAGE` on `JULIEN.CSG_SA_JULIEN_HACKATHON`, or that the schema has been created, then re-run `dbt build` to materialize and fully verify.

## Issues checked (22 total, 0 present)

All 22 issues in the 1.7→1.12 bundle were checked against the repo and marked `skipped-not-present`. Full detail is in `target/dbt_migration.json`. Highlights:

- **Deterministic/agentic (1.7→1.8):** `--dry-run` removal, duplicate primary-key constraints, spaces in resource names, package materialization overrides, `tests:`→`data_tests:`, source-freshness hooks — none found.
- **Behavior flags (1.8→1.12):** on-run-start hook skipping, `state:modified` comparison, custom microbatch, cumulative metric shape, macro-arg validation, warn_error strictness, generic test argument shape, duplicate resource names, ref resolution order, `generate_schema_name` validity, `sql_header` inheritance, analysis FQNs, source/semantic-model name spacing, Jinja file extensions, versioned-model pointers, catalogs v2 — none applicable, so **no flags were pinned** in `dbt_project.yml`.

## Manual actions (2)

1. **Warehouse schema/permissions** — fix `USAGE` grant or schema provisioning for `JULIEN.CSG_SA_JULIEN_HACKATHON` (see above), then re-run `dbt build` to complete verification.
2. **Out-of-repo job commands (issue `1_7_001`/`1_8_002`)** — this dbt platform project (614355) has zero jobs configured, so there was nothing to audit here. However, `.github/workflows/*.yml` trigger dbt Cloud jobs in a **different** account/project (account `188483`, projects `283328`/`275557`/`288405`) via the dbt Cloud API — outside what this tool can inspect. Please audit those jobs' commands directly in that account for any `dbt deps --add-package ... --dry-run` (replace with `dbt deps --lock`) or `--select state:modified` usage, since the behavior for both changed between 1.7 and 1.12.

## Jobs to flip

None — this project (614355) has no jobs configured in the dbt platform. `migration_jobs.json` reflects this (empty `jobs` list). The external account noted above is out of scope for this tool but should be reviewed and have its environments/jobs moved to the v2 Stable release track separately.

## Files changed

None. No code, YAML, or `dbt_project.yml` edits were required — the only repo changes were git hygiene (discarding a stray `package-lock.yml` diff and creating the `fix/v2-stable-migration` branch).
