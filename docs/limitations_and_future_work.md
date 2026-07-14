# Limitations and future work

## Current limitations

### Planar kinematics

The project is two-dimensional. It does not model roll, pitch, vertical motion, gravity projection, Earth rotation, Coriolis acceleration or geodetic coordinate transformations.

### Synthetic motion and sensors

The ground truth is prescribed and all sensors are simulated. The results demonstrate algorithmic behaviour under the selected stochastic models, not flight-test or road-test performance.

### Simplified GPS errors

GPS noise is independent Gaussian position noise. Multipath, satellite geometry, colored errors, spoofing, jamming, reacquisition latency and receiver clock effects are not modelled.

### Navigation-level quantum abstraction

The quantum model assumes an unwrapped, calibrated inertial output. It does not yet include:

- atom-interferometer fringe ambiguity;
- vibration and laser phase noise;
- contrast loss and finite detection probability;
- cycle dead time and aliasing;
- scale-factor and axis-alignment uncertainty;
- time synchronization and latency;
- lever-arm effects;
- laboratory control loops or hardware interfaces.

### Filter assumptions

The EKF assumes Gaussian noise and uses fixed covariance matrices. It does not use innovation gating, adaptive covariance estimation, robust loss functions or multiple-model logic.

## Recommended next research steps

1. Extend the state and mechanisation to 3D quaternion navigation in a local NED frame.
2. Introduce gravity, Earth rotation and realistic inertial scale-factor/misalignment errors.
3. Add GPS multipath, jamming, spoofing and variable satellite availability.
4. Model atom-interferometer phase wrapping, dead time and classical-IMU fringe-order resolution.
5. Add timing latency and asynchronous sensor fusion.
6. Compare EKF, error-state EKF, UKF and factor-graph formulations.
7. Add innovation gating and adaptive measurement covariance.
8. Validate against a public real IMU/GNSS dataset before hardware-in-the-loop testing.
9. Build a small hardware demonstrator with a conventional IMU/GNSS receiver while retaining the quantum sensor as a simulated input.

## Interpretation boundary

All reported improvements are conditional on the chosen simulation assumptions. They support the research hypothesis that a stable low-rate inertial reference can constrain MEMS bias during GPS denial; they do not establish the performance of a specific physical quantum sensor.
