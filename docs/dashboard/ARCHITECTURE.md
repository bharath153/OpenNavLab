# OpenNavLab Dashboard — Architecture and Data Flow

## 1. Design principle

The dashboard is deliberately separated from estimator mathematics.

The OpenNavLab research code generates trajectories, sensor measurements, filter estimates, Monte Carlo studies and saved outputs. The dashboard loads those saved outputs, computes presentation metrics where appropriate, visualizes them and exports evidence.

## 2. Structure

```text
dashboard/
├── run_opennavlab_dashboard.m
├── build_dashboard.m
├── callbacks/
├── data/
├── pages/
├── playback/
├── utilities/
└── data/reference/
```

## 3. Data-source priority

### Phase 7B single-run

Priority:
1. `results/data/phase7b_quantum_aided_navigation.mat`
2. `dashboard/data/reference/phase7b_dashboard_snapshot.mat`

The compact fallback comes from the real Phase 7B reference run and is downsampled only for visualization. Exact KPI values remain stored with the snapshot.

### Phase 7C Monte Carlo

Primary:
`results/data/phase7c_quantum_monte_carlo_runs.csv`

Fallback:
`dashboard/data/reference/phase7c_quantum_monte_carlo_runs.csv`

### Phase 7D sensitivity

Primary:
`results/data/phase7d_quantum_sensitivity_summary.csv`

Fallback:
`dashboard/data/reference/phase7d_quantum_sensitivity_summary.csv`

### Project Evolution

Full Phase 5 / Phase 7B saved metrics are preferred when available. GitHub mode also carries `phase_evolution_metrics.csv`.

## 4. Data flow

```text
Saved research artifacts
        ↓
load_* / adapt_* functions
        ↓
Canonical dashboard structures
        ↓
build_dashboard.m
        ↓
Page builders + callbacks + playback
        ↓
Interactive UI
        ↓
Screenshots / evidence export
```

## 5. Preview-mode boundary

Mission Preview:
- changes visualization only;
- is deterministic;
- is explicitly labelled;
- does not call production EKF scripts;
- is not used as research evidence.

## 6. Playback timer

The dashboard owns one timer named:

```text
OpenNavLab navigation playback
```

It uses fixed spacing, drops overlapping callbacks, is deleted on close, and quantizes periods to MATLAB's millisecond precision.

## 7. Validation boundary

The dashboard validates software integration and saved-result consistency. It does not validate a physical quantum sensor, real hardware timing, fringe ambiguity, installation effects, asynchronous latency or real sensor data.
