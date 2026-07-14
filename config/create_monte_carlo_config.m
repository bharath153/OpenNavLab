function config = create_monte_carlo_config()
%CREATE_MONTE_CARLO_CONFIG Configure Phase 6 Monte Carlo validation.
%
% The complete GPS/IMU EKF simulation is repeated with independent:
%
%   - IMU measurement noise
%   - IMU bias random walks
%   - GPS measurement noise
%   - initial navigation-state errors
%   - initial true sensor-bias variations
%
% Start with 100 runs for implementation validation.
% Increase to 500 runs for the final research results.

    %% Number of simulations

    config.number_of_runs = 500;

    %% Random-seed offsets

    config.imu_seed_offset = 10000;
    config.gps_seed_offset = 20000;
    config.initialization_seed_offset = 30000;

    %% Initial navigation-state errors

    config.initial_position_error_std_x = 2.0;    % [m]
    config.initial_position_error_std_y = 2.0;    % [m]

    config.initial_velocity_error_std_x = 0.50;   % [m/s]
    config.initial_velocity_error_std_y = 0.50;   % [m/s]

    config.initial_heading_error_std = ...
        deg2rad(2.0);                             % [rad]

    %% Variation in true initial sensor biases

    config.true_accelerometer_bias_variation_std_x = ...
        0.010;                                    % [m/s^2]

    config.true_accelerometer_bias_variation_std_y = ...
        0.010;                                    % [m/s^2]

    config.true_gyroscope_bias_variation_std = ...
        deg2rad(0.010);                           % [rad/s]

    %% NIS consistency configuration

    % Upper 95% chi-square threshold for a two-dimensional measurement.
    config.nis_95_threshold = 5.991;

    %% Progress reporting

    config.progress_report_interval = 10;

    %% Validation limits

    % These are deliberately broad sanity limits rather than performance
    % targets. They identify numerical divergence or implementation errors.

    config.maximum_allowed_position_rmse = 50;       % [m]
    config.maximum_allowed_mean_nis = 5;
    config.minimum_allowed_mean_nis = 0.25;
end