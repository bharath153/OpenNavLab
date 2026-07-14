# Application-ready project summary

## CV title

**OpenNavLab — Quantum-Aided Resilient Navigation | MATLAB**

## CV bullets

- Developed a MATLAB research platform for planar GPS/IMU navigation, including deterministic vehicle motion, MEMS white-noise and bias-random-walk models, GPS outages, inertial dead reckoning and an eight-state Extended Kalman Filter.
- Implemented a low-rate cold-atom inertial reference abstraction and fused quantum-derived MEMS bias pseudo-measurements with GPS/MEMS navigation while maintaining statistically consistent GPS and quantum NIS behaviour.
- Executed a 100-run paired sensitivity study across 0-40 s GPS outages and 0.25-2 Hz quantum update rates; a 2 Hz reference reduced the ensemble mean maximum error during a 40 s outage from 14.82 m to 7.93 m (46.5%) and improved 78% of runs.

## LinkedIn project description

Built OpenNavLab, a software-only MATLAB platform for resilient navigation under GPS denial. The project progresses from ground-truth trajectory generation and virtual MEMS/GPS sensors to an eight-state GPS/IMU EKF, Monte Carlo validation and a low-rate quantum inertial bias reference. In the final 100-run sensitivity study, a 2 Hz quantum reference reduced the ensemble mean maximum position error during a 40-second GPS outage by 46.5%, while the GPS and quantum NIS remained close to their theoretical expectations.

## Cover-letter paragraph

To strengthen my preparation for research on hybrid classical-quantum navigation, I developed OpenNavLab, a MATLAB simulation platform that combines high-rate MEMS propagation, GPS position updates and a low-rate cold-atom inertial reference within an eight-state EKF. I validated the approach through paired Monte Carlo studies and GPS-outage sensitivity analysis rather than relying on a single favourable run. In a 100-run study, a 2 Hz quantum bias reference reduced the ensemble mean maximum position error during a 40-second GPS outage from 14.82 m to 7.93 m, while innovation statistics remained consistent with their expected dimensions. The project also made the current modelling assumptions explicit, including the use of an unwrapped navigation-level quantum sensor abstraction, and provides a clear route toward phase ambiguity, latency and hardware-in-the-loop extensions.

## Interview explanation

The core idea is that the MEMS IMU supplies high-rate motion information but its bias accumulates during GPS denial. A slower but more stable quantum reference does not replace the MEMS sensor; it periodically observes the MEMS bias. The EKF then retains high bandwidth from MEMS propagation while limiting long-term drift through low-rate quantum updates.

## One-sentence result

A low-rate stable inertial reference became increasingly valuable as GPS-denial duration increased, reducing the 40-second ensemble mean maximum position error by 46.5% at 2 Hz and by 41.2% at 1 Hz.
