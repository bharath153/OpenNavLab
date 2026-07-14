function config = create_gps_config()
%CREATE_GPS_CONFIG Create the configuration for the virtual GPS.
%
% The GPS model provides two-dimensional position measurements:
%
%   position_x_measured = position_x_true + noise_x
%   position_y_measured = position_y_true + noise_y
%
% GPS measurements are generated only at the configured update rate.
% Measurements are unavailable during the specified outage windows.

    %% Random-number configuration

    config.random_seed = 84;

    %% GPS sampling configuration

    % GPS update frequency [Hz]
    config.update_frequency = 1.0;

    %% GPS position-noise configuration

    % Position measurement standard deviations [m]
    config.position_noise_std_x = 2.5;
    config.position_noise_std_y = 2.5;

    %% GPS outage configuration

    % Each row defines:
    %
    % [outage_start_time, outage_end_time]
    %
    % The start time is included.
    % The end time is excluded.
    %
    % Therefore, [50, 70] means:
    %
    %   GPS unavailable for 50 <= time < 70 seconds.

    config.outage_windows = ...
        [50, 70];
end