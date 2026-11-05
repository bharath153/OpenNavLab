function research = adapt_research_results(fileName)
%ADAPT_RESEARCH_RESULTS Load OpenNavLab Monte Carlo / sensitivity results.
%
% Supported:
%   MAT: a variable or structure named research containing .mc and/or .sensitivity
%   CSV Monte Carlo schema: run plus paired classical/quantum metric columns
%   CSV Sensitivity schema: one row per outage/rate operating point

    [~,~,ext]=fileparts(fileName);
    switch lower(ext)
        case '.mat'
            raw=load(fileName);
            if isfield(raw,'research') && isstruct(raw.research)
                research=raw.research;
                return;
            end
            names=fieldnames(raw);
            for k=1:numel(names)
                x=raw.(names{k});
                if isstruct(x) && (isfield(x,'mc') || isfield(x,'sensitivity'))
                    research=x; return;
                end
            end
            if isfield(raw,'mc') || isfield(raw,'sensitivity')
                research=struct();
                if isfield(raw,'mc'), research.mc=raw.mc; end
                if isfield(raw,'sensitivity'), research.sensitivity=raw.sensitivity; end
                return;
            end
            error('OpenNavLab:ResearchAdapter:MATSchema','No research.mc or research.sensitivity structure found.');

        case '.csv'
            T=readtable(fileName);
            names=T.Properties.VariableNames;
            if all(ismember({'run_number','classical_maximum_outage_error', ...
                    'quantum_maximum_outage_error','classical_position_rmse', ...
                    'quantum_position_rmse'},names))
                research=struct();
                research.mc=repositoryPhase7CTableToMC(T);
                return;
            end
            if all(ismember({'run','classicalMaxOutage_m','quantumMaxOutage_m'},names))
                research=struct(); research.mc=tableToMC(T); return;
            end
            if all(ismember({'outage_s','rate_Hz','classicalMeanMax_m','quantumMeanMax_m'},names))
                research=struct(); research.sensitivity=tableToSensitivity(T); return;
            end
            if all(ismember({'OutageDurationSeconds','QuantumFrequencyHz', ...
                    'ClassicalMeanReferenceOrMaximumErrorM', ...
                    'QuantumMeanReferenceOrMaximumErrorM'},names))
                research=struct();
                research.sensitivity=repositoryPhase7DTableToSensitivity(T);
                return;
            end
            if all(ismember({'OutageDurationSeconds','QuantumFrequencyHz', ...
                    'ClassicalMeanMaximumErrorM','QuantumMeanMaximumErrorM'},names))
                research=struct();
                research.sensitivity=publishedPhase7DTableToSensitivity(T);
                return;
            end
            error('OpenNavLab:ResearchAdapter:CSVSchema', ...
                'CSV schema not recognized. See README v0.6 research-data schemas.');
        otherwise
            error('OpenNavLab:ResearchAdapter:Extension','Use a MAT or CSV file.');
    end
end

function mc=tableToMC(T)
    required={'run','classicalMaxOutage_m','quantumMaxOutage_m', ...
        'classicalPositionRMSE_m','quantumPositionRMSE_m', ...
        'classicalFinalPosition_m','quantumFinalPosition_m', ...
        'classicalVelocityRMSE_mps','quantumVelocityRMSE_mps', ...
        'classicalHeadingRMSE_deg','quantumHeadingRMSE_deg'};
    assert(all(ismember(required,T.Properties.VariableNames)), ...
        'Monte Carlo CSV is missing one or more required metric columns.');
    mc.run=T.run;
    mc.maxOutage.classical=T.classicalMaxOutage_m; mc.maxOutage.quantum=T.quantumMaxOutage_m;
    mc.positionRMSE.classical=T.classicalPositionRMSE_m; mc.positionRMSE.quantum=T.quantumPositionRMSE_m;
    mc.finalPosition.classical=T.classicalFinalPosition_m; mc.finalPosition.quantum=T.quantumFinalPosition_m;
    mc.velocityRMSE.classical=T.classicalVelocityRMSE_mps; mc.velocityRMSE.quantum=T.quantumVelocityRMSE_mps;
    mc.headingRMSE.classical=T.classicalHeadingRMSE_deg; mc.headingRMSE.quantum=T.quantumHeadingRMSE_deg;
end

function s=tableToSensitivity(T)
    req={'outage_s','rate_Hz','classicalMeanMax_m','quantumMeanMax_m','classicalP95_m','quantumP95_m', ...
        'runsImproved_pct','positionRMSEreduction_pct','velocityRMSEreduction_pct', ...
        'headingRMSEreduction_pct','quantumNIS'};
    assert(all(ismember(req,T.Properties.VariableNames)), ...
        'Sensitivity CSV is missing one or more required columns.');
    outages=unique(T.outage_s,'sorted').'; rates=unique(T.rate_Hz,'sorted').';
    s.outage_s=outages; s.rates_Hz=rates;
    nr=numel(rates); no=numel(outages);
    s.classicalMeanMax_m=nan(1,no); s.classicalP95_m=nan(1,no);
    fields={'quantumMeanMax_m','quantumP95_m','runsImproved_pct','positionRMSEreduction_pct', ...
        'velocityRMSEreduction_pct','headingRMSEreduction_pct','quantumNIS'};
    for f=1:numel(fields), s.(fields{f})=nan(nr,no); end
    for i=1:height(T)
        oi=find(outages==T.outage_s(i),1); ri=find(rates==T.rate_Hz(i),1);
        s.classicalMeanMax_m(oi)=T.classicalMeanMax_m(i); s.classicalP95_m(oi)=T.classicalP95_m(i);
        for f=1:numel(fields), s.(fields{f})(ri,oi)=T.(fields{f})(i); end
    end
    s.meanReduction_pct=100*(repmat(s.classicalMeanMax_m,nr,1)-s.quantumMeanMax_m)./repmat(s.classicalMeanMax_m,nr,1);
    s.p95Reduction_pct=100*(repmat(s.classicalP95_m,nr,1)-s.quantumP95_m)./repmat(s.classicalP95_m,nr,1);
end


function s=publishedPhase7DTableToSensitivity(T)
    outages=unique(T.OutageDurationSeconds,'sorted').';
    rates=unique(T.QuantumFrequencyHz,'sorted').';
    nr=numel(rates); no=numel(outages);

    s.outage_s=outages;
    s.rates_Hz=rates;
    s.classicalMeanMax_m=nan(1,no);
    s.classicalP95_m=nan(1,no);

    fields={'quantumMeanMax_m','meanReduction_pct','quantumP95_m', ...
        'p95Reduction_pct','runsImproved_pct','positionRMSEreduction_pct', ...
        'velocityRMSEreduction_pct','headingRMSEreduction_pct','quantumNIS'};
    for f=1:numel(fields)
        s.(fields{f})=nan(nr,no);
    end

    for i=1:height(T)
        oi=find(outages==T.OutageDurationSeconds(i),1);
        ri=find(rates==T.QuantumFrequencyHz(i),1);

        s.classicalMeanMax_m(oi)=T.ClassicalMeanMaximumErrorM(i);
        s.quantumMeanMax_m(ri,oi)=T.QuantumMeanMaximumErrorM(i);
        s.meanReduction_pct(ri,oi)=T.ReductionInEnsembleMeanPercent(i);

        s.classicalP95_m(oi)=T.ClassicalP95MaximumErrorM(i);
        s.quantumP95_m(ri,oi)=T.QuantumP95MaximumErrorM(i);
        s.p95Reduction_pct(ri,oi)=T.P95ErrorReductionPercent(i);

        s.runsImproved_pct(ri,oi)=T.RunsImprovedPercent(i);
        s.positionRMSEreduction_pct(ri,oi)=T.PositionRMSEReductionPercent(i);
        s.velocityRMSEreduction_pct(ri,oi)=T.VelocityRMSEReductionPercent(i);
        s.headingRMSEreduction_pct(ri,oi)=T.HeadingRMSEReductionPercent(i);
        s.quantumNIS(ri,oi)=T.QuantumMeanNIS(i);
    end

    s.meta.source='Published OpenNavLab Phase 7D key results';
    s.meta.isProductionResult=true;
end


function mc=repositoryPhase7CTableToMC(T)
    mc.run=T.run_number(:);
    mc.maxOutage.classical=T.classical_maximum_outage_error(:);
    mc.maxOutage.quantum=T.quantum_maximum_outage_error(:);
    mc.positionRMSE.classical=T.classical_position_rmse(:);
    mc.positionRMSE.quantum=T.quantum_position_rmse(:);
    mc.finalPosition.classical=T.classical_final_position_error(:);
    mc.finalPosition.quantum=T.quantum_final_position_error(:);
    mc.velocityRMSE.classical=T.classical_velocity_rmse(:);
    mc.velocityRMSE.quantum=T.quantum_velocity_rmse(:);
    mc.headingRMSE.classical=T.classical_heading_rmse(:);
    mc.headingRMSE.quantum=T.quantum_heading_rmse(:);
    mc.meta.source='Published OpenNavLab Phase 7C paired Monte Carlo runs';
    mc.meta.isProductionResult=true;
end

function s=repositoryPhase7DTableToSensitivity(T)
    outages=unique(T.OutageDurationSeconds,'sorted').';
    rates=unique(T.QuantumFrequencyHz,'sorted').';
    nr=numel(rates); no=numel(outages);

    s.outage_s=outages; s.rates_Hz=rates;
    s.classicalMeanMax_m=nan(1,no); s.classicalP95_m=nan(1,no);

    fields={'quantumMeanMax_m','meanReduction_pct','quantumP95_m','p95Reduction_pct', ...
        'runsImproved_pct','positionRMSEreduction_pct','velocityRMSEreduction_pct', ...
        'headingRMSEreduction_pct','quantumNIS','meanPairedRelativeReduction_pct'};
    for f=1:numel(fields), s.(fields{f})=nan(nr,no); end

    for i=1:height(T)
        oi=find(outages==T.OutageDurationSeconds(i),1);
        ri=find(rates==T.QuantumFrequencyHz(i),1);

        cMean=T.ClassicalMeanReferenceOrMaximumErrorM(i);
        qMean=T.QuantumMeanReferenceOrMaximumErrorM(i);
        cP95=T.ClassicalP95ReferenceOrMaximumErrorM(i);
        qP95=T.QuantumP95ReferenceOrMaximumErrorM(i);

        s.classicalMeanMax_m(oi)=cMean;
        s.quantumMeanMax_m(ri,oi)=qMean;
        s.meanReduction_pct(ri,oi)=100*(cMean-qMean)/cMean;
        s.classicalP95_m(oi)=cP95;
        s.quantumP95_m(ri,oi)=qP95;
        s.p95Reduction_pct(ri,oi)=100*(cP95-qP95)/cP95;
        s.runsImproved_pct(ri,oi)=T.RunsImprovedPercent(i);
        s.positionRMSEreduction_pct(ri,oi)=T.PositionRMSEReductionPercent(i);
        s.velocityRMSEreduction_pct(ri,oi)=T.VelocityRMSEReductionPercent(i);
        s.headingRMSEreduction_pct(ri,oi)=T.HeadingRMSEReductionPercent(i);
        s.quantumNIS(ri,oi)=T.QuantumMeanNIS(i);
        if ismember('MeanRelativeReductionPercent',T.Properties.VariableNames)
            s.meanPairedRelativeReduction_pct(ri,oi)=T.MeanRelativeReductionPercent(i);
        end
    end

    s.meta.source='Published OpenNavLab Phase 7D sensitivity summary';
    s.meta.isProductionResult=true;
end
