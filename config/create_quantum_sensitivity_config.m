function config = create_quantum_sensitivity_config()
%CREATE_QUANTUM_SENSITIVITY_CONFIG Configure OpenNavLab Phase 7D.
%
% Phase 7D evaluates:
%   - multiple GPS-outage durations;
%   - multiple quantum-sensor update frequencies;
%   - classical GPS/MEMS navigation;
%   - quantum-aided GPS/MEMS navigation.
%
% Every paired comparison uses the same MEMS measurements, GPS
% measurements, initial-state errors, MEMS-bias evolution and underlying
% quantum-sensor realization.

    %% Monte Carlo settings

    % Final study size.
    config.number_of_runs = 100;

    config.progress_report_interval = 5;

    %% GPS-outage study

    config.outage_start_time = 50;              % [s]

    config.outage_durations = ...
        [0, 5, 10, 20, 30, 40];                % [s]

    % The zero-duration case is a reference error evaluated at the outage
    % start time rather than a maximum error over a denied interval.
    config.outage_plot_labels = ...
        ["No outage", "5", "10", "20", "30", "40"];

    %% Quantum-rate study

    % The highest rate must be an integer multiple of every lower rate so
    % that lower-rate measurements can be obtained by exact subsampling.
    config.quantum_update_frequencies = ...
        [0.25, 0.50, 1.00, 2.00];              % [Hz]

    %% Random-seed offsets

    config.initialization_seed_offset = 91000;
    config.imu_seed_offset = 92000;
    config.gps_seed_offset = 93000;
    config.quantum_seed_offset = 94000;

    %% Initial-state uncertainty

    config.initial_position_error_std_x = 2.0;  % [m]
    config.initial_position_error_std_y = 2.0;  % [m]

    config.initial_velocity_error_std_x = 0.50; % [m/s]
    config.initial_velocity_error_std_y = 0.50; % [m/s]

    config.initial_heading_error_std = ...
        deg2rad(2.0);                           % [rad]

    %% MEMS initial-bias variation

    config.mems_accelerometer_bias_variation_std_x = ...
        0.010;                                  % [m/s^2]

    config.mems_accelerometer_bias_variation_std_y = ...
        0.010;                                  % [m/s^2]

    config.mems_gyroscope_bias_variation_std = ...
        deg2rad(0.010);                         % [rad/s]

    %% Quantum calibration uncertainty

    config.quantum_accelerometer_calibration_error_std_x = ...
        2.5e-4;                                 % [m/s^2]

    config.quantum_accelerometer_calibration_error_std_y = ...
        2.5e-4;                                 % [m/s^2]

    config.quantum_gyroscope_calibration_error_std = ...
        deg2rad(2.5e-4);                        % [rad/s]

    %% NIS thresholds

    % Two-dimensional GPS position update.
    config.gps_nis_95_threshold = 5.991;

    % Three-dimensional quantum bias-reference update.
    config.quantum_nis_95_threshold = 7.815;

    %% Broad innovation-consistency limits

    config.minimum_allowed_gps_mean_nis = 0.25;
    config.maximum_allowed_gps_mean_nis = 5.00;

    config.minimum_allowed_quantum_mean_nis = 0.25;
    config.maximum_allowed_quantum_mean_nis = 10.0;

    %% Study description

    config.study_name = ...
        'GPS-outage duration and quantum-update-rate sensitivity';
end
