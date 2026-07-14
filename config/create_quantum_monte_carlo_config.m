function config = create_quantum_monte_carlo_config()
%CREATE_QUANTUM_MONTE_CARLO_CONFIG Configure Phase 7C.
%
% The study performs a paired comparison between:
%
%   1. Classical GPS/MEMS EKF
%   2. GPS/MEMS/quantum EKF
%
% Each pair uses identical:
%
%   - MEMS noise
%   - MEMS bias evolution
%   - GPS measurements
%   - GPS outage
%   - initial navigation errors
%
% The quantum-aided case additionally receives the low-rate quantum
% inertial reference measurements.

    %% Monte Carlo settings

    config.number_of_runs = 100;

    config.progress_report_interval = 10;

    %% GPS outage

    config.outage_start_time = 50;        % [s]
    config.outage_end_time = 70;          % [s]

    %% Random-seed offsets

    config.initialization_seed_offset = 81000;
    config.imu_seed_offset = 82000;
    config.gps_seed_offset = 83000;
    config.quantum_seed_offset = 84000;

    %% Initial navigation-state uncertainty

    config.initial_position_error_std_x = 2.0;    % [m]
    config.initial_position_error_std_y = 2.0;    % [m]

    config.initial_velocity_error_std_x = 0.50;   % [m/s]
    config.initial_velocity_error_std_y = 0.50;   % [m/s]

    config.initial_heading_error_std = ...
        deg2rad(2.0);                             % [rad]

    %% MEMS true initial-bias variation

    config.mems_accelerometer_bias_variation_std_x = ...
        0.010;                                    % [m/s^2]

    config.mems_accelerometer_bias_variation_std_y = ...
        0.010;                                    % [m/s^2]

    config.mems_gyroscope_bias_variation_std = ...
        deg2rad(0.010);                           % [rad/s]

    %% Quantum calibration uncertainty
    %
    % The simulated quantum sensor receives a small unknown offset around
    % the nominal calibrated value. The quantum-aided filter continues to
    % use the nominal calibration values.

    config.quantum_accelerometer_calibration_error_std_x = ...
        2.5e-4;                                   % [m/s^2]

    config.quantum_accelerometer_calibration_error_std_y = ...
        2.5e-4;                                   % [m/s^2]

    config.quantum_gyroscope_calibration_error_std = ...
        deg2rad(2.5e-4);                          % [rad/s]

    %% NIS thresholds

    % Two-dimensional GPS position update.
    config.gps_nis_95_threshold = 5.991;

    % Three-dimensional quantum bias-reference update.
    config.quantum_nis_95_threshold = 7.815;

    %% Broad consistency limits

    config.minimum_allowed_gps_mean_nis = 0.25;
    config.maximum_allowed_gps_mean_nis = 5.00;

    config.minimum_allowed_quantum_mean_nis = 0.10;
    config.maximum_allowed_quantum_mean_nis = 15.0;
end