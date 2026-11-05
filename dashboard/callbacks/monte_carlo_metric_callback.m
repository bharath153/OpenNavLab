function monte_carlo_metric_callback(fig)
%MONTE_CARLO_METRIC_CALLBACK Refresh plots/cards for selected MC metric.

    if isempty(fig) || ~isvalid(fig), return; end

    app = fig.UserData;
    h = app.Pages.MonteCarlo;
    mc = app.Research.mc;

    [c,q,unit,label,d] = get_mc_metric(mc,h.MetricDropDown.Value);
    gain = c-q;

    h.CardClassical.Value.Text = localFmt(mean(c),unit,d);
    h.CardQuantum.Value.Text = localFmt(mean(q),unit,d);
    h.CardGain.Value.Text = localFmt(mean(gain),unit,d);
    h.CardImproved.Value.Text = sprintf('%.0f %%',100*mean(gain>0));

    h.Scatter.XData = c;
    h.Scatter.YData = q;

    lim = pairedLimits(c,q);
    h.EqualityLine.XData = lim;
    h.EqualityLine.YData = lim;
    xlim(h.ScatterAxes,lim);
    ylim(h.ScatterAxes,lim);
    xlabel(h.ScatterAxes,sprintf('Classical [%s]',unit));
    ylabel(h.ScatterAxes,sprintf('Quantum-aided [%s]',unit));
    title(h.ScatterAxes,[label ' - paired runs'],'FontWeight','bold');

    h.Histogram.Data = gain;
    xlabel(h.HistAxes,sprintf('Paired gain [%s]',unit));

    app.Pages.MonteCarlo = h;
    fig.UserData = app;

    monte_carlo_run_callback(fig);
end

function lim = pairedLimits(a,b)
    lo = min([a(:);b(:)]);
    hi = max([a(:);b(:)]);
    span = max(hi-lo,eps);
    lim = [lo-0.08*span hi+0.08*span];
end

function txt = localFmt(v,unit,d)
    txt = sprintf(['%.' num2str(d) 'f %s'],v,unit);
end
