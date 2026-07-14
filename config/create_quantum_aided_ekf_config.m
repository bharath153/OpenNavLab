function config = create_quantum_aided_ekf_config( ...
    imu_config, ...
    gps_config, ...
    quantum_config)
%CREATE_QUANTUM_AIDED_EKF_CONFIG Configure the quantum-aided EKF.
%
% State vector:
%
%   x = [px, py, vx, vy, psi, bax, bay, bg]'
%
% The filter uses:
%
%   - MEMS IMU for 100 Hz state prediction
%   - GPS position measurements when available
%   - low-rate quantum measurements to observe MEMS sensor biases
%
% Quantum-derived pseudo-measurements:
%
%   z_bax = a_MEMS,x - a_quantum,x + b_quantum,x,nominal
%   z_bay = a_MEMS,y - a_quantum,y + b_quantum,y,nominal
%   z_bg  = w_MEMS   - w_quantum   + b_quantum,g,nominal
%
% Ideally:
%
%   z_quantum_bias = [bax, bay, bg]' + measurement noise

    if nargin ~= 3
        error( ...
            ['create_quantum_aided_ekf_config requires IMU, GPS ' ...
             'and quantum-sensor configurations.']);
    end

    %% Start from the classical GPS/IMU EKF configuration

    config = create_ekf_config( ...
        imu_config, ...
        gps_config);

    %% Quantum update configuration

    config.quantum.enabled = true;

    config.quantum.measurement_covariance_scale = 1.0;

    %% Nominal calibrated quantum biases

    config.quantum.nominal_accelerometer_bias_x = ...
        quantum_config.accelerometer.initial_bias_x;

    config.quantum.nominal_accelerometer_bias_y = ...
        quantum_config.accelerometer.initial_bias_y;

    config.quantum.nominal_gyroscope_bias = ...
        quantum_config.gyroscope.initial_bias;

    %% MEMS white-noise levels

    config.quantum.mems_accelerometer_noise_std_x = ...
        imu_config.accelerometer.measurement_noise_std_x;

    config.quantum.mems_accelerometer_noise_std_y = ...
        imu_config.accelerometer.measurement_noise_std_y;

    config.quantum.mems_gyroscope_noise_std = ...
        imu_config.gyroscope.measurement_noise_std;

    %% Quantum white-noise levels

    config.quantum.quantum_accelerometer_noise_std_x = ...
        quantum_config.accelerometer.noise_std_x;

    config.quantum.quantum_accelerometer_noise_std_y = ...
        quantum_config.accelerometer.noise_std_y;

    config.quantum.quantum_gyroscope_noise_std = ...
        quantum_config.gyroscope.noise_std;

    %% Quantum bias random-walk levels

    config.quantum.quantum_accelerometer_bias_rw_std_x = ...
        quantum_config.accelerometer.bias_random_walk_std_x;

    config.quantum.quantum_accelerometer_bias_rw_std_y = ...
        quantum_config.accelerometer.bias_random_walk_std_y;

    config.quantum.quantum_gyroscope_bias_rw_std = ...
        quantum_config.gyroscope.bias_random_walk_std;

    %% Quantum-bias calibration uncertainty
    %
    % The nominal initial quantum bias is treated as calibrated, but not
    % perfectly known. These values represent uncertainty in that
    % calibration.

    config.quantum.accelerometer_bias_calibration_std_x = ...
        2.5e-4;                                      % [m/s^2]

    config.quantum.accelerometer_bias_calibration_std_y = ...
        2.5e-4;                                      % [m/s^2]

    config.quantum.gyroscope_bias_calibration_std = ...
        deg2rad(2.5e-4);                             % [rad/s]

    %% Statistical consistency configuration

    % A three-dimensional quantum bias measurement has three degrees of
    % freedom. The 95% chi-square threshold is approximately 7.815.
    config.quantum.nis_95_threshold = 7.815;

    config.quantum.minimum_allowed_mean_nis = 0.10;
    config.quantum.maximum_allowed_mean_nis = 15.0;

    %% Model description

    config.quantum.model_name = ...
        'MEMS propagation with quantum bias-reference updates';
end