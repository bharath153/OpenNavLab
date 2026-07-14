function config = create_ekf_config(imu_config, gps_config)
%CREATE_EKF_CONFIG Create the configuration for the GPS/IMU EKF.
%
% State vector:
%
%   x = [px, py, vx, vy, psi, bax, bay, bg]'
%
% where:
%
%   px, py = navigation-frame position [m]
%   vx, vy = navigation-frame velocity [m/s]
%   psi    = heading [rad]
%   bax    = accelerometer X-axis bias [m/s^2]
%   bay    = accelerometer Y-axis bias [m/s^2]
%   bg     = gyroscope bias [rad/s]

    %% Validate required inputs

    if nargin ~= 2
        error( ...
            'create_ekf_config requires IMU and GPS configurations.');
    end

    %% State indices

    config.index.position_x = 1;
    config.index.position_y = 2;

    config.index.velocity_x = 3;
    config.index.velocity_y = 4;

    config.index.heading = 5;

    config.index.accelerometer_bias_x = 6;
    config.index.accelerometer_bias_y = 7;

    config.index.gyroscope_bias = 8;

    config.number_of_states = 8;

    %% IMU measurement-noise parameters

    config.accelerometer_noise_std_x = ...
        imu_config.accelerometer.measurement_noise_std_x;

    config.accelerometer_noise_std_y = ...
        imu_config.accelerometer.measurement_noise_std_y;

    config.gyroscope_noise_std = ...
        imu_config.gyroscope.measurement_noise_std;

    %% IMU bias random-walk parameters

    config.accelerometer_bias_random_walk_std_x = ...
        imu_config.accelerometer.bias_random_walk_std_x;

    config.accelerometer_bias_random_walk_std_y = ...
        imu_config.accelerometer.bias_random_walk_std_y;

    config.gyroscope_bias_random_walk_std = ...
        imu_config.gyroscope.bias_random_walk_std;

    %% GPS measurement-noise parameters

    config.gps_position_noise_std_x = ...
        gps_config.position_noise_std_x;

    config.gps_position_noise_std_y = ...
        gps_config.position_noise_std_y;

    config.gps_measurement_covariance = diag( ...
        [config.gps_position_noise_std_x^2, ...
         config.gps_position_noise_std_y^2]);

    %% Initial-state uncertainty

    initial_position_std = 5.0;             % [m]
    initial_velocity_std = 2.0;             % [m/s]
    initial_heading_std = deg2rad(10);      % [rad]

    initial_accelerometer_bias_std = 0.10;   % [m/s^2]
    initial_gyroscope_bias_std = ...
        deg2rad(0.20);                      % [rad/s]

    config.initial_covariance = diag( ...
        [initial_position_std^2, ...
         initial_position_std^2, ...
         initial_velocity_std^2, ...
         initial_velocity_std^2, ...
         initial_heading_std^2, ...
         initial_accelerometer_bias_std^2, ...
         initial_accelerometer_bias_std^2, ...
         initial_gyroscope_bias_std^2]);

    %% Numerical configuration

    config.use_joseph_covariance_update = true;

    % Multiplier applied to the nominal process-noise covariance.
    config.process_noise_scale = 1.0;

    % Numerical tolerance used during validation.
    config.covariance_symmetry_tolerance = 1e-8;
    config.minimum_variance_tolerance = -1e-10;
end