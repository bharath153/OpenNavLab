function data = load_builtin_single_run_results(matFile)
%LOAD_BUILTIN_SINGLE_RUN_RESULTS Load the real OpenNavLab Phase 7B run.
%
% The source MAT contains the truth trajectory, classical EKF,
% quantum-aided EKF, GPS, MEMS IMU, quantum reference, errors and metrics.

    if nargin < 1 || isempty(matFile)
        % Prefer the full repository result when available.
        try
            matFile = find_reference_result_file('phase7b_quantum_aided_navigation.mat');
        catch
            matFile = '';
        end

        % GitHub-ready fallback: compact real-data dashboard snapshot.
        if isempty(matFile) || ~isfile(matFile)
            dashboardRoot = fileparts(fileparts(mfilename('fullpath')));
            snapshotFile = fullfile(dashboardRoot,'data','reference', ...
                'phase7b_dashboard_snapshot.mat');
            if isfile(snapshotFile)
                R = load(snapshotFile,'data');
                data = R.data;
                return;
            end
        end
    end

    if ~isfile(matFile)
        error('OpenNavLab:Dashboard:MissingPhase7B', ...
            'Phase 7B result MAT or compact dashboard snapshot was not found.');
    end

    S = load(matFile);

    required = {'truth','classical_ekf','quantum_aided_ekf','gps','imu', ...
        'quantum','classical_position_error','quantum_position_error', ...
        'classical_velocity_error','quantum_velocity_error', ...
        'classical_heading_error','quantum_heading_error'};
    for k = 1:numel(required)
        if ~isfield(S,required{k})
            error('OpenNavLab:Dashboard:Phase7BSchema', ...
                'Phase 7B MAT is missing variable: %s',required{k});
        end
    end

    t = S.truth.time(:);
    n = numel(t);

    data.time = t;

    data.truth.position = [S.truth.position_x(:) S.truth.position_y(:)];
    data.truth.velocity = [S.truth.velocity_x(:) S.truth.velocity_y(:)];
    data.truth.heading_rad = S.truth.heading(:);

    data.classical.position = [S.classical_ekf.position_x(:) S.classical_ekf.position_y(:)];
    data.classical.velocity = [S.classical_ekf.velocity_x(:) S.classical_ekf.velocity_y(:)];
    data.classical.heading_rad = S.classical_ekf.heading(:);

    data.quantum.position = [S.quantum_aided_ekf.position_x(:) S.quantum_aided_ekf.position_y(:)];
    data.quantum.velocity = [S.quantum_aided_ekf.velocity_x(:) S.quantum_aided_ekf.velocity_y(:)];
    data.quantum.heading_rad = S.quantum_aided_ekf.heading(:);

    data.gps.outageMask = logical(S.gps.outage_mask(:));
    data.gps.scheduledMask = logical(S.gps.scheduled_update_mask(:));
    data.gps.availableMask = logical(S.gps.available_measurement_mask(:));

    if isfield(S.quantum_aided_ekf,'quantum_update_applied')
        data.quantum.updateMask = logical(S.quantum_aided_ekf.quantum_update_applied(:));
    else
        data.quantum.updateMask = logical(S.quantum.available_measurement_mask(:));
    end

    data.errors.classical.position_m = S.classical_position_error(:);
    data.errors.quantum.position_m = S.quantum_position_error(:);
    data.errors.classical.velocity_mps = S.classical_velocity_error(:);
    data.errors.quantum.velocity_mps = S.quantum_velocity_error(:);
    data.errors.classical.heading_deg = S.classical_heading_error(:);
    data.errors.quantum.heading_deg = S.quantum_heading_error(:);

    % The simulated MEMS bias realization is the truth against which both
    % filter bias-state estimates are compared.
    data.bias.true.accel_x_mps2 = S.imu.accelerometer_bias_x(:);
    data.bias.true.accel_y_mps2 = S.imu.accelerometer_bias_y(:);
    data.bias.true.gyro_z_rps = S.imu.gyroscope_bias(:);

    data.bias.classical.accel_x_mps2 = S.classical_ekf.accelerometer_bias_x(:);
    data.bias.classical.accel_y_mps2 = S.classical_ekf.accelerometer_bias_y(:);
    data.bias.classical.gyro_z_rps = S.classical_ekf.gyroscope_bias(:);

    data.bias.quantum.accel_x_mps2 = S.quantum_aided_ekf.accelerometer_bias_x(:);
    data.bias.quantum.accel_y_mps2 = S.quantum_aided_ekf.accelerometer_bias_y(:);
    data.bias.quantum.gyro_z_rps = S.quantum_aided_ekf.gyroscope_bias(:);

    data.nis.gps = S.classical_ekf.normalized_innovation_squared(:);
    data.nis.quantum = S.quantum_aided_ekf.quantum_normalized_innovation_squared(:);
    data.nis.gpsExpected = 2;
    data.nis.quantumExpected = 3;

    data.meta.source = 'OpenNavLab Phase 7B reference run';
    data.meta.sourceFile = matFile;
    data.meta.phase = '7B';
    data.meta.isProductionResult = true;
    data.meta.dt_s = S.truth.dt;
    data.meta.imuRate_Hz = S.imu.sampling_frequency;
    data.meta.gpsRate_Hz = S.gps.update_frequency;
    data.meta.quantumRate_Hz = S.quantum.update_frequency;

    if isfield(S,'phase7b_metrics')
        pm = S.phase7b_metrics;
        data.referenceMetrics.classicalPositionRMSE_m = pm.classical_position_rmse;
        data.referenceMetrics.quantumPositionRMSE_m = pm.quantum_position_rmse;
        data.referenceMetrics.classicalVelocityRMSE_mps = pm.classical_velocity_rmse;
        data.referenceMetrics.quantumVelocityRMSE_mps = pm.quantum_velocity_rmse;
        data.referenceMetrics.classicalHeadingRMSE_deg = pm.classical_heading_rmse;
        data.referenceMetrics.quantumHeadingRMSE_deg = pm.quantum_heading_rmse;
        data.referenceMetrics.classicalMaxOutageError_m = pm.classical_maximum_outage_error;
        data.referenceMetrics.quantumMaxOutageError_m = pm.quantum_maximum_outage_error;
        data.referenceMetrics.maxOutageReduction_pct = pm.maximum_outage_improvement_percent;
    end

    outageIdx = find(data.gps.outageMask);
    if ~isempty(outageIdx)
        % The repository configuration uses half-open outage windows.
        if isfield(S,'gps_config') && isfield(S.gps_config,'outage_windows') ...
                && numel(S.gps_config.outage_windows) >= 2
            w = double(S.gps_config.outage_windows);
            data.meta.outageStart_s = w(1);
            data.meta.outageEnd_s = w(2);
        else
            data.meta.outageStart_s = t(outageIdx(1));
            data.meta.outageEnd_s = t(outageIdx(end)) + S.truth.dt;
        end
    else
        data.meta.outageStart_s = NaN;
        data.meta.outageEnd_s = NaN;
    end

    assert(size(data.truth.position,1)==n);
    assert(size(data.classical.position,1)==n);
    assert(size(data.quantum.position,1)==n);
end
