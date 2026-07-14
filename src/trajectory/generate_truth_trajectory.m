function truth = generate_truth_trajectory(dt, simulation_time)
%GENERATE_TRUTH_TRAJECTORY Generate a 2D ground-truth navigation trajectory.
%
% Inputs:
%   dt              - Simulation time step [s]
%   simulation_time - Total simulation duration [s]
%
% Output:
%   truth - Structure containing the complete ground-truth trajectory.
%
% Coordinate convention:
%   Navigation frame:
%       X-axis = global horizontal X direction
%       Y-axis = global horizontal Y direction
%
%   Body frame:
%       X-axis = forward direction
%       Y-axis = left direction
%
%   Heading convention:
%       psi = 0 rad means the vehicle points along global +X
%       positive yaw rate produces a counter-clockwise left turn
%
% Phase 1 includes:
%   - Position
%   - Velocity
%   - Speed
%   - Heading
%   - Yaw rate
%   - Body-frame acceleration
%   - Navigation-frame acceleration

    %% Input validation

    validateattributes( ...
        dt, ...
        {'numeric'}, ...
        {'scalar', 'real', 'finite', 'positive'}, ...
        mfilename, ...
        'dt');

    validateattributes( ...
        simulation_time, ...
        {'numeric'}, ...
        {'scalar', 'real', 'finite', 'positive'}, ...
        mfilename, ...
        'simulation_time');

    if simulation_time < 115
        error( ...
            'Simulation time must be at least 115 seconds ' + ...
            'for the complete predefined trajectory.');
    end

    %% Time vector

    time = (0:dt:simulation_time)';
    number_of_samples = numel(time);

    %% Preallocate ground-truth variables

    position_x = zeros(number_of_samples, 1);
    position_y = zeros(number_of_samples, 1);

    velocity_x = zeros(number_of_samples, 1);
    velocity_y = zeros(number_of_samples, 1);

    acceleration_navigation_x = zeros(number_of_samples, 1);
    acceleration_navigation_y = zeros(number_of_samples, 1);

    acceleration_body_x = zeros(number_of_samples, 1);
    acceleration_body_y = zeros(number_of_samples, 1);

    speed = zeros(number_of_samples, 1);
    heading = zeros(number_of_samples, 1);

    longitudinal_acceleration_command = ...
        zeros(number_of_samples, 1);

    yaw_rate = zeros(number_of_samples, 1);

    %% Define the trajectory phases

    % Phase 1: 0-10 s
    % Accelerate from 0 m/s to 10 m/s.
    longitudinal_acceleration_command( ...
        time >= 0 & time < 10) = 1.0;

    % Phase 2: 10-30 s
    % Constant-speed straight motion.
    longitudinal_acceleration_command( ...
        time >= 10 & time < 30) = 0;

    yaw_rate(time >= 10 & time < 30) = 0;

    % Phase 3: 30-45 s
    % Left turn at 4 degrees per second.
    yaw_rate(time >= 30 & time < 45) = deg2rad(4);

    % Phase 4: 45-65 s
    % Constant-speed straight motion.
    yaw_rate(time >= 45 & time < 65) = 0;

    % Phase 5: 65-80 s
    % Right turn at 5 degrees per second.
    yaw_rate(time >= 65 & time < 80) = deg2rad(-5);

    % Phase 6: 80-100 s
    % Constant-speed straight motion.
    yaw_rate(time >= 80 & time < 100) = 0;

    % Phase 7: 100-115 s
    % Decelerate from 10 m/s to 0 m/s in 15 seconds.
    braking_acceleration = -10 / 15;

    longitudinal_acceleration_command( ...
        time >= 100 & time < 115) = braking_acceleration;

    % Phase 8: 115 s onward
    % Vehicle remains stationary.
    longitudinal_acceleration_command(time >= 115) = 0;
    yaw_rate(time >= 115) = 0;

    %% Propagate the motion model

    for k = 1:number_of_samples - 1

        % Body-frame longitudinal acceleration.
        acceleration_body_x(k) = ...
            longitudinal_acceleration_command(k);

        % Body-frame lateral acceleration caused by turning.
        %
        % a_lateral = speed * yaw_rate
        acceleration_body_y(k) = ...
            speed(k) * yaw_rate(k);

        % Rotation matrix from body frame to navigation frame.
        rotation_body_to_navigation = ...
            [cos(heading(k)), -sin(heading(k)); ...
             sin(heading(k)),  cos(heading(k))];

        acceleration_body = ...
            [acceleration_body_x(k); ...
             acceleration_body_y(k)];

        acceleration_navigation = ...
            rotation_body_to_navigation * acceleration_body;

        acceleration_navigation_x(k) = ...
            acceleration_navigation(1);

        acceleration_navigation_y(k) = ...
            acceleration_navigation(2);

        % Calculate navigation-frame velocity components.
        velocity_x(k) = ...
            speed(k) * cos(heading(k));

        velocity_y(k) = ...
            speed(k) * sin(heading(k));

        % Propagate position using constant acceleration over one step.
        position_x(k + 1) = ...
            position_x(k) ...
            + velocity_x(k) * dt ...
            + 0.5 * acceleration_navigation_x(k) * dt^2;

        position_y(k + 1) = ...
            position_y(k) ...
            + velocity_y(k) * dt ...
            + 0.5 * acceleration_navigation_y(k) * dt^2;

        % Propagate scalar speed.
        speed(k + 1) = ...
            speed(k) ...
            + longitudinal_acceleration_command(k) * dt;

        % Prevent numerical errors from producing negative speed.
        speed(k + 1) = max(0, speed(k + 1));

        % Propagate heading.
        heading(k + 1) = ...
            heading(k) + yaw_rate(k) * dt;

        % Keep heading within [-pi, pi].
        heading(k + 1) = atan2( ...
            sin(heading(k + 1)), ...
            cos(heading(k + 1)));
    end

    %% Calculate final-sample quantities

    final_index = number_of_samples;

    acceleration_body_x(final_index) = ...
        longitudinal_acceleration_command(final_index);

    acceleration_body_y(final_index) = ...
        speed(final_index) * yaw_rate(final_index);

    rotation_body_to_navigation = ...
        [cos(heading(final_index)), -sin(heading(final_index)); ...
         sin(heading(final_index)),  cos(heading(final_index))];

    acceleration_navigation = ...
        rotation_body_to_navigation * ...
        [acceleration_body_x(final_index); ...
         acceleration_body_y(final_index)];

    acceleration_navigation_x(final_index) = ...
        acceleration_navigation(1);

    acceleration_navigation_y(final_index) = ...
        acceleration_navigation(2);

    velocity_x(final_index) = ...
        speed(final_index) * cos(heading(final_index));

    velocity_y(final_index) = ...
        speed(final_index) * sin(heading(final_index));

    %% Store outputs

    truth.time = time;
    truth.dt = dt;
    truth.simulation_time = simulation_time;

    truth.position_x = position_x;
    truth.position_y = position_y;

    truth.velocity_x = velocity_x;
    truth.velocity_y = velocity_y;

    truth.acceleration_navigation_x = ...
        acceleration_navigation_x;

    truth.acceleration_navigation_y = ...
        acceleration_navigation_y;

    truth.acceleration_body_x = ...
        acceleration_body_x;

    truth.acceleration_body_y = ...
        acceleration_body_y;

    truth.speed = speed;
    truth.heading = heading;
    truth.yaw_rate = yaw_rate;

    truth.longitudinal_acceleration_command = ...
        longitudinal_acceleration_command;
end