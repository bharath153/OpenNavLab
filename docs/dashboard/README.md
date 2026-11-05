# OpenNavLab Dashboard

The OpenNavLab dashboard is the interactive presentation layer for the saved
navigation experiments. Estimator mathematics remains in the main OpenNavLab
research code; the dashboard consumes saved outputs and exposes them through
replay, comparison and statistical-analysis views.

## Evidence-backed pages

| Page | Source |
|---|---|
| Overview / Replay / Errors / Quantum | Phase 7B reference run |
| Project Evolution | Phase 3, Phase 5, Phase 7B and Phase 7D saved metrics |
| Monte Carlo | Phase 7C paired 100-run CSV |
| Sensitivity | Phase 7D 24-point summary CSV |
| Evidence | Dashboard regression suite and export package |

The Mission page has a clearly labelled **Preview** mode. Preview cases are
visual what-if scenarios and are not presented as rerun EKF results.

## Generate final screenshots

Launch the dashboard and run:

```matlab
clear all
app = run_opennavlab_dashboard;
files = export_dashboard_screenshots(app);
```

The utility exports the actual live MATLAB UI into this folder:

```text
docs/dashboard/screenshots/
├── 01_overview.png
├── 02_replay_gps_outage.png
├── 03_project_evolution.png
├── 04_monte_carlo.png
├── 05_sensitivity.png
└── 06_evidence_validation.png
```

The Replay screenshot is captured at approximately 60 s, inside the real
50–70 s Phase 7B GPS outage. The Evidence screenshot runs the dashboard self-test
first so the validation state is visible.

## Recommended README images

Use these three as the primary GitHub visuals:

1. `01_overview.png` — immediate project summary.
2. `02_replay_gps_outage.png` — interactive navigation concept.
3. `05_sensitivity.png` — strongest research result.

The other three are useful in this documentation page or a LinkedIn/project post.

## Validation

The v1.0 release was manually tested with:

- dashboard self-test: **15/15 passed**;
- post-close playback timer check: empty timer array.

The dashboard labels its own UI/regression status as `UI VERIFIED`; this should
not be interpreted as hardware validation of the quantum sensor model.
