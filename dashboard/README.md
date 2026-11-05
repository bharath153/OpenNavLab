# OpenNavLab Dashboard v1.0

Release candidate built from the actual OpenNavLab repository result artifacts.

## Default data sources

v1.0 no longer starts from synthetic dashboard research data.

### Single-run Replay / Errors / Quantum
Loaded from:

```text
results/data/phase7b_quantum_aided_navigation.mat
```

The dashboard uses:
- truth trajectory;
- classical GPS/MEMS EKF;
- quantum-aided EKF;
- GPS outage mask;
- MEMS bias realization;
- classical and quantum bias estimates;
- classical GPS NIS;
- quantum-update NIS.

Reference scenario:
- GPS outage: 50–70 s
- quantum update rate: 1 Hz
- classical position RMSE: 2.7659405 m
- quantum position RMSE: 2.2322846 m
- classical maximum outage error: 8.849205 m
- quantum maximum outage error: 6.639959 m

### Monte Carlo Explorer
Loaded from the real 100-run paired dataset:

```text
results/data/phase7c_quantum_monte_carlo_runs.csv
```

For maximum outage position error:
- classical mean: 5.6624269 m
- quantum mean: 4.8209707 m
- mean paired absolute gain: 0.8414562 m
- runs improved: 66%

### Sensitivity Explorer
Loaded from:

```text
results/data/phase7d_quantum_sensitivity_summary.csv
```

At 40 s outage / 2 Hz:
- classical ensemble-mean maximum error: 14.817725 m
- quantum ensemble-mean maximum error: 7.929148 m
- reduction between ensemble means: 46.4888%
- P95 reduction: 49.5425%
- runs improved: 78%
- position RMSE reduction: 23.3604%
- velocity RMSE reduction: 28.4476%
- heading RMSE reduction: 37.9403%
- quantum mean NIS: 2.99263

The dashboard deliberately distinguishes reduction between ensemble means from the
mean of per-run relative reductions.

## Mission preview mode

The Mission page still allows changing outage duration and quantum update rate.
Clicking **Apply Preview** creates a deterministic visualization case only. It
does not rerun the production EKFs and the UI marks the single-run source as a
preview. **Restore Reference** returns to the real Phase 7B result.

## Repository installation

The dashboard can run standalone from this folder.

To integrate it into OpenNavLab, copy this folder to:

```text
OpenNavLab/dashboard/
```

Then run:

```matlab
cd dashboard
app = run_opennavlab_dashboard;
```

When installed there, the loaders first use `OpenNavLab/results/data/`. The
bundled `data/reference/` files remain a fallback.

## Regression test

Run:

```matlab
clear all
app = run_opennavlab_dashboard;
```

Then open:

```text
Evidence -> Run Dashboard Self-Test
```

The v1.0 suite checks the real Phase 7B, Phase 7C and Phase 7D values plus page
construction and timer uniqueness.

After closing the app:

```matlab
timerfindall('Name','OpenNavLab navigation playback')
```

must return an empty timer array.

See:
- `REGRESSION_CHECKLIST.md`
- `REFERENCE_DATA_MANIFEST.md`
- `GITHUB_DASHBOARD_SECTION.md`


## GitHub-integrated mode

The repository integration package does not duplicate the large generated Phase
5 and Phase 7B MAT files. It uses:

- the full `results/data/phase7b_quantum_aided_navigation.mat` when locally available;
- otherwise the compact, real-data `data/reference/phase7b_dashboard_snapshot.mat`;
- a small `phase_evolution_metrics.csv` fallback for cross-phase KPIs;
- the actual Phase 7C and Phase 7D CSV artifacts.

The compact Phase 7B snapshot is decimated only for visualization. KPI values in
the snapshot are the exact values saved from the full 100 Hz Phase 7B reference
run.

### Export README screenshots

With the dashboard open:

```matlab
files = export_dashboard_screenshots(app);
```

This writes six actual UI screenshots to:

```text
docs/dashboard/screenshots/
```


## v1.0.1 timer maintenance

Playback timer periods are quantized to MATLAB's supported 1 ms resolution
before timer construction. This removes the startup precision warning without
changing replay timing at the dashboard's supported playback rates.
