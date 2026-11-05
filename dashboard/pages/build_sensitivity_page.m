function handles = build_sensitivity_page(parent, theme, research)
%BUILD_SENSITIVITY_PAGE Phase 7D-style rate x outage explorer.

    s = research.sensitivity;
    metricItems = {'Position RMSE Reduction','Velocity RMSE Reduction', ...
        'Heading RMSE Reduction','P95 Reduction','Runs Improved','Quantum NIS'};
    defaultMetric = metricItems{1};

    panel = uipanel(parent,'BorderType','none','BackgroundColor',theme.Background);
    panel.Layout.Row = 1;
    panel.Layout.Column = 1;

    grid = uigridlayout(panel,[4 4]);
    grid.RowHeight = {54,92,'1x',125};
    grid.ColumnWidth = {'1x','1x','1x','1x'};
    grid.RowSpacing = 10;
    grid.ColumnSpacing = 12;
    grid.Padding = [24 16 24 16];
    grid.BackgroundColor = theme.Background;

    pageTitle = uilabel(grid,'Text','Sensitivity Explorer','FontSize',22, ...
        'FontWeight','bold','FontColor',theme.TextPrimary);
    pageTitle.Layout.Row = 1;
    pageTitle.Layout.Column = [1 2];

    controlPanel = uipanel(grid,'BorderType','none','BackgroundColor',theme.Background);
    controlPanel.Layout.Row = 1;
    controlPanel.Layout.Column = [3 4];

    cg = uigridlayout(controlPanel,[1 4]);
    cg.ColumnWidth = {105,'1x',120,105};
    cg.Padding = [0 4 0 0];
    cg.BackgroundColor = theme.Background;

    uilabel(cg,'Text','Heatmap metric','HorizontalAlignment','right', ...
        'FontSize',10,'FontColor',theme.TextSecondary);
    metricDropDown = uidropdown(cg,'Items',metricItems,'Value',defaultMetric);
    loadButton = uibutton(cg,'push','Text','Load Results');
    loadStatus = uilabel(cg,'Text','Demo data','HorizontalAlignment','center','FontSize',9,'FontColor',theme.TextMuted);

    % Default selected point: 40 s, 2 Hz.
    outageIdx = numel(s.outage_s);
    rateIdx = numel(s.rates_Hz);

    cardMean = create_kpi_card(grid,theme,'Mean max error', ...
        sprintf('%.3f -> %.3f m', ...
        s.classicalMeanMax_m(outageIdx),s.quantumMeanMax_m(rateIdx,outageIdx)), ...
        sprintf('%.1f%% reduction',s.meanReduction_pct(rateIdx,outageIdx)));
    cardMean.Panel.Layout.Row = 2; cardMean.Panel.Layout.Column = 1;

    cardP95 = create_kpi_card(grid,theme,'P95 error', ...
        sprintf('%.3f -> %.3f m', ...
        s.classicalP95_m(outageIdx),s.quantumP95_m(rateIdx,outageIdx)), ...
        sprintf('%.1f%% reduction',s.p95Reduction_pct(rateIdx,outageIdx)));
    cardP95.Panel.Layout.Row = 2; cardP95.Panel.Layout.Column = 2;

    cardRuns = create_kpi_card(grid,theme,'Runs improved', ...
        sprintf('%.0f %%',s.runsImproved_pct(rateIdx,outageIdx)), ...
        'Paired Monte Carlo runs');
    cardRuns.Panel.Layout.Row = 2; cardRuns.Panel.Layout.Column = 3;
    cardRuns.Value.FontColor = theme.Quantum;

    cardNIS = create_kpi_card(grid,theme,'Quantum NIS', ...
        sprintf('%.3f',s.quantumNIS(rateIdx,outageIdx)), ...
        'Expected value: 3');
    cardNIS.Panel.Layout.Row = 2; cardNIS.Panel.Layout.Column = 4;

    linePanel = uipanel(grid,'BorderType','line','BorderColor',theme.Border, ...
        'BackgroundColor',theme.PanelBackground);
    linePanel.Layout.Row = 3; linePanel.Layout.Column = [1 2];

    lg = uigridlayout(linePanel,[1 1]);
    lg.Padding = [10 10 10 8];
    lg.BackgroundColor = theme.PanelBackground;

    lineAx = uiaxes(lg);
    lineAx.Color = theme.PanelBackground;
    lineAx.XColor = theme.TextMuted;
    lineAx.YColor = theme.TextMuted;
    lineAx.GridColor = theme.Border;
    lineAx.XGrid = 'on'; lineAx.YGrid = 'on'; lineAx.Box = 'off';
    hold(lineAx,'on');

    lineClassical = plot(lineAx,s.outage_s,s.classicalMeanMax_m,'-o', ...
        'Color',theme.TextPrimary,'LineWidth',1.7,'MarkerSize',4);

    rateColors = [ ...
        0.55 0.68 0.86; ...
        0.39 0.57 0.82; ...
        0.22 0.46 0.76; ...
        0.10 0.62 0.50];

    rateLines = gobjects(numel(s.rates_Hz),1);
    for k = 1:numel(s.rates_Hz)
        rateLines(k) = plot(lineAx,s.outage_s,s.quantumMeanMax_m(k,:),'-o', ...
            'Color',rateColors(k,:),'LineWidth',1.4,'MarkerSize',4);
    end

    selectedPoint = plot(lineAx,s.outage_s(outageIdx), ...
        s.quantumMeanMax_m(rateIdx,outageIdx),'o', ...
        'MarkerSize',10,'MarkerFaceColor',theme.Quantum, ...
        'MarkerEdgeColor',theme.TextPrimary);

    xlabel(lineAx,'GPS outage duration [s]');
    ylabel(lineAx,'Mean maximum position error [m]');
    title(lineAx,'Phase 7D operating envelope','FontWeight','bold');
    legend(lineAx,{'Classical','Q 0.25 Hz','Q 0.5 Hz','Q 1 Hz','Q 2 Hz','Selected'}, ...
        'Location','northwest','Box','off');

    heatPanel = uipanel(grid,'BorderType','line','BorderColor',theme.Border, ...
        'BackgroundColor',theme.PanelBackground);
    heatPanel.Layout.Row = 3; heatPanel.Layout.Column = [3 4];

    hg = uigridlayout(heatPanel,[1 1]);
    hg.Padding = [12 10 12 8];
    hg.BackgroundColor = theme.PanelBackground;

    heatAx = uiaxes(hg);
    heatAx.Color = theme.PanelBackground;
    heatAx.XColor = theme.TextMuted;
    heatAx.YColor = theme.TextMuted;
    heatAx.Box = 'off';

    heatData = getHeatData(s,defaultMetric);
    heatImage = imagesc(heatAx,1:numel(s.outage_s),1:numel(s.rates_Hz),heatData);
    heatAx.YDir = 'normal';
    heatAx.XTick = 1:numel(s.outage_s);
    heatAx.XTickLabel = string(s.outage_s);
    heatAx.YTick = 1:numel(s.rates_Hz);
    heatAx.YTickLabel = string(s.rates_Hz);
    xlabel(heatAx,'Outage duration [s]');
    ylabel(heatAx,'Quantum rate [Hz]');
    title(heatAx,defaultMetric,'FontWeight','bold');
    colormap(heatAx,blueMap(64));
    colorbar(heatAx);

    selectionPanel = uipanel(grid,'BorderType','line','BorderColor',theme.Border, ...
        'BackgroundColor',theme.PanelBackground);
    selectionPanel.Layout.Row = 4;
    selectionPanel.Layout.Column = [1 4];

    sg = uigridlayout(selectionPanel,[2 6]);
    sg.RowHeight = {32,'1x'};
    sg.ColumnWidth = {90,120,90,120,'1x','1x'};
    sg.Padding = [16 10 16 10];
    sg.ColumnSpacing = 10;
    sg.BackgroundColor = theme.PanelBackground;

    uilabel(sg,'Text','Outage','HorizontalAlignment','right', ...
        'FontColor',theme.TextSecondary);
    outageDropDown = uidropdown(sg,'Items',string(s.outage_s), ...
        'Value',string(s.outage_s(outageIdx)));

    uilabel(sg,'Text','Q rate','HorizontalAlignment','right', ...
        'FontColor',theme.TextSecondary);
    rateDropDown = uidropdown(sg,'Items',string(s.rates_Hz), ...
        'Value',string(s.rates_Hz(rateIdx)));

    selectionTitle = uilabel(sg,'Text','SELECTED OPERATING POINT', ...
        'FontSize',10,'FontWeight','bold','FontColor',theme.TextMuted);
    selectionTitle.Layout.Column = [5 6];

    detail1 = uilabel(sg,'Text',sprintf('40 s / 2 Hz  |  Mean reduction %.1f%%', ...
        s.meanReduction_pct(rateIdx,outageIdx)), ...
        'HorizontalAlignment','center','FontWeight','bold','FontColor',theme.TextPrimary);
    detail1.Layout.Column = [1 2];

    detail2 = uilabel(sg,'Text',sprintf('P95 reduction %.1f%%  |  Runs improved %.0f%%', ...
        s.p95Reduction_pct(rateIdx,outageIdx),s.runsImproved_pct(rateIdx,outageIdx)), ...
        'HorizontalAlignment','center','FontColor',theme.TextSecondary);
    detail2.Layout.Column = [3 4];

    detail3 = uilabel(sg,'Text',sprintf('Position / velocity / heading RMSE: %.1f / %.1f / %.1f%%', ...
        s.positionRMSEreduction_pct(rateIdx,outageIdx), ...
        s.velocityRMSEreduction_pct(rateIdx,outageIdx), ...
        s.headingRMSEreduction_pct(rateIdx,outageIdx)), ...
        'HorizontalAlignment','center','FontColor',theme.TextSecondary);
    detail3.Layout.Column = [5 6];

    handles.Panel = panel;
    handles.MetricDropDown = metricDropDown;
    handles.OutageDropDown = outageDropDown;
    handles.RateDropDown = rateDropDown;
    handles.CardMean = cardMean;
    handles.CardP95 = cardP95;
    handles.CardRuns = cardRuns;
    handles.CardNIS = cardNIS;
    handles.LineAxes = lineAx;
    handles.ClassicalLine = lineClassical;
    handles.RateLines = rateLines;
    handles.SelectedPoint = selectedPoint;
    handles.HeatAxes = heatAx;
    handles.HeatImage = heatImage;
    handles.Detail1 = detail1;
    handles.Detail2 = detail2;
    handles.Detail3 = detail3;
    handles.LoadButton = loadButton;
    handles.LoadStatus = loadStatus;
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

function m = blueMap(n)
    a = [0.96 0.98 1.00];
    b = [0.15 0.39 0.82];
    u = linspace(0,1,n).';
    m = a.*(1-u) + b.*u;
end
