# Mathematical model

## Coordinate frames

OpenNavLab uses a two-dimensional navigation frame and a planar body frame. Heading `psi` rotates body-frame acceleration into the navigation frame:

```math
\mathbf{R}_{b}^{n}(\psi)=
\begin{bmatrix}
\cos\psi & -\sin\psi\\
\sin\psi & \cos\psi
\end{bmatrix}.
```

## Dead-reckoning mechanisation

For a uniform time step `dt`, body acceleration is transformed as

```math
\mathbf{a}^{n}_k = \mathbf{R}_{b}^{n}(\psi_k)\mathbf{a}^{b}_k.
```

The discrete propagation is

```math
\mathbf{p}_{k+1}=\mathbf{p}_k+\mathbf{v}_k\Delta t+
\frac{1}{2}\mathbf{a}^{n}_k\Delta t^2,
```

```math
\mathbf{v}_{k+1}=\mathbf{v}_k+\mathbf{a}^{n}_k\Delta t,
```

```math
\psi_{k+1}=\operatorname{wrap}(\psi_k+\omega_k\Delta t).
```

## MEMS measurement model

The virtual MEMS measurements are

```math
\tilde{a}_{x}=a_x+b_{a_x}+n_{a_x},
```

```math
\tilde{a}_{y}=a_y+b_{a_y}+n_{a_y},
```

```math
\tilde{\omega}=\omega+b_g+n_g.
```

The biases are random walks:

```math
b_{k+1}=b_k+\sigma_{rw}\sqrt{\Delta t}\,w_k,
\qquad w_k\sim\mathcal{N}(0,1).
```

Baseline MEMS settings are:

| Parameter | Value |
|---|---:|
| Accelerometer white noise | 0.050 m/s² per sample per axis |
| Accelerometer bias random walk | 5.0e-4 m/s²/√s per axis |
| Gyroscope white noise | 0.002 rad/s per sample |
| Gyroscope bias random walk | 2.0e-5 rad/s/√s |

## GPS measurement model

GPS supplies position only:

```math
\mathbf{z}_{GPS,k}=
\begin{bmatrix}p_x\\p_y\end{bmatrix}_k+
\mathbf{v}_{GPS,k},
```

with

```math
\mathbf{R}_{GPS}=\operatorname{diag}(2.5^2,2.5^2)\;\mathrm{m}^2.
```

The measurement is omitted during the configured outage interval.

## Navigation state

The classical and quantum-aided filters use

```math
\mathbf{x}=
\begin{bmatrix}
p_x&p_y&v_x&v_y&\psi&b_{a_x}&b_{a_y}&b_g
\end{bmatrix}^{T}.
```

Bias-corrected MEMS measurements drive the nonlinear state prediction.
