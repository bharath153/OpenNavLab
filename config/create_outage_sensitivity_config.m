function config = create_outage_sensitivity_config()
%CREATE_OUTAGE_SENSITIVITY_CONFIG Configure Phase 6B.
%
% The study investigates how navigation performance changes as the
% duration of a GPS outage increases.
%
% All outage cases begin at the same simulation time. Common random
% numbers are used so that each outage duration experiences the same:
%
%   - IMU white noise
%   - IMU bias random walk
%   - GPS measurement noise
%   - initial navigation errors
%   - true initial sensor-bias variation
%
% Only the GPS outage duration changes.

    %% Monte Carlo configuration

    % Start with 100 runs for each outage duration.
    config.number_of_runs = 100;

    %% Outage-duration cases [s]

    config.outage_durations = ...
        [0, 5, 10, 20, 30, 40];

    % Common outage start time [s]
    config.outage_start_time = 50;

    %% Random-seed offsets

    config.imu_seed_offset = 40000;
    config.gps_seed_offset = 50000;
    config.initialization_seed_offset = 60000;

    %% Initial navigation-state errors

    config.initial_position_error_std_x = 2.0;   % [m]
    config.initial_position_error_std_y = 2.0;   % [m]

    config.initial_velocity_error_std_x = 0.50;  % [m/s]
    config.initial_velocity_error_std_y = 0.50;  % [m/s]

    config.initial_heading_error_std = ...
        deg2rad(2.0);                            % [rad]

    %% True initial sensor-bias variation

    config.true_accelerometer_bias_variation_std_x = ...
        0.010;                                   % [m/s^2]

    config.true_accelerometer_bias_variation_std_y = ...
        0.010;                                   % [m/s^2]

    config.true_gyroscope_bias_variation_std = ...
        deg2rad(0.010);                          % [rad/s]

    %% Progress reporting

    config.progress_report_interval = 10;

    %% Consistency limits

    config.minimum_allowed_mean_nis = 0.25;
    config.maximum_allowed_mean_nis = 5.0;
end