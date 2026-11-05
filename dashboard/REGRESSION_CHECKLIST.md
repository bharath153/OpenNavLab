# OpenNavLab Dashboard v1.0 — Release Checklist

## Launch
- [ ] `clear all`
- [ ] `app = run_opennavlab_dashboard;`
- [ ] No console error
- [ ] Header shows `UI VERIFIED`
- [ ] Header scenario shows the Phase 7B reference: 20 s outage / Q = 1 Hz

## Reference single-run
- [ ] Overview uses repository Phase 7B values
- [ ] Replay works
- [ ] GPS denied between 50 and 70 s
- [ ] Quantum badge stays stable
- [ ] Errors page updates with replay cursor
- [ ] Quantum bias/NIS plots are visible

## Mission
- [ ] Apply Preview changes the visualization and marks preview mode
- [ ] Restore Reference returns to Phase 7B
- [ ] Load MAT Results accepts the repository Phase 7B MAT

## Evolution
- [ ] Phase 3 / Phase 5 / Phase 7B values display
- [ ] Phase 7D ensemble result remains separate

## Monte Carlo
- [ ] Status says `Published Phase 7C`
- [ ] 100 paired runs
- [ ] Metric selector works
- [ ] Run selector works
- [ ] Max-outage classical mean ≈ 5.662427 m
- [ ] Max-outage quantum mean ≈ 4.820971 m
- [ ] Runs improved = 66%

## Sensitivity
- [ ] Status says `Published Phase 7D`
- [ ] 4 rates x 6 outage durations
- [ ] 40 s / 2 Hz = 14.817725 -> 7.929148 m
- [ ] Ensemble-mean reduction ≈ 46.4888%
- [ ] P95 reduction ≈ 49.5425%
- [ ] Runs improved = 78%

## Evidence
- [ ] Run Dashboard Self-Test -> PASS
- [ ] Export Evidence Package succeeds
- [ ] Export includes Phase 7C paired-run CSV
- [ ] Export includes Phase 7D summary CSV
- [ ] Export includes dashboard manifest and plots

## Close
- [ ] Close dashboard
- [ ] `timerfindall('Name','OpenNavLab navigation playback')`
- [ ] Expected: empty timer array
