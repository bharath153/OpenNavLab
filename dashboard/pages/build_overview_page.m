function handles = build_overview_page(parent, theme, data, metrics)
%BUILD_OVERVIEW_PAGE Create the dashboard landing page.

    panel = uipanel(parent,'BorderType','none','BackgroundColor',theme.Background);
    panel.Layout.Row = 1;
    panel.Layout.Column = 1;

    grid = uigridlayout(panel,[4 4]);
    grid.RowHeight = {58,95,'1x',82};
    grid.ColumnWidth = {'1x','1x','1x','1x'};
    grid.RowSpacing = 14;
    grid.ColumnSpacing = 14;
    grid.Padding = [24 20 24 20];
    grid.BackgroundColor = theme.Background;

    title = uilabel(grid,'Text','Overview','FontSize',22, ...
        'FontWeight','bold','FontColor',theme.TextPrimary);
    title.Layout.Row = 1; title.Layout.Column = [1 3];

    hint = uilabel(grid,'Text','Scenario summary and animated navigation preview', ...
        'HorizontalAlignment','right','FontSize',11,'FontColor',theme.TextMuted);
    hint.Layout.Row = 1; hint.Layout.Column = 4;

    cardScenario = create_kpi_card(grid,theme,'Scenario', ...
        sprintf('%g s / %g Hz',metrics.outageDuration_s,data.meta.quantumRate_Hz), ...
        'GPS outage / quantum rate');
    cardScenario.Panel.Layout.Row = 2; cardScenario.Panel.Layout.Column = 1;

    cardClassical = create_kpi_card(grid,theme,'Classical max error', ...
        format_metric(metrics.classicalMaxOutageError_m,'m',2), ...
        'During selected outage');
    cardClassical.Panel.Layout.Row = 2; cardClassical.Panel.Layout.Column = 2;

    cardQuantum = create_kpi_card(grid,theme,'Quantum max error', ...
        format_metric(metrics.quantumMaxOutageError_m,'m',2), ...
        'During selected outage');
    cardQuantum.Panel.Layout.Row = 2; cardQuantum.Panel.Layout.Column = 3;

    cardGain = create_kpi_card(grid,theme,'Reduction', ...
        format_metric(metrics.maxOutageReduction_pct,'%',1), ...
        'Classical to quantum-aided');
    cardGain.Panel.Layout.Row = 2; cardGain.Panel.Layout.Column = 4;
    cardGain.Value.FontColor = theme.Quantum;

    plotPanel = uipanel(grid,'BorderType','line', ...
        'BorderColor',theme.Border,'BackgroundColor',theme.PanelBackground);
    plotPanel.Layout.Row = 3; plotPanel.Layout.Column = [1 4];

    pg = uigridlayout(plotPanel,[2 1]);
    pg.RowHeight = {28,'1x'};
    pg.Padding = [16 12 16 16];
    pg.RowSpacing = 4;
    pg.BackgroundColor = theme.PanelBackground;

    uilabel(pg,'Text','Navigation preview','FontSize',12, ...
        'FontWeight','bold','FontColor',theme.TextPrimary);

    ax = uiaxes(pg);
    ax.Color = theme.PanelBackground;
    ax.XColor = theme.TextMuted;
    ax.YColor = theme.TextMuted;
    ax.GridColor = theme.Border;
    ax.Box = 'off';
    ax.XGrid = 'on'; ax.YGrid = 'on';
    ax.DataAspectRatio = [1 1 1];
    xlabel(ax,'East / x [m]'); ylabel(ax,'North / y [m]');
    hold(ax,'on');

    plot(ax,data.truth.position(:,1),data.truth.position(:,2),'-', ...
        'Color',[0.82 0.83 0.85],'LineWidth',1.0);

    truthMarker = plot(ax,data.truth.position(1,1),data.truth.position(1,2),'o', ...
        'MarkerSize',7,'MarkerFaceColor',theme.Truth,'MarkerEdgeColor',theme.Truth);
    classicalMarker = plot(ax,data.classical.position(1,1),data.classical.position(1,2),'o', ...
        'MarkerSize',6,'MarkerFaceColor',theme.Classical,'MarkerEdgeColor',theme.Classical);
    quantumMarker = plot(ax,data.quantum.position(1,1),data.quantum.position(1,2),'o', ...
        'MarkerSize',6,'MarkerFaceColor',theme.Quantum,'MarkerEdgeColor',theme.Quantum);

    legend(ax,{'Truth path','Truth position','Classical','Quantum-aided'}, ...
        'Location','best','Box','off');

    actionPanel = uipanel(grid,'BorderType','none','BackgroundColor',theme.Background);
    actionPanel.Layout.Row = 4; actionPanel.Layout.Column = [1 4];

    ag = uigridlayout(actionPanel,[1 3]);
    ag.ColumnWidth = {'1x',220,'1x'};
    ag.Padding = [0 4 0 0];
    ag.BackgroundColor = theme.Background;

    uilabel(ag,'Text', ...
        'Use Replay to inspect estimator divergence, GPS denial, correction and recovery.', ...
        'FontSize',11,'FontColor',theme.TextSecondary);

    uilabel(ag,'Text','INTERACTIVE REPLAY READY', ...
        'HorizontalAlignment','center','FontSize',10,'FontWeight','bold', ...
        'FontColor',theme.Accent,'BackgroundColor',theme.AccentSoft);

    uilabel(ag,'Text','');

    handles.Panel = panel;
    handles.Axes = ax;
    handles.TruthMarker = truthMarker;
    handles.ClassicalMarker = classicalMarker;
    handles.QuantumMarker = quantumMarker;
    handles.CardScenario = cardScenario;
    handles.CardClassical = cardClassical;
    handles.CardQuantum = cardQuantum;
    handles.CardGain = cardGain;
end
