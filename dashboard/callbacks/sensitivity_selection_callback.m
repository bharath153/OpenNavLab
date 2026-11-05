function sensitivity_selection_callback(fig)
%SENSITIVITY_SELECTION_CALLBACK Update selected operating-point details.

    if isempty(fig) || ~isvalid(fig), return; end

    app = fig.UserData;
    h = app.Pages.Sensitivity;
    s = app.Research.sensitivity;

    outageVal = str2double(h.OutageDropDown.Value);
    rateVal = str2double(h.RateDropDown.Value);

    [~,oi] = min(abs(s.outage_s-outageVal));
    [~,ri] = min(abs(s.rates_Hz-rateVal));

    cMean = s.classicalMeanMax_m(oi);
    qMean = s.quantumMeanMax_m(ri,oi);
    meanRed = s.meanReduction_pct(ri,oi);

    cP95 = s.classicalP95_m(oi);
    qP95 = s.quantumP95_m(ri,oi);
    p95Red = s.p95Reduction_pct(ri,oi);

    h.CardMean.Value.Text = sprintf('%.3f -> %.3f m',cMean,qMean);
    h.CardMean.Detail.Text = sprintf('%.1f%% reduction',meanRed);

    h.CardP95.Value.Text = sprintf('%.3f -> %.3f m',cP95,qP95);
    h.CardP95.Detail.Text = sprintf('%.1f%% reduction',p95Red);

    h.CardRuns.Value.Text = sprintf('%.0f %%',s.runsImproved_pct(ri,oi));
    h.CardNIS.Value.Text = sprintf('%.3f',s.quantumNIS(ri,oi));

    h.SelectedPoint.XData = s.outage_s(oi);
    h.SelectedPoint.YData = qMean;

    h.Detail1.Text = sprintf('%g s / %g Hz  |  Mean reduction %.1f%%', ...
        s.outage_s(oi),s.rates_Hz(ri),meanRed);

    h.Detail2.Text = sprintf('P95 reduction %.1f%%  |  Runs improved %.0f%%', ...
        p95Red,s.runsImproved_pct(ri,oi));

    h.Detail3.Text = sprintf('Position / velocity / heading RMSE: %.1f / %.1f / %.1f%%', ...
        s.positionRMSEreduction_pct(ri,oi), ...
        s.velocityRMSEreduction_pct(ri,oi), ...
        s.headingRMSEreduction_pct(ri,oi));

    app.Pages.Sensitivity = h;
    fig.UserData = app;
end
