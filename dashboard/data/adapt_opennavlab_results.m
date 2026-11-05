function data = adapt_opennavlab_results(source)
%ADAPT_OPENNAVLAB_RESULTS Convert common OpenNavLab result layouts to the
%dashboard schema.
%
% This adapter is intentionally tolerant. It supports:
%   1) an already dashboard-compatible structure;
%   2) a MAT-file containing one compatible structure;
%   3) a MAT-file/workspace structure containing recognizable truth,
%      classical, quantum, GPS, error, bias and NIS arrays.
%
% It does not alter estimator mathematics.

    if ischar(source) || isstring(source)
        raw = load(char(source));
    elseif isstruct(source)
        raw = source;
    else
        error('OpenNavLab:Adapter:UnsupportedInput', ...
            'Input must be a MAT-file path or structure.');
    end

    % Already compatible?
    try
        validateBase(raw);
        data = raw;
        data = addOptionalDefaults(data);
        return;
    catch
    end

    % Search top-level structures first.
    names = fieldnames(raw);
    for k = 1:numel(names)
        candidate = raw.(names{k});
        if isstruct(candidate)
            try
                validateBase(candidate);
                data = addOptionalDefaults(candidate);
                return;
            catch
            end
        end
    end

    % Heuristic extraction from common names.
    data = struct();

    data.time = firstVector(raw, {'time','t','time_s','Time'});
    if isempty(data.time)
        error('OpenNavLab:Adapter:MissingTime', ...
            'Could not identify a time vector in the selected MAT-file.');
    end
    data.time = data.time(:);
    n = numel(data.time);

    data.truth.position = firstMatrix2(raw, ...
        {'truth_position','truthPosition','position_truth','pos_truth','p_truth'});
    data.classical.position = firstMatrix2(raw, ...
        {'classical_position','ekf_position','position_ekf','gps_imu_position','pos_classical'});
    data.quantum.position = firstMatrix2(raw, ...
        {'quantum_position','quantum_aided_position','position_quantum','pos_quantum'});

    if isempty(data.truth.position) || isempty(data.classical.position) || isempty(data.quantum.position)
        error('OpenNavLab:Adapter:MissingPosition', ...
            ['Could not identify truth/classical/quantum Nx2 position arrays. ' ...
             'Use the documented dashboard schema or edit adapt_opennavlab_results.m.']);
    end

    data.truth.velocity = firstMatrix2(raw, ...
        {'truth_velocity','truthVelocity','velocity_truth','vel_truth'});
    data.classical.velocity = firstMatrix2(raw, ...
        {'classical_velocity','ekf_velocity','velocity_ekf','vel_classical'});
    data.quantum.velocity = firstMatrix2(raw, ...
        {'quantum_velocity','quantum_aided_velocity','velocity_quantum','vel_quantum'});

    data.truth.heading_rad = firstVector(raw, ...
        {'truth_heading_rad','heading_truth_rad','psi_truth','truth_heading'});
    data.classical.heading_rad = firstVector(raw, ...
        {'classical_heading_rad','ekf_heading_rad','psi_ekf','classical_heading'});
    data.quantum.heading_rad = firstVector(raw, ...
        {'quantum_heading_rad','quantum_aided_heading_rad','psi_quantum','quantum_heading'});

    % Fill missing velocity/heading only when needed for visualization.
    if isempty(data.truth.velocity)
        dt = median(diff(data.time));
        data.truth.velocity = [gradient(data.truth.position(:,1),dt), ...
                               gradient(data.truth.position(:,2),dt)];
    end
    if isempty(data.classical.velocity)
        dt = median(diff(data.time));
        data.classical.velocity = [gradient(data.classical.position(:,1),dt), ...
                                   gradient(data.classical.position(:,2),dt)];
    end
    if isempty(data.quantum.velocity)
        dt = median(diff(data.time));
        data.quantum.velocity = [gradient(data.quantum.position(:,1),dt), ...
                                 gradient(data.quantum.position(:,2),dt)];
    end

    if isempty(data.truth.heading_rad)
        data.truth.heading_rad = atan2(data.truth.velocity(:,2),data.truth.velocity(:,1));
    end
    if isempty(data.classical.heading_rad)
        data.classical.heading_rad = atan2(data.classical.velocity(:,2),data.classical.velocity(:,1));
    end
    if isempty(data.quantum.heading_rad)
        data.quantum.heading_rad = atan2(data.quantum.velocity(:,2),data.quantum.velocity(:,1));
    end

    outageMask = firstLogical(raw, ...
        {'gps_outage_mask','outageMask','outage_mask','gpsOutageMask'});
    if isempty(outageMask)
        gpsAvailable = firstLogical(raw, ...
            {'gps_available_mask','gpsAvailable','available_measurement_mask'});
        if ~isempty(gpsAvailable)
            outageMask = ~gpsAvailable(:);
        else
            outageMask = false(n,1);
        end
    end
    data.gps.outageMask = logical(outageMask(:));

    scheduled = firstLogical(raw, ...
        {'gps_scheduled_mask','gpsScheduled','measurement_update_mask'});
    if isempty(scheduled)
        scheduled = ~isnan(firstVector(raw, {'gps_x','gps_position_x'}));
        if isempty(scheduled), scheduled = false(n,1); end
    end
    data.gps.scheduledMask = logical(scheduled(:));
    data.gps.availableMask = data.gps.scheduledMask & ~data.gps.outageMask;

    qMask = firstLogical(raw, ...
        {'quantum_update_mask','quantumUpdateMask','q_update_mask'});
    if isempty(qMask), qMask = false(n,1); end
    data.quantum.updateMask = logical(qMask(:));

    % Errors from trajectories.
    data.errors.classical.position_m = vecnorm( ...
        data.classical.position-data.truth.position,2,2);
    data.errors.quantum.position_m = vecnorm( ...
        data.quantum.position-data.truth.position,2,2);
    data.errors.classical.velocity_mps = vecnorm( ...
        data.classical.velocity-data.truth.velocity,2,2);
    data.errors.quantum.velocity_mps = vecnorm( ...
        data.quantum.velocity-data.truth.velocity,2,2);

    data.errors.classical.heading_deg = abs(rad2deg(wrapLocal( ...
        data.classical.heading_rad-data.truth.heading_rad)));
    data.errors.quantum.heading_deg = abs(rad2deg(wrapLocal( ...
        data.quantum.heading_rad-data.truth.heading_rad)));

    % Optional NIS.
    data.nis.gps = firstVector(raw, {'gps_nis','nis_gps','GPS_NIS'});
    data.nis.quantum = firstVector(raw, {'quantum_nis','nis_quantum','Q_NIS'});
    data.nis.gpsExpected = 2;
    data.nis.quantumExpected = 3;

    % Optional biases.
    data.bias.true.accel_x_mps2 = firstVector(raw, {'true_bax','bax_true'});
    data.bias.true.accel_y_mps2 = firstVector(raw, {'true_bay','bay_true'});
    data.bias.true.gyro_z_rps = firstVector(raw, {'true_bg','bg_true'});

    data.bias.classical.accel_x_mps2 = firstVector(raw, {'classical_bax','ekf_bax','bax_ekf'});
    data.bias.classical.accel_y_mps2 = firstVector(raw, {'classical_bay','ekf_bay','bay_ekf'});
    data.bias.classical.gyro_z_rps = firstVector(raw, {'classical_bg','ekf_bg','bg_ekf'});

    data.bias.quantum.accel_x_mps2 = firstVector(raw, {'quantum_bax','q_bax'});
    data.bias.quantum.accel_y_mps2 = firstVector(raw, {'quantum_bay','q_bay'});
    data.bias.quantum.gyro_z_rps = firstVector(raw, {'quantum_bg','q_bg'});

    dt = median(diff(data.time));
    data.meta.source = 'Adapted OpenNavLab MAT results';
    data.meta.dt_s = dt;
    data.meta.imuRate_Hz = 1/dt;
    data.meta.gpsRate_Hz = estimateRate(data.time,data.gps.scheduledMask);
    data.meta.quantumRate_Hz = estimateRate(data.time,data.quantum.updateMask);

    idx = find(data.gps.outageMask);
    if isempty(idx)
        data.meta.outageStart_s = NaN;
        data.meta.outageEnd_s = NaN;
    else
        data.meta.outageStart_s = data.time(idx(1));
        data.meta.outageEnd_s = data.time(idx(end));
    end

    data = addOptionalDefaults(data);
    validateBase(data);
end

function validateBase(data)
    req = {'time','truth','classical','quantum','gps','errors','meta'};
    for k = 1:numel(req)
        assert(isfield(data,req{k}), 'Missing field %s',req{k});
    end
    n = numel(data.time);
    assert(size(data.truth.position,1)==n);
    assert(size(data.classical.position,1)==n);
    assert(size(data.quantum.position,1)==n);
end

function data = addOptionalDefaults(data)
    n = numel(data.time);

    if ~isfield(data,'nis')
        data.nis = struct();
    end
    if ~isfield(data.nis,'gps'), data.nis.gps = nan(n,1); end
    if ~isfield(data.nis,'quantum'), data.nis.quantum = nan(n,1); end
    if ~isfield(data.nis,'gpsExpected'), data.nis.gpsExpected = 2; end
    if ~isfield(data.nis,'quantumExpected'), data.nis.quantumExpected = 3; end

    if ~isfield(data,'bias')
        data.bias = struct();
    end
    groups = {'true','classical','quantum'};
    names = {'accel_x_mps2','accel_y_mps2','gyro_z_rps'};
    for g = 1:numel(groups)
        if ~isfield(data.bias,groups{g})
            data.bias.(groups{g}) = struct();
        end
        for j = 1:numel(names)
            if ~isfield(data.bias.(groups{g}),names{j}) || ...
                    isempty(data.bias.(groups{g}).(names{j}))
                data.bias.(groups{g}).(names{j}) = nan(n,1);
            end
        end
    end
end

function v = firstVector(s,names)
    v = [];
    for i = 1:numel(names)
        if isfield(s,names{i})
            x = s.(names{i});
            if isnumeric(x) || islogical(x)
                if isvector(x)
                    v = x(:);
                    return;
                end
            end
        end
    end
end

function m = firstMatrix2(s,names)
    m = [];
    for i = 1:numel(names)
        if isfield(s,names{i})
            x = s.(names{i});
            if isnumeric(x) && ismatrix(x) && size(x,2)>=2
                m = x(:,1:2);
                return;
            end
        end
    end
end

function v = firstLogical(s,names)
    v = [];
    for i = 1:numel(names)
        if isfield(s,names{i})
            x = s.(names{i});
            if isvector(x)
                v = logical(x(:));
                return;
            end
        end
    end
end

function r = estimateRate(t,mask)
    idx = find(mask);
    if numel(idx) < 2
        r = 0;
    else
        d = diff(t(idx));
        r = 1/median(d);
    end
end

function a = wrapLocal(a)
    a = mod(a+pi,2*pi)-pi;
end
