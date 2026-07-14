# Results

This folder contains generated validation outputs.

- `data/` retains CSV summaries and per-run results suitable for review without MATLAB.
- `figures/` contains high-resolution plots produced by the phase scripts.
- Large MAT workspaces are regenerated locally and are excluded from the GitHub-ready package.

The most important final-study files are:

- `data/phase7d_quantum_sensitivity_summary.csv` — complete MATLAB Phase 7D output;
- `data/phase7d_key_results.csv` — curated metrics with explicit ensemble-mean and P95 reductions;
- `figures/phase7d_mean_error_sensitivity.png`;
- `figures/phase7d_p95_error_sensitivity.png`;
- `figures/phase7d_rmse_reduction_heatmaps.png`;
- `figures/phase7d_quantum_nis_heatmap.png`.
