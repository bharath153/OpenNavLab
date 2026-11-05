# OpenNavLab Dashboard — User Guide

## 1. Launch

From the repository root:

```matlab
cd dashboard
clear all
app = run_opennavlab_dashboard;
```

The dashboard opens on **Overview**. When the full Phase 7B MAT file is available under `results/data/`, the dashboard uses it directly. Otherwise the GitHub-ready package uses the compact Phase 7B dashboard snapshot under `dashboard/data/reference/`.

## 2. Overview

The default reference is the Phase 7B quantum-aided navigation run.

Reference case:
- GPS outage: 50–70 s;
- quantum update rate: 1 Hz;
- classical position RMSE: 2.7659405 m;
- quantum-aided position RMSE: 2.2322846 m;
- classical maximum outage error: 8.849205 m;
- quantum-aided maximum outage error: 6.639959 m.

## 3. Replay

Replay animates truth, classical GPS/MEMS EKF and quantum-aided EKF trajectories.

Controls:
- Play / Pause;
- seek slider;
- playback speed;
- reset.

The GPS state changes during the 50–70 s outage.

## 4. Mission

Mission provides an interactive **Preview** mode.

The user can change GPS outage timing and quantum update rate. `Apply Preview` generates a deterministic visualization scenario and does not rerun the production EKFs. `Restore Reference` reloads the saved Phase 7B result.

## 5. Errors

Displays synchronized horizontal position, velocity and heading errors. The moving time cursor follows Replay.

## 6. Project Evolution

Reference-run progression:
- Phase 3 MEMS dead reckoning;
- Phase 5 classical GPS/MEMS EKF;
- Phase 7B quantum-aided EKF.

The Phase 7D 40 s / 2 Hz result is kept separate because it is a 100-run ensemble statistic.

## 7. Quantum

Shows:
- true versus estimated accelerometer bias;
- true versus estimated gyro bias;
- GPS innovation consistency;
- quantum-reference innovation consistency.

Expected NIS dimensions:
- GPS: 2;
- quantum reference: 3.

## 8. Monte Carlo

Uses the real Phase 7C paired 100-run dataset.

Selectable metrics:
- maximum outage error;
- position RMSE;
- final position error;
- velocity RMSE;
- heading RMSE.

For maximum outage error:
- classical mean: 5.6624269 m;
- quantum-aided mean: 4.8209707 m;
- mean paired absolute gain: 0.8414562 m;
- runs improved: 66%.

## 9. Sensitivity

Uses the real Phase 7D grid:
- outage durations: 0, 5, 10, 20, 30, 40 s;
- quantum update rates: 0.25, 0.5, 1, 2 Hz.

At 40 s outage / 2 Hz:
- classical ensemble-mean maximum error: 14.817725 m;
- quantum ensemble-mean maximum error: 7.929148 m;
- reduction between ensemble means: 46.4888%;
- P95 reduction: 49.5425%;
- runs improved: 78%.

## 10. Evidence

Run **Evidence → Run Dashboard Self-Test**.

Validated release target:

```text
PASS - 15/15 checks passed.
```

## 11. Export screenshots

```matlab
files = export_dashboard_screenshots(app);
```

Outputs:
- `01_overview.png`
- `02_replay_gps_outage.png`
- `03_project_evolution.png`
- `04_monte_carlo.png`
- `05_sensitivity.png`
- `06_evidence_validation.png`

## 12. Close and verify cleanup

After closing the dashboard:

```matlab
timerfindall('Name','OpenNavLab navigation playback')
```

Expected:

```matlab
ans =

     []
```
