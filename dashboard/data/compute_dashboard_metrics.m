function metrics = compute_dashboard_metrics(data)
%COMPUTE_DASHBOARD_METRICS Compute dashboard summary metrics.

    outageMask = logical(data.gps.outageMask(:));
    t = data.time(:);

    if any(outageMask)
        idx = find(outageMask);

        if isfield(data,'meta') && isfield(data.meta,'outageStart_s') ...
                && isfield(data.meta,'outageEnd_s') ...
                && isfinite(data.meta.outageStart_s) && isfinite(data.meta.outageEnd_s)
            metrics.outageStart_s = double(data.meta.outageStart_s);
            metrics.outageEnd_s = double(data.meta.outageEnd_s);
        else
            metrics.outageStart_s = t(idx(1));
            dt = median(diff(t));
            metrics.outageEnd_s = t(idx(end)) + dt;
        end

        metrics.outageDuration_s = metrics.outageEnd_s-metrics.outageStart_s;

        metrics.classicalMaxOutageError_m = ...
            max(data.errors.classical.position_m(outageMask));
        metrics.quantumMaxOutageError_m = ...
            max(data.errors.quantum.position_m(outageMask));
    else
        metrics.outageStart_s = NaN;
        metrics.outageEnd_s = NaN;
        metrics.outageDuration_s = 0;
        metrics.classicalMaxOutageError_m = max(data.errors.classical.position_m);
        metrics.quantumMaxOutageError_m = max(data.errors.quantum.position_m);
    end

    metrics.maxOutageReduction_pct = pctReduction( ...
        metrics.classicalMaxOutageError_m,metrics.quantumMaxOutageError_m);

    % A compact GitHub dashboard snapshot can carry exact metrics from the
    % full 100 Hz Phase 7B reference run. Use those values for KPI cards and
    % validation while plotting the decimated visualization arrays.
    if isfield(data,'referenceMetrics')
        r = data.referenceMetrics;
        metrics.classicalMaxOutageError_m = r.classicalMaxOutageError_m;
        metrics.quantumMaxOutageError_m = r.quantumMaxOutageError_m;
        metrics.maxOutageReduction_pct = r.maxOutageReduction_pct;
        metrics.classicalPositionRMSE_m = r.classicalPositionRMSE_m;
        metrics.quantumPositionRMSE_m = r.quantumPositionRMSE_m;
        metrics.positionRMSEreduction_pct = pctReduction( ...
            r.classicalPositionRMSE_m,r.quantumPositionRMSE_m);
        metrics.classicalVelocityRMSE_mps = r.classicalVelocityRMSE_mps;
        metrics.quantumVelocityRMSE_mps = r.quantumVelocityRMSE_mps;
        metrics.velocityRMSEreduction_pct = pctReduction( ...
            r.classicalVelocityRMSE_mps,r.quantumVelocityRMSE_mps);
        metrics.classicalHeadingRMSE_deg = r.classicalHeadingRMSE_deg;
        metrics.quantumHeadingRMSE_deg = r.quantumHeadingRMSE_deg;
        metrics.headingRMSEreduction_pct = pctReduction( ...
            r.classicalHeadingRMSE_deg,r.quantumHeadingRMSE_deg);
        return;
    end

    metrics.classicalPositionRMSE_m = ...
        sqrt(mean(data.errors.classical.position_m.^2));
    metrics.quantumPositionRMSE_m = ...
        sqrt(mean(data.errors.quantum.position_m.^2));
    metrics.positionRMSEreduction_pct = pctReduction( ...
        metrics.classicalPositionRMSE_m,metrics.quantumPositionRMSE_m);

    metrics.classicalVelocityRMSE_mps = ...
        sqrt(mean(data.errors.classical.velocity_mps.^2));
    metrics.quantumVelocityRMSE_mps = ...
        sqrt(mean(data.errors.quantum.velocity_mps.^2));
    metrics.velocityRMSEreduction_pct = pctReduction( ...
        metrics.classicalVelocityRMSE_mps,metrics.quantumVelocityRMSE_mps);

    metrics.classicalHeadingRMSE_deg = ...
        sqrt(mean(data.errors.classical.heading_deg.^2));
    metrics.quantumHeadingRMSE_deg = ...
        sqrt(mean(data.errors.quantum.heading_deg.^2));
    metrics.headingRMSEreduction_pct = pctReduction( ...
        metrics.classicalHeadingRMSE_deg,metrics.quantumHeadingRMSE_deg);
end

function v = pctReduction(a,b)
    if a > eps
        v = 100*(a-b)/a;
    else
        v = NaN;
    end
end
