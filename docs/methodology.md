# Methodology and phase map

OpenNavLab is organised as a sequence of increasingly complex validation phases. Each phase is executable independently and saves both numerical results and figures.

## Phase 1 — Deterministic ground truth

A 120 s planar vehicle trajectory is generated at 100 Hz. The commanded motion contains acceleration, constant-speed segments, positive and negative yaw-rate manoeuvres and a final deceleration to rest. The output contains navigation-frame position, velocity and acceleration together with body-frame acceleration, heading and yaw rate.

Reference values from the current dataset:

- final position: 868.576 m, 227.041 m;
- maximum speed: 10.000 m/s;
- final heading: -15 degrees;
- lateral acceleration range: -0.8727 to 0.6981 m/s².

## Phase 2 — Virtual MEMS IMU

The ideal body-frame accelerations and yaw rate are corrupted with per-sample white noise and bias random walks. The baseline sensor uses accelerometer biases of +0.030 and -0.020 m/s² and a gyroscope bias of 0.001 rad/s.

## Phase 3 — Inertial dead reckoning

Three cases are compared:

1. ideal inertial measurements;
2. white noise only;
3. white noise plus evolving sensor bias.

This isolates the effect of bias accumulation. The complete virtual IMU reaches 235.271 m final position error and 103.170 m position RMSE.

## Phase 4 — Virtual GPS

A two-dimensional 1 Hz GPS provides position measurements with 2.5 m standard deviation per axis. Measurements are suppressed during configurable outage windows. The reference case uses a 50-70 s outage.

## Phase 5 — Classical GPS/MEMS EKF

An eight-state EKF predicts at the IMU rate and corrects position whenever GPS is available. The filter estimates position, velocity, heading and three MEMS biases. Joseph-form covariance correction is used to preserve numerical symmetry and positive semidefiniteness.

## Phase 6A — Classical Monte Carlo validation

Random initial-state errors, sensor biases, white noise, bias random walks and GPS measurements are regenerated for every run. Performance is reported using mean, median, P05, P95 and confidence intervals. Innovation consistency is assessed with the two-degree-of-freedom GPS NIS.

## Phase 6B — GPS-outage sensitivity

Outage durations of 0, 5, 10, 20, 30 and 40 s are evaluated. The no-outage case reports the navigation error at the reference time of 50 s; the other cases report maximum error during the denied interval.

## Phase 7A — Virtual quantum inertial reference

A low-rate cold-atom reference provides acceleration and yaw-rate measurements with lower bias instability than the MEMS sensor. Equivalent acceleration phase is generated with

```math
\phi = k_{\mathrm{eff}} a T^2.
```

The current phase assumes that fringe order has already been resolved.

## Phase 7B — Quantum-aided EKF

The quantum measurement is converted into a direct pseudo-measurement of MEMS accelerometer and gyroscope biases. These measurements supplement GPS position corrections and remain available through the GPS outage.

## Phase 7C — Paired quantum Monte Carlo validation

Classical and quantum-aided filters use the same random initialization, MEMS trajectory and GPS measurements in every paired run. This controls nuisance variability and allows the paired error reduction to be analysed directly.

## Phase 7D — Quantum-rate/outage sensitivity

Quantum update rates of 0.25, 0.5, 1 and 2 Hz are evaluated over the six outage cases. Lower-rate quantum datasets are exact subsets of the maximum-rate realization, preserving paired comparisons across rates.

The final study contains 100 Monte Carlo runs and 3,000 filter simulations.
