# OpenNavLab Dashboard Documentation

The OpenNavLab dashboard is the presentation and analysis layer for the saved navigation experiments. Estimator equations, simulation logic and experiment scripts remain in the main OpenNavLab research code; the dashboard consumes their saved outputs.

## Documentation map

- [User Guide](USER_GUIDE.md) — launch, navigation and page-by-page usage.
- [Architecture and Data Flow](ARCHITECTURE.md) — dashboard structure, source artifacts and separation from estimator code.
- [Validation and Evidence](VALIDATION.md) — self-test, timer cleanup, evidence export and validation scope.
- [Reproducibility](REPRODUCIBILITY.md) — regenerate research outputs and reproduce dashboard figures.
- [Screenshot Captions](SCREENSHOT_CAPTIONS.md) — captions for the six dashboard images.
- [Release Notes](RELEASE_NOTES.md) — v1.0 through v1.0.2 changes.
- [Reference Data Manifest](REFERENCE_DATA_MANIFEST.md) — hashes for compact dashboard reference files.

## Evidence-backed pages

| Dashboard page | Primary source |
|---|---|
| Overview | Phase 7B reference run |
| Replay | Phase 7B reference run |
| Mission | Interactive preview; reference can be restored |
| Errors | Phase 7B reference run |
| Project Evolution | Phase 3/5/7B metrics + Phase 7D ensemble result |
| Quantum | Phase 7B bias estimates and NIS channels |
| Monte Carlo | Phase 7C paired 100-run CSV |
| Sensitivity | Phase 7D 24-point sensitivity CSV |
| Evidence | Regression checks and exported evidence package |

The Mission page is the only page that can create a synthetic visualization scenario. These scenarios are explicitly labelled **Preview** and are not presented as rerun EKF results.

## Screenshots

The six validated UI screenshots are stored under [screenshots/](screenshots/).

Recommended main README visuals:
1. `01_overview.png`
2. `02_replay_gps_outage.png`
3. `05_sensitivity.png`

## Current validation status

The release candidate was manually checked in MATLAB with:
- dashboard self-test: **15/15 passed**;
- screenshot export: completed successfully;
- playback timer after dashboard close: empty timer array;
- startup timer-precision warning removed in v1.0.1.

The UI label `UI VERIFIED` describes dashboard regression status only. It is not a claim of hardware validation of the quantum sensor abstraction.
