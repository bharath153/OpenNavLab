# Extended Kalman Filter formulation

## State prediction

The EKF predicts at the 100 Hz MEMS rate. For the current state estimate, measured acceleration is corrected using the estimated biases and rotated into the navigation frame. Position, velocity and heading are then propagated with the nonlinear mechanisation equations.

The three sensor-bias states follow zero-mean random-walk dynamics, so their expected value is unchanged during prediction.

## Linearisation

The state-transition Jacobian includes:

- position sensitivity to velocity;
- position and velocity sensitivity to heading;
- position and velocity sensitivity to accelerometer bias;
- heading sensitivity to gyroscope bias.

The process-noise mapping injects MEMS white noise into position, velocity and heading and injects continuous-time random-walk increments into the three bias states.

## GPS update

The GPS measurement matrix is

```math
\mathbf{H}_{GPS}=
\begin{bmatrix}
1&0&0&0&0&0&0&0\\
0&1&0&0&0&0&0&0
\end{bmatrix}.
```

For innovation `nu` and innovation covariance `S`, the gain is

```math
\mathbf{K}=\mathbf{P}^{-}\mathbf{H}^{T}\mathbf{S}^{-1}.
```

The implementation uses the Joseph covariance update:

```math
\mathbf{P}^{+}=(\mathbf{I}-\mathbf{K}\mathbf{H})
\mathbf{P}^{-}(\mathbf{I}-\mathbf{K}\mathbf{H})^{T}
+\mathbf{K}\mathbf{R}\mathbf{K}^{T}.
```

This is more numerically robust than the simplified covariance expression.

## Quantum bias update

The quantum update observes the three MEMS bias states directly:

```math
\mathbf{H}_{q}=
\begin{bmatrix}
0&0&0&0&0&1&0&0\\
0&0&0&0&0&0&1&0\\
0&0&0&0&0&0&0&1
\end{bmatrix}.
```

The update uses the same linear Kalman correction and Joseph covariance form as the GPS update.

## Innovation consistency

Normalized innovation squared is evaluated as

```math
\mathrm{NIS}=\boldsymbol{\nu}^{T}\mathbf{S}^{-1}\boldsymbol{\nu}.
```

The theoretical expected values are 2 for the two-dimensional GPS update and 3 for the three-dimensional quantum bias-reference update. The 95% thresholds used in the project are 5.991 and 7.815, respectively.
