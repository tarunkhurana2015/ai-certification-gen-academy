# Project Specifications (Single Source of Truth)

This directory contains the authoritative specifications for the project following the **Spec-Driven Development (SDD)** lifecycle:

| Specification Document | Purpose |
|---|---|
| [`01_product_scope.md`](./01_product_scope.md) | Vision, target audience, platform matrix, and MVP scope boundaries |
| [`02_user_journeys_and_features.md`](./02_user_journeys_and_features.md) | User journeys, Gherkin acceptance criteria (`Given/When/Then`), and edge cases |
| [`03_architecture_and_monorepo.md`](./03_architecture_and_monorepo.md) | Monorepo layout (`apps/` vs `packages/`), MVVM, state management, and routing |
| [`04_design_system_and_responsive.md`](./04_design_system_and_responsive.md) | Material 3 tokens, responsive breakpoints, and accessibility |
| [`05_api_and_data_contracts.md`](./05_api_and_data_contracts.md) | Entities, DTOs, JSON payloads, and repository interfaces |
| [`06_testing_strategy.md`](./06_testing_strategy.md) | Testing pyramid, Gherkin test mappings, and CI quality gates |
| [`07_implementation_plan.md`](./07_implementation_plan.md) | Phased roadmap and Definition of Done (DoD) |

## Gated Workflow
1. Complete Stage 0 Environment Verification (`flutter-environment-setup`).
2. Complete each spec gate (1 to 7) sequentially with developer interview and sign-off.
3. Validate specs using `validate_specs.sh`.
4. Scaffold the workspace using `flutter-scaffold-project`.
