function render_replay_frame(fig,idx)
%RENDER_REPLAY_FRAME Render one sample across dashboard views.

    if isempty(fig) || ~isvalid(fig), return; end

    app = fig.UserData;
    data = app.Data;
    theme = app.Theme;

    idx = max(1,min(numel(data.time),round(idx)));
    app.Playback.currentIndex = idx;

    stride = max(1,round(0.10/data.meta.dt_s));
    traceIdx = unique([1:stride:idx, idx]);

    rp = app.Pages.Replay;
    rp.TruthTrace.XData = data.truth.position(traceIdx,1);
    rp.TruthTrace.YData = data.truth.position(traceIdx,2);
    rp.ClassicalTrace.XData = data.classical.position(traceIdx,1);
    rp.ClassicalTrace.YData = data.classical.position(traceIdx,2);
    rp.QuantumTrace.XData = data.quantum.position(traceIdx,1);
    rp.QuantumTrace.YData = data.quantum.position(traceIdx,2);

    rp.TruthMarker.XData = data.truth.position(idx,1);
    rp.TruthMarker.YData = data.truth.position(idx,2);
    rp.ClassicalMarker.XData = data.classical.position(idx,1);
    rp.ClassicalMarker.YData = data.classical.position(idx,2);
    rp.QuantumMarker.XData = data.quantum.position(idx,1);
    rp.QuantumMarker.YData = data.quantum.position(idx,2);

    op = app.Pages.Overview;
    op.TruthMarker.XData = data.truth.position(idx,1);
    op.TruthMarker.YData = data.truth.position(idx,2);
    op.ClassicalMarker.XData = data.classical.position(idx,1);
    op.ClassicalMarker.YData = data.classical.position(idx,2);
    op.QuantumMarker.XData = data.quantum.position(idx,1);
    op.QuantumMarker.YData = data.quantum.position(idx,2);

    cErr = data.errors.classical.position_m(idx);
    qErr = data.errors.quantum.position_m(idx);

    rp.ClassicalError.Text = format_metric(cErr,'m',2);
    rp.QuantumError.Text = format_metric(qErr,'m',2);

    if cErr > 1e-9
        reduction = 100*(cErr-qErr)/cErr;
        rp.CurrentImprovement.Text = format_metric(reduction,'%',1);
    else
        rp.CurrentImprovement.Text = '--';
    end

    currentTime = data.time(idx);
    rp.TimeLabel.Text = sprintf('%.2f s',currentTime);
    rp.TimeCaption.Text = sprintf('t = %.2f s',currentTime);
    rp.TimeSlider.Value = currentTime;
    app.Footer.Time.Text = sprintf('t = %.2f s',currentTime);


    % Shared replay cursor on the Errors page.
    if isfield(app.Pages,'Errors')
        e = app.Pages.Errors;
        updateCursor(e.PositionCursor,currentTime);
        updateCursor(e.VelocityCursor,currentTime);
        updateCursor(e.HeadingCursor,currentTime);
    end

    if data.gps.outageMask(idx)
        rp.GPSBadge.Text = 'GPS DENIED';
        rp.GPSBadge.FontColor = theme.Error;
        rp.GPSBadge.BackgroundColor = theme.ErrorBackground;
        rp.StateText.Text = 'GPS DENIED';
        rp.StateText.FontColor = theme.Error;
        app.Footer.GPS.Text = 'GPS DENIED';
        app.Footer.GPS.FontColor = theme.Error;
    else
        rp.GPSBadge.Text = 'GPS AVAILABLE';
        rp.GPSBadge.FontColor = theme.Success;
        rp.GPSBadge.BackgroundColor = theme.SuccessBackground;
        rp.StateText.Text = 'GPS AVAILABLE';
        rp.StateText.FontColor = theme.Success;
        app.Footer.GPS.Text = 'GPS AVAILABLE';
        app.Footer.GPS.FontColor = theme.Success;
    end

    % Keep quantum status completely static. Frequent colour pulses at
    % 1-2 Hz looked like UI flicker, so quantum update timing is shown only
    % in the analysis plots rather than by flashing the status badge.
    rp.QuantumBadge.Text = sprintf('QUANTUM ACTIVE  |  %g Hz',data.meta.quantumRate_Hz);
    rp.QuantumBadge.BackgroundColor = theme.AccentSoft;
    rp.QuantumBadge.FontColor = theme.Accent;
    app.Footer.Quantum.Text = 'QUANTUM ACTIVE';
    app.Footer.Quantum.FontColor = theme.Accent;

    fig.UserData = app;
    drawnow limitrate;
end


function updateCursor(cursor,t)
    x = cursor.XData;
    if numel(x) < 2
        cursor.XData = [t t];
    else
        cursor.XData = [t t];
    end
end
