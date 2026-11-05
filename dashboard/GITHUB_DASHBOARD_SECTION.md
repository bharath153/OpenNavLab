## Interactive Research Dashboard

OpenNavLab includes a MATLAB research dashboard that consumes the repository's
saved experiment outputs without duplicating estimator mathematics inside the UI.

### Evidence-backed views

- **Replay / Errors / Quantum:** Phase 7B reference-run MAT output
- **Monte Carlo Explorer:** Phase 7C 100-run paired CSV
- **Sensitivity Explorer:** Phase 7D 24-point outage-duration / quantum-rate CSV
- **Project Evolution:** Phase 5, Phase 7B and Phase 7D saved metrics

The dashboard supports animated replay, synchronized error analysis, quantum
bias/NIS inspection, paired Monte Carlo exploration, sensitivity heatmaps,
project-evolution comparison, regression self-testing and evidence export.

Run:

```matlab
cd dashboard
app = run_opennavlab_dashboard;
```

The Mission page also contains an explicitly labeled **preview mode** for
interactive what-if visualization; preview cases are not presented as rerun EKF
results.
