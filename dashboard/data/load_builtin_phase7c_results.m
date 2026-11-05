function mc = load_builtin_phase7c_results(csvFile)
%LOAD_BUILTIN_PHASE7C_RESULTS Load the real 100-run paired Phase 7C CSV.

    if nargin < 1 || isempty(csvFile)
        csvFile = find_reference_result_file('phase7c_quantum_monte_carlo_runs.csv');
    end

    T = readtable(csvFile);

    required = { ...
        'run_number', ...
        'classical_position_rmse','quantum_position_rmse', ...
        'classical_velocity_rmse','quantum_velocity_rmse', ...
        'classical_heading_rmse','quantum_heading_rmse', ...
        'classical_maximum_outage_error','quantum_maximum_outage_error', ...
        'classical_final_position_error','quantum_final_position_error'};

    if ~all(ismember(required,T.Properties.VariableNames))
        error('OpenNavLab:Dashboard:Phase7CSchema', ...
            'The Phase 7C paired-run CSV does not match the expected repository schema.');
    end

    mc.run = T.run_number(:);

    mc.maxOutage.classical = T.classical_maximum_outage_error(:);
    mc.maxOutage.quantum = T.quantum_maximum_outage_error(:);

    mc.positionRMSE.classical = T.classical_position_rmse(:);
    mc.positionRMSE.quantum = T.quantum_position_rmse(:);

    mc.finalPosition.classical = T.classical_final_position_error(:);
    mc.finalPosition.quantum = T.quantum_final_position_error(:);

    mc.velocityRMSE.classical = T.classical_velocity_rmse(:);
    mc.velocityRMSE.quantum = T.quantum_velocity_rmse(:);

    mc.headingRMSE.classical = T.classical_heading_rmse(:);
    mc.headingRMSE.quantum = T.quantum_heading_rmse(:);

    mc.meta.source = 'Published OpenNavLab Phase 7C paired Monte Carlo runs';
    mc.meta.sourceFile = csvFile;
    mc.meta.isProductionResult = true;
    mc.meta.numberOfRuns = height(T);
end
