# Reproducibility and runtime

## Determinism

Configuration files contain explicit random seeds. Monte Carlo studies derive deterministic per-run seeds from fixed offsets. Phase 7C and Phase 7D use paired realizations so classical and quantum-aided filters are compared under the same nuisance conditions.

## Recommended execution order

1. Run Phases 1-5 and inspect validation assertions.
2. Run Phase 6A and Phase 6B.
3. Run Phase 7A and Phase 7B.
4. Run Phase 7C.
5. Run Phase 7D last.

## Reference runtimes

Observed on the development Windows machine:

| Study | Workload | Approximate runtime |
|---|---:|---:|
| Phase 6A | 500 classical runs | 139 s |
| Phase 6B | 600 EKF simulations | 163 s |
| Phase 7C | 100 paired runs / 200 filters | 99 s |
| Phase 7D | 3,000 filter simulations | 1,212 s |

Runtime varies with MATLAB release, CPU and graphics export performance.

## Generated data

Scripts write data to `results/data` and figures to `results/figures`. Generated MAT files are ignored in the GitHub-ready repository. CSV summaries and selected figures are retained for review.
