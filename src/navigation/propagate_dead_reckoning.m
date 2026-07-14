function navigation = propagate_dead_reckoning( ...
    time, ...
    acceleration_body_x, ...
    acceleration_body_y, ...
    yaw_rate, ...
    initial_state)
%PROPAGATE_DEAD_RECKONING Perform 2D inertial dead reckoning.
%
% Inputs:
%   time                 - Time vector [s]
%   acceleration_body_x  - Longitudinal body acceleration [m/s^2]
%   acceleration_body_y  - Lateral body acceleration [m/s^2]
%   yaw_rate             - Body yaw rate [rad/s]
%   initial_state        - Structure containing:
%                           position_x [m]
%                           position_y [m]
%                           velocity_x [m/s]
%                           velocity_y [m/s]
%                           heading    [rad]
%
% Output:
%   navigation - Estimated position, velocity, acceleration and heading.
%
% Mechanisation equations:
%
%   psi(k+1) = psi(k) + omega(k) * dt
%
%   a_navigation = R_body_to_navigation * a_body
%
%   v(k+1) = v(k) + a_navigation(k) * dt
%
%   p(k+1) = p(k) + v(k) * dt
%                    + 0.5 * a_navigation(k) * dt^2

    %% Convert inputs to column vectors

    time = time(:);
    acceleration_body_x = acceleration_body_x(:);
    acceleration_body_y = acceleration_body_y(:);
    yaw_rate = yaw_rate(:);

    number_of_samples = numel(time);

    %% Input validation

    if number_of_samples < 2
        error('At least two samples are required.');
    end

    if numel(acceleration_body_x) ~= number_of_samples
        error('Acceleration X sample count does not match time.');
    end

    if numel(acceleration_body_y) ~= number_of_samples
        error('Acceleration Y sample count does not match time.');
    end

    if numel(yaw_rate) ~= number_of_samples
        error('Yaw-rate sample count does not match time.');
    end

    required_initial_fields = { ...
        'position_x', ...
        'position_y', ...
        'velocity_x', ...
        'velocity_y', ...
        'heading'};

    for field_index = 1:numel(required_initial_fields)

        current_field = required_initial_fields{field_index};

        if ~isfield(initial_state, current_field)
            error( ...
                'Initial state does not contain the field "%s".', ...
                current_field);
        end
    end

    time_steps = diff(time);
    dt = mean(time_steps);

    time_step_tolerance = max(1e-12, 1e-9 * dt);

    if any(abs(time_steps - dt) > time_step_tolerance)
        error('The time vector must have a uniform sampling interval.');
    end

    if dt <= 0
        error('The time vector must be strictly increasing.');
    end

    %% Preallocate outputs

    position_x = zeros(number_of_samples, 1);
    position_y = zeros(number_of_samples, 1);

    velocity_x = zeros(number_of_samples, 1);
    velocity_y = zeros(number_of_samples, 1);

    heading = zeros(number_of_samples, 1);

    acceleration_navigation_x = zeros(number_of_samples, 1);
    acceleration_navigation_y = zeros(number_of_samples, 1);

    %% Set initial state

    position_x(1) = initial_state.position_x;
    position_y(1) = initial_state.position_y;

    velocity_x(1) = initial_state.velocity_x;
    velocity_y(1) = initial_state.velocity_y;

    heading(1) = initial_state.heading;

    %% Inertial navigation propagation

    for k = 1:number_of_samples - 1

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

        % Position propagation
        position_x(k + 1) = ...
            position_x(k) ...
            + velocity_x(k) * dt ...
            + 0.5 * acceleration_navigation_x(k) * dt^2;

        position_y(k + 1) = ...
            position_y(k) ...
            + velocity_y(k) * dt ...
            + 0.5 * acceleration_navigation_y(k) * dt^2;

        % Velocity propagation
        velocity_x(k + 1) = ...
            velocity_x(k) ...
            + acceleration_navigation_x(k) * dt;

        velocity_y(k + 1) = ...
            velocity_y(k) ...
            + acceleration_navigation_y(k) * dt;

        % Heading propagation
        heading_unwrapped = ...
            heading(k) + yaw_rate(k) * dt;

        heading(k + 1) = atan2( ...
            sin(heading_unwrapped), ...
            cos(heading_unwrapped));
    end

    %% Calculate final-sample acceleration

    rotation_body_to_navigation = ...
        [cos(heading(end)), -sin(heading(end)); ...
         sin(heading(end)),  cos(heading(end))];

    acceleration_navigation = ...
        rotation_body_to_navigation * ...
        [acceleration_body_x(end); ...
         acceleration_body_y(end)];

    acceleration_navigation_x(end) = ...
        acceleration_navigation(1);

    acceleration_navigation_y(end) = ...
        acceleration_navigation(2);

    %% Store results

    navigation.time = time;
    navigation.dt = dt;

    navigation.position_x = position_x;
    navigation.position_y = position_y;

    navigation.velocity_x = velocity_x;
    navigation.velocity_y = velocity_y;

    navigation.speed = hypot(velocity_x, velocity_y);

    navigation.heading = heading;

    navigation.acceleration_navigation_x = ...
        acceleration_navigation_x;

    navigation.acceleration_navigation_y = ...
        acceleration_navigation_y;

    navigation.acceleration_body_x = ...
        acceleration_body_x;

    navigation.acceleration_body_y = ...
        acceleration_body_y;

    navigation.yaw_rate = yaw_rate;
end