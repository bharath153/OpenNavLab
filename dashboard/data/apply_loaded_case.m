function apply_loaded_case(fig,data,messageText)
%APPLY_LOADED_CASE Replace dashboard data and refresh all supported pages.

    if isempty(fig) || ~isvalid(fig), return; end
    if nargin < 3, messageText = 'Case loaded.'; end

    app = fig.UserData;

    if strcmp(app.Playback.Timer.Running,'on')
        stop(app.Playback.Timer);
    end

    metrics = compute_dashboard_metrics(data);
    app.Data = data;
    app.Metrics = metrics;
    app.Playback.currentIndex = 1;
    app.Playback.isPlaying = false;
    app.Pages.Replay.PlayPauseButton.Text = 'Play';

    app.Header.Scenario.Text = sprintf('%g s outage  /  Q = %g Hz', ...
        metrics.outageDuration_s,data.meta.quantumRate_Hz);

    % Mission controls / preview.
    m = app.Pages.Mission;
    if isfinite(metrics.outageStart_s), m.OutageStart.Value = metrics.outageStart_s; end
    m.OutageDuration.Value = max(0,metrics.outageDuration_s);
    if isfinite(metrics.outageEnd_s), m.OutageEnd.Value = metrics.outageEnd_s; end
    rateStr = num2str(data.meta.quantumRate_Hz);
    if any(strcmp(m.QuantumRate.Items,rateStr))
        m.QuantumRate.Value = rateStr;
    end
    m.PreviewGPS.Text = sprintf('GPS denied from %.1f to %.1f s', ...
        metrics.outageStart_s,metrics.outageEnd_s);
    m.PreviewQuantum.Text = sprintf('Quantum reference: %g Hz',data.meta.quantumRate_Hz);
    m.PreviewReduction.Text = sprintf('Current max-error reduction: %.1f%%', ...
        metrics.maxOutageReduction_pct);

    % Data provenance.
    isProduction = isfield(data,'meta') && isfield(data.meta,'isProductionResult') ...
        && logical(data.meta.isProductionResult);

    if isProduction
        m.Status.Text = 'REFERENCE RUN';
        m.Status.FontColor = app.Theme.Success;
        m.Status.BackgroundColor = app.Theme.SuccessBackground;
        app.Pages.Evidence.SingleRunSource.Text = 'Single-run: Phase 7B repository result';
        app.Pages.Evidence.SingleRunSource.FontColor = app.Theme.Success;
    else
        m.Status.Text = 'PREVIEW ACTIVE';
        m.Status.FontColor = app.Theme.Warning;
        m.Status.BackgroundColor = app.Theme.WarningBackground;
        app.Pages.Evidence.SingleRunSource.Text = 'Single-run: what-if preview';
        app.Pages.Evidence.SingleRunSource.FontColor = app.Theme.Warning;
    end

    % Overview.
    app.Pages.Overview.CardScenario.Value.Text = sprintf('%g s / %g Hz', ...
        metrics.outageDuration_s,data.meta.quantumRate_Hz);
    app.Pages.Overview.CardClassical.Value.Text = ...
        format_metric(metrics.classicalMaxOutageError_m,'m',2);
    app.Pages.Overview.CardQuantum.Value.Text = ...
        format_metric(metrics.quantumMaxOutageError_m,'m',2);
    app.Pages.Overview.CardGain.Value.Text = ...
        format_metric(metrics.maxOutageReduction_pct,'%',1);

    % Update overview path.
    ax = app.Pages.Overview.Axes;
    cla(ax);
    hold(ax,'on');
    plot(ax,data.truth.position(:,1),data.truth.position(:,2),'-', ...
        'Color',[0.82 0.83 0.85],'LineWidth',1.0);
    app.Pages.Overview.TruthMarker = plot(ax,data.truth.position(1,1),data.truth.position(1,2),'o', ...
        'MarkerSize',7,'MarkerFaceColor',app.Theme.Truth,'MarkerEdgeColor',app.Theme.Truth);
    app.Pages.Overview.ClassicalMarker = plot(ax,data.classical.position(1,1),data.classical.position(1,2),'o', ...
        'MarkerSize',6,'MarkerFaceColor',app.Theme.Classical,'MarkerEdgeColor',app.Theme.Classical);
    app.Pages.Overview.QuantumMarker = plot(ax,data.quantum.position(1,1),data.quantum.position(1,2),'o', ...
        'MarkerSize',6,'MarkerFaceColor',app.Theme.Quantum,'MarkerEdgeColor',app.Theme.Quantum);
    xlabel(ax,'East / x [m]'); ylabel(ax,'North / y [m]');
    ax.XGrid='on'; ax.YGrid='on'; ax.Box='off'; ax.DataAspectRatio=[1 1 1];
    legend(ax,{'Truth path','Truth position','Classical','Quantum-aided'},'Location','best','Box','off');

    % Replay path.
    ax = app.Pages.Replay.Axes;
    cla(ax);
    hold(ax,'on');
    plot(ax,data.truth.position(:,1),data.truth.position(:,2),'-', ...
        'Color',[0.80 0.81 0.83],'LineWidth',1.0);
    app.Pages.Replay.TruthTrace = plot(ax,nan,nan,'-','Color',app.Theme.Truth,'LineWidth',1.5);
    app.Pages.Replay.ClassicalTrace = plot(ax,nan,nan,'-','Color',app.Theme.Classical,'LineWidth',1.8);
    app.Pages.Replay.QuantumTrace = plot(ax,nan,nan,'-','Color',app.Theme.Quantum,'LineWidth',1.8);
    app.Pages.Replay.TruthMarker = plot(ax,nan,nan,'o','MarkerSize',7, ...
        'MarkerFaceColor',app.Theme.Truth,'MarkerEdgeColor',app.Theme.Truth);
    app.Pages.Replay.ClassicalMarker = plot(ax,nan,nan,'o','MarkerSize',6, ...
        'MarkerFaceColor',app.Theme.Classical,'MarkerEdgeColor',app.Theme.Classical);
    app.Pages.Replay.QuantumMarker = plot(ax,nan,nan,'o','MarkerSize',6, ...
        'MarkerFaceColor',app.Theme.Quantum,'MarkerEdgeColor',app.Theme.Quantum);
    xlabel(ax,'East / x [m]'); ylabel(ax,'North / y [m]');
    ax.XGrid='on'; ax.YGrid='on'; ax.Box='off'; ax.DataAspectRatio=[1 1 1];
    legend(ax,{'Full truth','Truth replay','Classical EKF','Quantum-aided EKF'}, ...
        'Location','best','Box','off');

    app.Pages.Replay.TimeSlider.Limits = [data.time(1) data.time(end)];
    app.Pages.Replay.TimeSlider.Value = data.time(1);
    if isfinite(metrics.outageStart_s)
        app.Pages.Replay.TimeSlider.MajorTicks = ...
            [data.time(1),metrics.outageStart_s,metrics.outageEnd_s,data.time(end)];
        app.Pages.Replay.TimeSlider.MajorTickLabels = ...
            {sprintf('%.0f',data.time(1)),sprintf('%.0f',metrics.outageStart_s), ...
             sprintf('%.0f',metrics.outageEnd_s),sprintf('%.0f',data.time(end))};
        app.Pages.Replay.OutageLabel.Text = sprintf('GPS outage: %.1f-%.1f s', ...
            metrics.outageStart_s,metrics.outageEnd_s);
    else
        app.Pages.Replay.OutageLabel.Text = 'GPS outage: none';
    end

    app.Pages.Replay.ReferenceNote.Text = sprintf( ...
        'Reference: classical max %.2f m, quantum %.2f m (%.1f%% reduction).', ...
        metrics.classicalMaxOutageError_m,metrics.quantumMaxOutageError_m, ...
        metrics.maxOutageReduction_pct);

    % Errors.
    refreshErrorPage(app.Pages.Errors,data,metrics);

    % Quantum.
    refreshQuantumPage(app.Pages.Quantum,data);

    app.Footer.Status.Text = 'READY';
    app.Footer.Message.Text = messageText;
    fig.UserData = app;

    render_replay_frame(fig,1);
end

function refreshErrorPage(e,data,metrics)
    e.PositionClassical.XData = data.time;
    e.PositionClassical.YData = data.errors.classical.position_m;
    e.PositionQuantum.XData = data.time;
    e.PositionQuantum.YData = data.errors.quantum.position_m;

    e.VelocityClassical.XData = data.time;
    e.VelocityClassical.YData = data.errors.classical.velocity_mps;
    e.VelocityQuantum.XData = data.time;
    e.VelocityQuantum.YData = data.errors.quantum.velocity_mps;

    e.HeadingClassical.XData = data.time;
    e.HeadingClassical.YData = data.errors.classical.heading_deg;
    e.HeadingQuantum.XData = data.time;
    e.HeadingQuantum.YData = data.errors.quantum.heading_deg;

    refreshAxis(e.PositionAxes,e.PositionCursor,e.PositionOutagePatch, ...
        data.time,data.errors.classical.position_m,data.errors.quantum.position_m,metrics);
    refreshAxis(e.VelocityAxes,e.VelocityCursor,e.VelocityOutagePatch, ...
        data.time,data.errors.classical.velocity_mps,data.errors.quantum.velocity_mps,metrics);
    refreshAxis(e.HeadingAxes,e.HeadingCursor,e.HeadingOutagePatch, ...
        data.time,data.errors.classical.heading_deg,data.errors.quantum.heading_deg,metrics);

    e.PositionCard.Value.Text = sprintf('%.2f -> %.2f m', ...
        metrics.classicalPositionRMSE_m,metrics.quantumPositionRMSE_m);
    e.PositionCard.Detail.Text = sprintf('%.1f%% reduction',metrics.positionRMSEreduction_pct);

    e.VelocityCard.Value.Text = sprintf('%.3f -> %.3f m/s', ...
        metrics.classicalVelocityRMSE_mps,metrics.quantumVelocityRMSE_mps);
    e.VelocityCard.Detail.Text = sprintf('%.1f%% reduction',metrics.velocityRMSEreduction_pct);

    e.HeadingCard.Value.Text = sprintf('%.2f -> %.2f deg', ...
        metrics.classicalHeadingRMSE_deg,metrics.quantumHeadingRMSE_deg);
    e.HeadingCard.Detail.Text = sprintf('%.1f%% reduction',metrics.headingRMSEreduction_pct);
end

function refreshAxis(ax,cursor,p,outTime,cErr,qErr,metrics)
    ymax = max([cErr(:);qErr(:)]);
    if ~isfinite(ymax) || ymax<=0, ymax=1; end
    ymax = 1.08*ymax;
    xlim(ax,[outTime(1) outTime(end)]);
    ylim(ax,[0 ymax]);
    cursor.XData = [outTime(1) outTime(1)];
    cursor.YData = [0 ymax];
    if isfinite(metrics.outageStart_s)
        p.XData = [metrics.outageStart_s metrics.outageEnd_s metrics.outageEnd_s metrics.outageStart_s];
        p.YData = [0 0 ymax ymax];
        p.Visible = 'on';
    else
        p.Visible = 'off';
    end
end

function refreshQuantumPage(q,data)
    q.CardRate.Value.Text = sprintf('%g Hz',data.meta.quantumRate_Hz);
    q.CardRate.Detail.Text = sprintf('%d update events',sum(data.quantum.updateMask));

    g = mean(data.nis.gps,'omitnan');
    qq = mean(data.nis.quantum,'omitnan');
    q.CardGPS.Value.Text = safe(g);
    q.CardGPS.Detail.Text = sprintf('Expected %.0f',data.nis.gpsExpected);
    q.CardQuantum.Value.Text = safe(qq);
    q.CardQuantum.Detail.Text = sprintf('Expected %.0f',data.nis.quantumExpected);

    q.BiasXTrue.XData=data.time; q.BiasXTrue.YData=data.bias.true.accel_x_mps2;
    q.BiasXClassical.XData=data.time; q.BiasXClassical.YData=data.bias.classical.accel_x_mps2;
    q.BiasXQuantum.XData=data.time; q.BiasXQuantum.YData=data.bias.quantum.accel_x_mps2;

    q.GyroTrue.XData=data.time; q.GyroTrue.YData=rad2deg(data.bias.true.gyro_z_rps);
    q.GyroClassical.XData=data.time; q.GyroClassical.YData=rad2deg(data.bias.classical.gyro_z_rps);
    q.GyroQuantum.XData=data.time; q.GyroQuantum.YData=rad2deg(data.bias.quantum.gyro_z_rps);

    q.GPSNIS.XData=data.time; q.GPSNIS.YData=data.nis.gps;
    q.QuantumNIS.XData=data.time; q.QuantumNIS.YData=data.nis.quantum;

    xlim(q.BiasXAxes,[data.time(1) data.time(end)]);
    xlim(q.GyroAxes,[data.time(1) data.time(end)]);
    xlim(q.NISAxes,[data.time(1) data.time(end)]);
end

function t=safe(v)
    if isnan(v), t='--'; else, t=sprintf('%.3f',v); end
end
