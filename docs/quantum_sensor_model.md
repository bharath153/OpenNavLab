# Quantum inertial reference abstraction

## Purpose

The virtual quantum sensor is intended to study navigation-level fusion, not to reproduce a complete atom-interferometer laboratory. It provides low-rate acceleration and yaw-rate references whose slowly varying biases are much smaller than the MEMS biases.

## Atom-interferometer phase

The equivalent acceleration phase is modelled as

```math
\phi = k_{\mathrm{eff}}aT^2.
```

The baseline parameters are:

| Parameter | Value |
|---|---:|
| Optical wavelength | 780.24 nm |
| Effective wave vector | approximately 1.6106e7 rad/m |
| Interrogation time | 0.050 s |
| Acceleration phase scale | approximately 4.0264e4 rad/(m/s²) |

The code currently stores unwrapped phase and assumes that the classical IMU has resolved fringe order.

## Quantum measurement settings

| Parameter | Value |
|---|---:|
| Acceleration noise | 0.005 m/s² per axis |
| Acceleration initial bias | +0.001 and -0.001 m/s² |
| Acceleration bias random walk | 5.0e-6 m/s²/√s |
| Gyroscope noise | 0.010 deg/s |
| Gyroscope initial bias | 0.001 deg/s |
| Gyroscope bias random walk | 5.0e-5 deg/s/√s |

## MEMS-bias pseudo-measurement

At a quantum update, the filter forms

```math
\mathbf{z}_{q}=
\begin{bmatrix}
\tilde{a}_{x,M}-\tilde{a}_{x,Q}+b_{x,Q,nom}\\
\tilde{a}_{y,M}-\tilde{a}_{y,Q}+b_{y,Q,nom}\\
\tilde{\omega}_{M}-\tilde{\omega}_{Q}+b_{g,Q,nom}
\end{bmatrix}.
```

Ideally this is a direct measurement of

```math
\begin{bmatrix}b_{a_x}&b_{a_y}&b_g\end{bmatrix}^{T}.
```

The pseudo-measurement covariance includes MEMS white noise, quantum white noise, quantum calibration uncertainty and time-growing quantum bias random-walk variance.

## Current assumptions

- phase ambiguity is already resolved;
- MEMS and quantum timestamps are aligned;
- the sensor axes are perfectly aligned;
- there is no lever arm or latency;
- quantum measurements have no dead time;
- vibration and platform-motion rejection are not explicitly modelled.

These assumptions make the sensor suitable for testing the fusion concept while clearly separating it from a hardware-validated claim.
