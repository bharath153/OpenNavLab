function handles = build_monte_carlo_page(parent, theme, research)
%BUILD_MONTE_CARLO_PAGE Paired Phase 7C-style statistical explorer.

    mc = research.mc;
    metricItems = {'Maximum Outage Error','Position RMSE', ...
        'Final Position Error','Velocity RMSE','Heading RMSE'};
    defaultMetric = metricItems{1};
    [c,q,unit,label,decimals] = get_mc_metric(mc,defaultMetric);
    gain = c-q;

    panel = uipanel(parent,'BorderType','none','BackgroundColor',theme.Background);
    panel.Layout.Row = 1;
    panel.Layout.Column = 1;

    grid = uigridlayout(panel,[5 4]);
    grid.RowHeight = {54,92,'1x',136,34};
    grid.ColumnWidth = {'1x','1x','1x','1x'};
    grid.RowSpacing = 10;
    grid.ColumnSpacing = 12;
    grid.Padding = [24 16 24 16];
    grid.BackgroundColor = theme.Background;

    pageTitle = uilabel(grid,'Text','Monte Carlo Explorer','FontSize',22, ...
        'FontWeight','bold','FontColor',theme.TextPrimary);
    pageTitle.Layout.Row = 1;
    pageTitle.Layout.Column = [1 2];

    controlPanel = uipanel(grid,'BorderType','none','BackgroundColor',theme.Background);
    controlPanel.Layout.Row = 1;
    controlPanel.Layout.Column = [3 4];

    cg = uigridlayout(controlPanel,[1 6]);
    cg.ColumnWidth = {55,'1x',40,72,120,105};
    cg.Padding = [0 4 0 0];
    cg.BackgroundColor = theme.Background;

    uilabel(cg,'Text','Metric','HorizontalAlignment','right', ...
        'FontSize',10,'FontColor',theme.TextSecondary);
    metricDropDown = uidropdown(cg,'Items',metricItems,'Value',defaultMetric);

    uilabel(cg,'Text','Run','HorizontalAlignment','right', ...
        'FontSize',10,'FontColor',theme.TextSecondary);
    runSpinner = uispinner(cg,'Limits',[1 numel(mc.run)],'Step',1,'Value',1);
    loadButton = uibutton(cg,'push','Text','Load Results');
    loadStatus = uilabel(cg,'Text','Demo data','HorizontalAlignment','center','FontSize',9,'FontColor',theme.TextMuted);

    cardC = create_kpi_card(grid,theme,'Classical mean', ...
        localFmt(mean(c),unit,decimals),'100 paired runs');
    cardC.Panel.Layout.Row = 2; cardC.Panel.Layout.Column = 1;

    cardQ = create_kpi_card(grid,theme,'Quantum mean', ...
        localFmt(mean(q),unit,decimals),'Same stochastic realizations');
    cardQ.Panel.Layout.Row = 2; cardQ.Panel.Layout.Column = 2;

    cardGain = create_kpi_card(grid,theme,'Mean paired gain', ...
        localFmt(mean(gain),unit,decimals),'Classical - quantum');
    cardGain.Panel.Layout.Row = 2; cardGain.Panel.Layout.Column = 3;

    improved = 100*mean(gain>0);
    cardImproved = create_kpi_card(grid,theme,'Runs improved', ...
        sprintf('%.0f %%',improved),'Paired run-level comparison');
    cardImproved.Panel.Layout.Row = 2; cardImproved.Panel.Layout.Column = 4;
    cardImproved.Value.FontColor = theme.Quantum;

    scatterPanel = uipanel(grid,'BorderType','line','BorderColor',theme.Border, ...
        'BackgroundColor',theme.PanelBackground);
    scatterPanel.Layout.Row = 3;
    scatterPanel.Layout.Column = [1 2];

    sg = uigridlayout(scatterPanel,[1 1]);
    sg.Padding = [10 10 10 8];
    sg.BackgroundColor = theme.PanelBackground;

    scatterAx = uiaxes(sg);
    scatterAx.Color = theme.PanelBackground;
    scatterAx.XColor = theme.TextMuted;
    scatterAx.YColor = theme.TextMuted;
    scatterAx.GridColor = theme.Border;
    scatterAx.XGrid = 'on'; scatterAx.YGrid = 'on'; scatterAx.Box = 'off';
    hold(scatterAx,'on');

    scatterPts = scatter(scatterAx,c,q,24, ...
        'MarkerFaceColor',theme.AccentSoft, ...
        'MarkerEdgeColor',theme.Classical);

    lim = pairedLimits(c,q);
    equalityLine = plot(scatterAx,lim,lim,'--','Color',theme.TextMuted,'LineWidth',1.0);
    selectedPoint = plot(scatterAx,c(1),q(1),'o','MarkerSize',9, ...
        'MarkerFaceColor',theme.Quantum,'MarkerEdgeColor',theme.TextPrimary);

    xlim(scatterAx,lim); ylim(scatterAx,lim);
    xlabel(scatterAx,sprintf('Classical [%s]',unit));
    ylabel(scatterAx,sprintf('Quantum-aided [%s]',unit));
    title(scatterAx,[label ' - paired runs'],'FontWeight','bold');
    legend(scatterAx,{'Paired run','y = x','Selected run'}, ...
        'Location','best','Box','off');

    histPanel = uipanel(grid,'BorderType','line','BorderColor',theme.Border, ...
        'BackgroundColor',theme.PanelBackground);
    histPanel.Layout.Row = 3;
    histPanel.Layout.Column = [3 4];

    hg = uigridlayout(histPanel,[1 1]);
    hg.Padding = [10 10 10 8];
    hg.BackgroundColor = theme.PanelBackground;

    histAx = uiaxes(hg);
    histAx.Color = theme.PanelBackground;
    histAx.XColor = theme.TextMuted;
    histAx.YColor = theme.TextMuted;
    histAx.GridColor = theme.Border;
    histAx.XGrid = 'on'; histAx.YGrid = 'on'; histAx.Box = 'off';
    hold(histAx,'on');

    histObj = histogram(histAx,gain,18, ...
        'FaceColor',theme.Quantum,'FaceAlpha',0.55,'EdgeColor',theme.Border);
    zeroLine = xline(histAx,0,'--','No change','Color',theme.TextMuted);
    xlabel(histAx,sprintf('Paired gain [%s]',unit));
    ylabel(histAx,'Runs');
    title(histAx,'Distribution of paired improvement','FontWeight','bold');

    detailPanel = uipanel(grid,'BorderType','line','BorderColor',theme.Border, ...
        'BackgroundColor',theme.PanelBackground);
    detailPanel.Layout.Row = 4;
    detailPanel.Layout.Column = [1 4];

    dg = uigridlayout(detailPanel,[2 6]);
    dg.RowHeight = {28,'1x'};
    dg.ColumnWidth = {95,120,120,145,'1x',110};
    dg.Padding = [16 10 16 10];
    dg.ColumnSpacing = 12;
    dg.BackgroundColor = theme.PanelBackground;

    detailTitle = uilabel(dg,'Text','SELECTED RUN','FontSize',10, ...
        'FontWeight','bold','FontColor',theme.TextMuted);
    detailTitle.Layout.Column = 1;

    runLabel = uilabel(dg,'Text','Run 1 / 100','FontSize',10, ...
        'FontWeight','bold','FontColor',theme.TextPrimary);
    runLabel.Layout.Column = [2 4];

    p95C = percentile95(c);
    p95Q = percentile95(q);
    p95Label = uilabel(dg,'Text',sprintf('P95: %s -> %s', ...
        localFmt(p95C,unit,decimals),localFmt(p95Q,unit,decimals)), ...
        'HorizontalAlignment','right','FontColor',theme.TextSecondary);
    p95Label.Layout.Column = [5 6];

    classicalLabel = uilabel(dg,'Text','Classical','FontColor',theme.TextSecondary);
    classicalLabel.Layout.Column = 1;

    runClassical = uilabel(dg,'Text',localFmt(c(1),unit,decimals), ...
        'FontWeight','bold','FontColor',theme.Classical, ...
        'HorizontalAlignment','left');
    runClassical.Layout.Column = 2;

    quantumLabel = uilabel(dg,'Text','Quantum-aided','FontColor',theme.TextSecondary);
    quantumLabel.Layout.Column = 3;

    runQuantum = uilabel(dg,'Text',localFmt(q(1),unit,decimals), ...
        'FontWeight','bold','FontColor',theme.Quantum, ...
        'HorizontalAlignment','left');
    runQuantum.Layout.Column = 4;

    runGainLabel = uilabel(dg,'Text',sprintf('Gain: %s',localFmt(gain(1),unit,decimals)), ...
        'HorizontalAlignment','center','FontWeight','bold','FontColor',theme.TextPrimary);
    runGainLabel.Layout.Column = 5;

    stateLabel = uilabel(dg,'Text',runState(gain(1)), ...
        'HorizontalAlignment','center','FontWeight','bold', ...
        'FontColor',stateColor(theme,gain(1)));
    stateLabel.Layout.Column = 6;

    note = uilabel(grid,'Text', ...
        'Deterministic Phase 7C-style demo data for dashboard validation; replace with saved paired Monte Carlo results for final evidence.', ...
        'FontSize',9,'FontColor',theme.TextMuted,'WordWrap','on');
    note.Layout.Row = 5;
    note.Layout.Column = [1 4];

    handles.Panel = panel;
    handles.MetricDropDown = metricDropDown;
    handles.RunSpinner = runSpinner;
    handles.CardClassical = cardC;
    handles.CardQuantum = cardQ;
    handles.CardGain = cardGain;
    handles.CardImproved = cardImproved;
    handles.ScatterAxes = scatterAx;
    handles.Scatter = scatterPts;
    handles.EqualityLine = equalityLine;
    handles.SelectedPoint = selectedPoint;
    handles.HistAxes = histAx;
    handles.Histogram = histObj;
    handles.ZeroLine = zeroLine;
    handles.RunLabel = runLabel;
    handles.RunClassical = runClassical;
    handles.RunQuantum = runQuantum;
    handles.RunGain = runGainLabel;
    handles.P95Label = p95Label;
    handles.StateLabel = stateLabel;
    handles.LoadButton = loadButton;
    handles.LoadStatus = loadStatus;
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

function p = percentile95(x)
    x = sort(x(:));
    idx = max(1,min(numel(x),ceil(0.95*numel(x))));
    p = x(idx);
end

function txt = runState(g)
    if g > 0
        txt = 'IMPROVED';
    elseif g < 0
        txt = 'DEGRADED';
    else
        txt = 'UNCHANGED';
    end
end

function c = stateColor(theme,g)
    if g > 0
        c = theme.Success;
    elseif g < 0
        c = theme.Error;
    else
        c = theme.TextSecondary;
    end
end
