function apply_mission_callback(fig)
%APPLY_MISSION_CALLBACK Build an exploratory dashboard preview case.

    if isempty(fig) || ~isvalid(fig), return; end

    app = fig.UserData;
    mission = app.Pages.Mission;

    cfg.outageStart_s = mission.OutageStart.Value;
    cfg.outageDuration_s = mission.OutageDuration.Value;
    cfg.quantumRate_Hz = str2double(mission.QuantumRate.Value);

    if cfg.outageStart_s + cfg.outageDuration_s > 120
        cfg.outageDuration_s = max(0,120-cfg.outageStart_s);
        mission.OutageDuration.Value = cfg.outageDuration_s;
    end

    data = create_demo_case(cfg);
    data.meta.source = 'Dashboard what-if preview (not an EKF rerun)';
    data.meta.isProductionResult = false;

    % Preserve the Mission status text, then refresh all dashboard pages
    % through the same path used by externally loaded MAT results.
    fig.UserData = app;
    apply_loaded_case(fig,data,sprintf( ...
        'Scenario applied: %.1f s outage starting at %.1f s, quantum %.2g Hz.', ...
        cfg.outageDuration_s,cfg.outageStart_s,cfg.quantumRate_Hz));

    app = fig.UserData;
    metrics = app.Metrics;
    mission = app.Pages.Mission;

    mission.OutageEnd.Value = metrics.outageEnd_s;
    mission.Status.Text = 'PREVIEW ACTIVE';
    mission.Status.FontColor = app.Theme.AccentDark;
    mission.Status.BackgroundColor = app.Theme.AccentSoft;
    mission.PreviewGPS.Text = sprintf('GPS denied from %.1f to %.1f s', ...
        metrics.outageStart_s,metrics.outageEnd_s);
    mission.PreviewQuantum.Text = sprintf('Quantum reference: %g Hz', ...
        data.meta.quantumRate_Hz);
    mission.PreviewReduction.Text = sprintf('Current max-error reduction: %.1f%%', ...
        metrics.maxOutageReduction_pct);

    fig.UserData = app;

end
