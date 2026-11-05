function sensitivity_metric_callback(fig)
%SENSITIVITY_METRIC_CALLBACK Update heatmap metric.

    if isempty(fig) || ~isvalid(fig), return; end

    app = fig.UserData;
    h = app.Pages.Sensitivity;
    s = app.Research.sensitivity;

    metric = h.MetricDropDown.Value;
    C = getHeatData(s,metric);

    h.HeatImage.CData = C;
    title(h.HeatAxes,char(metric),'FontWeight','bold');

    finiteVals = C(isfinite(C));
    if ~isempty(finiteVals)
        lo = min(finiteVals);
        hi = max(finiteVals);
        if hi <= lo, hi = lo + 1; end
        caxis(h.HeatAxes,[lo hi]);
    end

    app.Pages.Sensitivity = h;
    fig.UserData = app;
end

function C = getHeatData(s,metric)
    switch char(metric)
        case 'Position RMSE Reduction'
            C = s.positionRMSEreduction_pct;
        case 'Velocity RMSE Reduction'
            C = s.velocityRMSEreduction_pct;
        case 'Heading RMSE Reduction'
            C = s.headingRMSEreduction_pct;
        case 'P95 Reduction'
            C = s.p95Reduction_pct;
        case 'Runs Improved'
            C = s.runsImproved_pct;
        case 'Quantum NIS'
            C = s.quantumNIS;
        otherwise
            error('Unknown sensitivity metric: %s',char(metric));
    end
end
