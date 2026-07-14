function config = create_imu_config()
%CREATE_IMU_CONFIG Create the configuration for the virtual IMU.
%
% The measurement-noise values are per-sample standard deviations at the
% selected simulation sampling frequency.
%
% Bias random-walk values are expressed per square root second:
%
%   accelerometer: [m/s^2/sqrt(s)]
%   gyroscope:     [rad/s/sqrt(s)]
%
% The same random seed is used every time so that the simulation results
% remain reproducible.

    %% Random-number configuration

    config.random_seed = 42;

    %% Accelerometer configuration

    % Initial constant biases [m/s^2]
    config.accelerometer.initial_bias_x = 0.030;
    config.accelerometer.initial_bias_y = -0.020;

    % Per-sample white-noise standard deviations [m/s^2]
    config.accelerometer.measurement_noise_std_x = 0.050;
    config.accelerometer.measurement_noise_std_y = 0.050;

    % Bias random-walk standard deviations [m/s^2/sqrt(s)]
    config.accelerometer.bias_random_walk_std_x = 5.0e-4;
    config.accelerometer.bias_random_walk_std_y = 5.0e-4;

    %% Gyroscope configuration

    % Initial yaw-rate bias [rad/s]
    config.gyroscope.initial_bias = 0.001;

    % Per-sample white-noise standard deviation [rad/s]
    config.gyroscope.measurement_noise_std = 0.002;

    % Bias random-walk standard deviation [rad/s/sqrt(s)]
    config.gyroscope.bias_random_walk_std = 2.0e-5;
end