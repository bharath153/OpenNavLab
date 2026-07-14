function config = create_quantum_sensor_config()
%CREATE_QUANTUM_SENSOR_CONFIG Configure the virtual quantum reference IMU.
%
% The model represents a low-rate cold-atom inertial reference containing:
%
%   - two body-frame acceleration measurements
%   - one yaw-rate measurement
%   - low white noise
%   - low bias offset
%   - slowly varying bias random walk
%   - equivalent atom-interferometer acceleration phase
%
% This is a navigation-level abstraction rather than a complete
% atom-optics laboratory model.
%
% The model assumes that phase ambiguity has been resolved using the
% high-rate classical IMU. Explicit phase wrapping and fringe-locking will
% be introduced in a later extension.

    %% Reproducibility

    config.random_seed = 7001;

    %% Measurement frequency

    % Quantum measurements are slower than the classical 100 Hz IMU.
    config.update_frequency = 1.0;            % [Hz]

    %% Accelerometer white noise

    config.accelerometer.noise_std_x = ...
        0.005;                                % [m/s^2]

    config.accelerometer.noise_std_y = ...
        0.005;                                % [m/s^2]

    %% Accelerometer initial bias

    config.accelerometer.initial_bias_x = ...
        0.0010;                               % [m/s^2]

    config.accelerometer.initial_bias_y = ...
       -0.0010;                               % [m/s^2]

    %% Accelerometer bias random walk

    % Continuous-time random-walk coefficients.
    config.accelerometer.bias_random_walk_std_x = ...
        5.0e-6;                               % [m/s^2/sqrt(s)]

    config.accelerometer.bias_random_walk_std_y = ...
        5.0e-6;                               % [m/s^2/sqrt(s)]

    %% Gyroscope white noise

    config.gyroscope.noise_std = ...
        deg2rad(0.010);                       % [rad/s]

    %% Gyroscope initial bias

    config.gyroscope.initial_bias = ...
        deg2rad(0.001);                       % [rad/s]

    %% Gyroscope bias random walk

    config.gyroscope.bias_random_walk_std = ...
        deg2rad(5.0e-5);                      % [rad/s/sqrt(s)]

    %% Atom-interferometer parameters

    % Rubidium-87 D2 transition wavelength.
    config.atom.wavelength = ...
        780.24e-9;                            % [m]

    % Counter-propagating Raman effective wave vector:
    %
    %   k_eff approximately 4*pi/lambda
    %
    config.atom.effective_wavevector = ...
        4 * pi / config.atom.wavelength;      % [rad/m]

    % Pulse-separation or interrogation time.
    config.atom.interrogation_time = ...
        0.050;                                % [s]

    % Acceleration phase scale:
    %
    %   phi = k_eff * a * T^2
    %
    config.atom.acceleration_phase_scale_factor = ...
        config.atom.effective_wavevector ...
        * config.atom.interrogation_time^2;

    %% Availability configuration

    % Each row is [start_time, end_time] in seconds.
    % Leave empty for uninterrupted quantum measurements.
    config.outage_windows = [];

    %% Model description

    config.model_name = ...
        'Low-rate unwrapped cold-atom inertial reference';

    config.model_version = ...
        'Phase 7A';
end