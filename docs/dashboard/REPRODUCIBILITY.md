# OpenNavLab Dashboard — Reproducibility

## 1. Phase scripts

```text
examples/run_gps_imu_ekf.m
examples/run_quantum_aided_navigation.m
examples/run_quantum_aided_monte_carlo.m
examples/run_quantum_sensitivity_study.m
```

They correspond to Phases 5, 7B, 7C and 7D.

## 2. Expected artifacts

```text
results/data/phase5_gps_imu_ekf.mat
results/data/phase7b_quantum_aided_navigation.mat
results/data/phase7c_quantum_monte_carlo_runs.csv
results/data/phase7c_quantum_monte_carlo_summary.csv
results/data/phase7d_quantum_sensitivity_summary.csv
```

Compact fallbacks live under `dashboard/data/reference/`.

## 3. Reproduce the dashboard

```matlab
cd dashboard
clear all
app = run_opennavlab_dashboard;
```

Run the self-test, then:

```matlab
files = export_dashboard_screenshots(app);
```

## 4. Screenshot workflow

The Replay screenshot is captured near 60 s, inside the real 50–70 s GPS outage.

## 5. Provenance

Repository result files are preferred. Compact fallbacks are used only when full artifacts are unavailable.

The compact Phase 7B snapshot is decimated for visualization while retaining exact full-run KPI values.

## 6. Statistical interpretation

Phase 7C is paired: classical and quantum-aided filters use matched stochastic realizations.

Phase 7D distinguishes:
- reduction between ensemble means;
- mean of per-run relative reductions.

These are not interchangeable statistics.

## 7. Clean shutdown

After close:

```matlab
timerfindall('Name','OpenNavLab navigation playback')
```

should return no timer objects.
