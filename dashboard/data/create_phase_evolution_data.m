function evolution = create_phase_evolution_data()
%CREATE_PHASE_EVOLUTION_DATA Load cross-phase metrics from saved artifacts.
%
% Full repository MAT files are preferred when present. GitHub-ready clones
% can use the compact phase_evolution_metrics.csv fallback.

    useFull = true;
    try
        phase5File = find_reference_result_file('phase5_gps_imu_ekf.mat');
        phase7bFile = find_reference_result_file('phase7b_quantum_aided_navigation.mat');
    catch
        useFull = false;
    end

    if useFull && isfile(phase5File) && isfile(phase7bFile)
        P5 = load(phase5File,'phase5_metrics');
        P7 = load(phase7bFile,'phase7b_metrics');

        p5 = P5.phase5_metrics;
        p7 = P7.phase7b_metrics;

        phaseNames = {'Phase 3 MEMS DR','Phase 5 Classical EKF','Phase 7B Quantum EKF'};
        positionRMSE = [p5.dead_reckoning_position_rmse, p5.ekf_position_rmse, p7.quantum_position_rmse];
        velocityRMSE = [p5.dead_reckoning_velocity_rmse, p5.ekf_velocity_rmse, p7.quantum_velocity_rmse];
        headingRMSE = [p5.dead_reckoning_heading_rmse, p5.ekf_heading_rmse, p7.quantum_heading_rmse];
        maxOutage = [NaN, p5.maximum_outage_position_error, p7.quantum_maximum_outage_error];

        classicalPosition = p7.classical_position_rmse;
        classicalOutage = p7.classical_maximum_outage_error;
    else
        csvFile = find_reference_result_file('phase_evolution_metrics.csv');
        T = readtable(csvFile,'TextType','string');

        phaseNames = cellstr(T.Phase).';
        positionRMSE = T.PositionRMSE_m.';
        velocityRMSE = T.VelocityRMSE_mps.';
        headingRMSE = T.HeadingRMSE_deg.';
        maxOutage = T.MaxOutageError_m.';

        classicalPosition = positionRMSE(2);
        classicalOutage = maxOutage(2);
    end

    s = load_builtin_phase7d_results();

    evolution.singleRun.phaseNames = phaseNames;
    evolution.singleRun.positionRMSE_m = positionRMSE;
    evolution.singleRun.velocityRMSE_mps = velocityRMSE;
    evolution.singleRun.headingRMSE_deg = headingRMSE;
    evolution.singleRun.maxOutageError_m = maxOutage;

    evolution.reductions.drToClassicalPosition_pct = ...
        100*(positionRMSE(1)-positionRMSE(2))/positionRMSE(1);
    evolution.reductions.classicalToQuantumPosition_pct = ...
        100*(classicalPosition-positionRMSE(3))/classicalPosition;
    evolution.reductions.singleRunMaxOutage_pct = ...
        100*(classicalOutage-maxOutage(3))/classicalOutage;

    [~,oi] = min(abs(s.outage_s-40));
    [~,ri] = min(abs(s.rates_Hz-2));

    evolution.phase7d.outage_s = s.outage_s(oi);
    evolution.phase7d.quantumRate_Hz = s.rates_Hz(ri);
    evolution.phase7d.classicalMeanMax_m = s.classicalMeanMax_m(oi);
    evolution.phase7d.quantumMeanMax_m = s.quantumMeanMax_m(ri,oi);
    evolution.phase7d.meanReduction_pct = s.meanReduction_pct(ri,oi);
    evolution.phase7d.classicalP95_m = s.classicalP95_m(oi);
    evolution.phase7d.quantumP95_m = s.quantumP95_m(ri,oi);
    evolution.phase7d.p95Reduction_pct = s.p95Reduction_pct(ri,oi);
    evolution.phase7d.runsImproved_pct = s.runsImproved_pct(ri,oi);

    evolution.meta.source = 'OpenNavLab saved Phase 3/5/7B/7D metrics';
    evolution.meta.isProductionResult = true;
    evolution.meta.note = [ ...
        'Phase 3/5/7B values are reference-run navigation metrics. ' ...
        'Phase 7D values are 100-run ensemble statistics and are displayed separately.'];
end
