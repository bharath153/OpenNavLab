# Validation results

## Phase 1 — Ground truth

| Metric | Value |
|---|---:|
| Simulation duration | 120 s |
| Time step | 0.01 s |
| Final X position | 868.576 m |
| Final Y position | 227.041 m |
| Maximum speed | 10.000 m/s |
| Final heading | -15.000 deg |

## Phase 2 — MEMS sensor model

| Metric | X accelerometer | Y accelerometer | Gyroscope |
|---|---:|---:|---:|
| Final bias | 0.02242 m/s² | -0.01459 m/s² | 0.06373 deg/s |
| Noise standard deviation | 0.04990 m/s² | 0.05047 m/s² | 0.002004 rad/s |
| Total error RMSE | 0.05630 m/s² | 0.05423 m/s² | 0.002271 rad/s |

## Phase 3 — Dead reckoning

| Case | Position RMSE | Velocity RMSE | Heading RMSE |
|---|---:|---:|---:|
| Ideal IMU | 0.225 m | 0.0058 m/s | 0 deg |
| Noise only | 2.025 m | 0.0412 m/s | 0.0538 deg |
| Noise and bias | 103.170 m | 2.3436 m/s | 4.1217 deg |

The complete virtual IMU reached 235.271 m final position error.

## Phase 4 — GPS

The 1 Hz virtual GPS achieved a horizontal RMSE of 3.390 m and a maximum horizontal error of 9.053 m while suppressing 20 measurements during the 50-70 s outage.

## Phase 5 — Classical GPS/MEMS EKF

| Metric | IMU-only | GPS/IMU EKF |
|---|---:|---:|
| Position RMSE | 103.170 m | 2.766 m |
| Velocity RMSE | 2.3436 m/s | 0.3749 m/s |
| Heading RMSE | 4.1217 deg | 1.7165 deg |

The maximum outage error was 8.849 m. At the first returning GPS measurement it decreased to 1.337 m. Mean GPS NIS was 1.810, with 4.95% of samples above the 95% threshold.

## Phase 6A — 500-run classical validation

| Metric | Mean | P95 |
|---|---:|---:|
| Position RMSE | 2.344 m | 3.313 m |
| Final position error | 1.284 m | 2.554 m |
| Maximum outage error | 5.224 m | 10.084 m |
| Velocity RMSE | 0.4056 m/s | 0.5095 m/s |
| Heading RMSE | 2.943 deg | 4.619 deg |

Mean GPS NIS was 1.927 and the average 95%-threshold exceedance was 4.53%.

## Phase 6B — Outage sensitivity

The classical mean maximum error increased from 1.466 m in the no-outage reference case to 16.729 m for a 40 s outage. The corresponding P95 error increased to 32.814 m.

## Phase 7A — Virtual quantum reference

Acceleration error RMSE was 0.00474 and 0.00496 m/s² for the two axes. Gyroscope error RMSE was approximately 0.01177 deg/s.

## Phase 7B — Single-run quantum aiding

At a 1 Hz quantum update rate:

| Metric | Classical | Quantum-aided |
|---|---:|---:|
| Position RMSE | 2.766 m | 2.232 m |
| Velocity RMSE | 0.3749 m/s | 0.2881 m/s |
| Heading RMSE | 1.7165 deg | 1.1509 deg |
| Maximum outage error | 8.849 m | 6.640 m |

## Phase 7C — Paired 100-run validation

The paired study reduced mean maximum outage error from 5.662 m to 4.821 m. The mean paired improvement was 0.841 m, and 66% of runs improved. Position, velocity and heading RMSE improved in 81%, 99% and 89% of runs.

## Phase 7D — 100-run sensitivity study

At 40 s GPS outage:

| Quantum rate | Mean maximum error | Reduction in ensemble mean | P95 error | Runs improved |
|---:|---:|---:|---:|---:|
| 0.25 Hz | 10.200 m | 31.2% | 18.604 m | 62% |
| 0.50 Hz | 9.734 m | 34.3% | 16.855 m | 67% |
| 1.00 Hz | 8.710 m | 41.2% | 16.087 m | 75% |
| 2.00 Hz | **7.929 m** | **46.5%** | **13.725 m** | **78%** |

The 2 Hz case reduced the P95 error by 49.5% and reduced position, velocity and heading RMSE by 23.4%, 28.4% and 37.9%.

## Statistical interpretation note

`ReductionInEnsembleMeanPercent` in `phase7d_key_results.csv` is computed from the classical and quantum ensemble means. The original Phase 7D summary also stores the mean of per-run relative reductions. The latter can be unstable when an individual classical reference error is close to zero, especially in the no-outage case. Use the absolute paired reduction and its confidence interval for inference, and use the reduction in ensemble mean for the headline system-level comparison.
