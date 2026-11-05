# OpenNavLab Dashboard — Validation and Evidence

## 1. Scope

Validation here is software regression validation. `UI VERIFIED` means the dashboard is correctly connected to the saved OpenNavLab outputs and selected displayed values match the repository artifacts.

## 2. Built-in self-test

Launch the dashboard and use:

**Evidence → Run Dashboard Self-Test**

Validated release result:

```text
PASS - 15/15 checks passed.
```

The suite checks:
- dashboard version metadata;
- playback timer ownership;
- single-run dimensions;
- production-data provenance;
- Phase 7B position RMSE values;
- Phase 7B maximum outage errors;
- outage timing and quantum update rate;
- Phase 7C 100 paired runs;
- Phase 7C aggregate maximum-outage statistics;
- Phase 7D 4 × 6 grid;
- Phase 7D production provenance;
- Phase 7D 40 s / 2 Hz reference values;
- project-evolution provenance;
- page construction validity.

## 3. Timer cleanup

After closing:

```matlab
timerfindall('Name','OpenNavLab navigation playback')
```

Expected:

```matlab
ans =

     []
```

This was manually confirmed for the release candidate.

## 4. Screenshot export

```matlab
files = export_dashboard_screenshots(app);
```

completed successfully for the release candidate.

## 5. Evidence package

Evidence export contains dashboard data/metrics, scenario description, manifest, self-test result, Phase 7C and Phase 7D source CSVs, trajectory/error/bias/NIS/evolution/sensitivity figures.

The export does not rerun the estimator.

## 6. Validated reference values

### Phase 7B
- classical position RMSE: 2.7659405 m;
- quantum position RMSE: 2.2322846 m;
- classical maximum outage error: 8.849205 m;
- quantum maximum outage error: 6.639959 m;
- outage: 50–70 s;
- quantum update rate: 1 Hz.

### Phase 7C
- 100 paired runs;
- classical maximum-outage mean: 5.6624269 m;
- quantum maximum-outage mean: 4.8209707 m;
- mean paired absolute gain: 0.8414562 m;
- improved runs: 66%.

### Phase 7D at 40 s / 2 Hz
- classical ensemble mean: 14.817725 m;
- quantum ensemble mean: 7.929148 m;
- ensemble-mean reduction: 46.4888%;
- P95 reduction: 49.5425%;
- improved runs: 78%;
- quantum mean NIS: 2.99263.

## 7. Limitations

Not included:
- NEES;
- 3D navigation;
- physical atom-interferometer fringe ambiguity;
- lever arms/misalignment;
- hardware latency;
- real sensor data;
- HIL validation.
