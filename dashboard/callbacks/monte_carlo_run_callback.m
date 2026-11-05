function monte_carlo_run_callback(fig)
%MONTE_CARLO_RUN_CALLBACK Update selected paired-run detail.

    if isempty(fig) || ~isvalid(fig), return; end

    app = fig.UserData;
    h = app.Pages.MonteCarlo;
    mc = app.Research.mc;

    [c,q,unit,~,d] = get_mc_metric(mc,h.MetricDropDown.Value);
    gain = c-q;

    idx = round(h.RunSpinner.Value);
    idx = max(1,min(numel(c),idx));
    h.RunSpinner.Value = idx;

    h.SelectedPoint.XData = c(idx);
    h.SelectedPoint.YData = q(idx);

    h.RunLabel.Text = sprintf('Run %d / %d',idx,numel(c));
    h.RunClassical.Text = localFmt(c(idx),unit,d);
    h.RunQuantum.Text = localFmt(q(idx),unit,d);
    h.RunGain.Text = sprintf('Gain: %s',localFmt(gain(idx),unit,d));

    p95C = percentile95(c);
    p95Q = percentile95(q);
    h.P95Label.Text = sprintf('P95: %s -> %s', ...
        localFmt(p95C,unit,d),localFmt(p95Q,unit,d));

    if gain(idx) > 0
        h.StateLabel.Text = 'IMPROVED';
        h.StateLabel.FontColor = app.Theme.Success;
    elseif gain(idx) < 0
        h.StateLabel.Text = 'DEGRADED';
        h.StateLabel.FontColor = app.Theme.Error;
    else
        h.StateLabel.Text = 'UNCHANGED';
        h.StateLabel.FontColor = app.Theme.TextSecondary;
    end

    app.Pages.MonteCarlo = h;
    fig.UserData = app;
end

function txt = localFmt(v,unit,d)
    txt = sprintf(['%.' num2str(d) 'f %s'],v,unit);
end

function p = percentile95(x)
    x = sort(x(:));
    idx = max(1,min(numel(x),ceil(0.95*numel(x))));
    p = x(idx);
end
