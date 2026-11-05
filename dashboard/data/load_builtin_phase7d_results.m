function sensitivity = load_builtin_phase7d_results(csvFile)
%LOAD_BUILTIN_PHASE7D_RESULTS Load the real OpenNavLab Phase 7D summary CSV.

    if nargin < 1 || isempty(csvFile)
        csvFile = find_reference_result_file('phase7d_quantum_sensitivity_summary.csv');
    end

    T = readtable(csvFile);

    required = { ...
        'OutageDurationSeconds','QuantumFrequencyHz', ...
        'ClassicalMeanReferenceOrMaximumErrorM', ...
        'ClassicalP95ReferenceOrMaximumErrorM', ...
        'QuantumMeanReferenceOrMaximumErrorM', ...
        'QuantumP95ReferenceOrMaximumErrorM', ...
        'RunsImprovedPercent', ...
        'PositionRMSEReductionPercent', ...
        'VelocityRMSEReductionPercent', ...
        'HeadingRMSEReductionPercent', ...
        'QuantumMeanNIS'};

    if ~all(ismember(required,T.Properties.VariableNames))
        error('OpenNavLab:Dashboard:Phase7DSchema', ...
            'The Phase 7D summary CSV does not match the expected repository schema.');
    end

    outages = unique(T.OutageDurationSeconds,'sorted').';
    rates = unique(T.QuantumFrequencyHz,'sorted').';

    nr = numel(rates);
    no = numel(outages);

    sensitivity.outage_s = outages;
    sensitivity.rates_Hz = rates;
    sensitivity.classicalMeanMax_m = nan(1,no);
    sensitivity.classicalP95_m = nan(1,no);

    sensitivity.quantumMeanMax_m = nan(nr,no);
    sensitivity.meanReduction_pct = nan(nr,no);
    sensitivity.quantumP95_m = nan(nr,no);
    sensitivity.p95Reduction_pct = nan(nr,no);
    sensitivity.runsImproved_pct = nan(nr,no);
    sensitivity.positionRMSEreduction_pct = nan(nr,no);
    sensitivity.velocityRMSEreduction_pct = nan(nr,no);
    sensitivity.headingRMSEreduction_pct = nan(nr,no);
    sensitivity.quantumNIS = nan(nr,no);

    % Preserve the paired mean-relative statistic separately because the
    % dashboard headline uses reduction between ensemble means.
    sensitivity.meanPairedRelativeReduction_pct = nan(nr,no);

    for i = 1:height(T)
        oi = find(outages == T.OutageDurationSeconds(i),1);
        ri = find(rates == T.QuantumFrequencyHz(i),1);

        cMean = T.ClassicalMeanReferenceOrMaximumErrorM(i);
        qMean = T.QuantumMeanReferenceOrMaximumErrorM(i);
        cP95 = T.ClassicalP95ReferenceOrMaximumErrorM(i);
        qP95 = T.QuantumP95ReferenceOrMaximumErrorM(i);

        sensitivity.classicalMeanMax_m(oi) = cMean;
        sensitivity.quantumMeanMax_m(ri,oi) = qMean;
        sensitivity.meanReduction_pct(ri,oi) = 100*(cMean-qMean)/cMean;

        sensitivity.classicalP95_m(oi) = cP95;
        sensitivity.quantumP95_m(ri,oi) = qP95;
        sensitivity.p95Reduction_pct(ri,oi) = 100*(cP95-qP95)/cP95;

        sensitivity.runsImproved_pct(ri,oi) = T.RunsImprovedPercent(i);
        sensitivity.positionRMSEreduction_pct(ri,oi) = T.PositionRMSEReductionPercent(i);
        sensitivity.velocityRMSEreduction_pct(ri,oi) = T.VelocityRMSEReductionPercent(i);
        sensitivity.headingRMSEreduction_pct(ri,oi) = T.HeadingRMSEReductionPercent(i);
        sensitivity.quantumNIS(ri,oi) = T.QuantumMeanNIS(i);

        if ismember('MeanRelativeReductionPercent',T.Properties.VariableNames)
            sensitivity.meanPairedRelativeReduction_pct(ri,oi) = ...
                T.MeanRelativeReductionPercent(i);
        end
    end

    sensitivity.meta.source = 'Published OpenNavLab Phase 7D sensitivity summary';
    sensitivity.meta.sourceFile = csvFile;
    sensitivity.meta.isProductionResult = true;
    sensitivity.meta.numberOfOperatingPoints = height(T);
end
