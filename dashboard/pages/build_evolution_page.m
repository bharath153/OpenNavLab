function handles = build_evolution_page(parent, theme, evolution)
%BUILD_EVOLUTION_PAGE Cross-phase project progression without mixing metrics.

    metricItems = {'Position RMSE','Velocity RMSE','Heading RMSE','Maximum Outage Error'};
    defaultMetric = metricItems{1};
    [vals,unit,metricLabel] = getEvolutionMetric(evolution,defaultMetric);

    panel = uipanel(parent,'BorderType','none','BackgroundColor',theme.Background);
    panel.Layout.Row = 1;
    panel.Layout.Column = 1;

    grid = uigridlayout(panel,[4 4]);
    grid.RowHeight = {54,92,'1x',150};
    grid.ColumnWidth = {'1x','1x','1x','1x'};
    grid.RowSpacing = 10;
    grid.ColumnSpacing = 12;
    grid.Padding = [24 16 24 16];
    grid.BackgroundColor = theme.Background;

    pageTitle = uilabel(grid,'Text','Project Evolution','FontSize',22, ...
        'FontWeight','bold','FontColor',theme.TextPrimary);
    pageTitle.Layout.Row = 1;
    pageTitle.Layout.Column = [1 2];

    controlPanel = uipanel(grid,'BorderType','none','BackgroundColor',theme.Background);
    controlPanel.Layout.Row = 1;
    controlPanel.Layout.Column = [3 4];
    cg = uigridlayout(controlPanel,[1 2]);
    cg.ColumnWidth = {105,'1x'};
    cg.Padding = [0 4 0 0];
    cg.BackgroundColor = theme.Background;
    uilabel(cg,'Text','Metric','HorizontalAlignment','right', ...
        'FontSize',10,'FontColor',theme.TextSecondary);
    metricDropDown = uidropdown(cg,'Items',metricItems,'Value',defaultMetric);

    c1 = create_kpi_card(grid,theme,'DR -> Classical', ...
        sprintf('%.1f %%',evolution.reductions.drToClassicalPosition_pct), ...
        'Position RMSE reduction');
    c1.Panel.Layout.Row=2; c1.Panel.Layout.Column=1;

    c2 = create_kpi_card(grid,theme,'Classical -> Quantum', ...
        sprintf('%.1f %%',evolution.reductions.classicalToQuantumPosition_pct), ...
        'Position RMSE reduction');
    c2.Panel.Layout.Row=2; c2.Panel.Layout.Column=2;

    c3 = create_kpi_card(grid,theme,'Single-run outage gain', ...
        sprintf('%.1f %%',evolution.reductions.singleRunMaxOutage_pct), ...
        'Phase 5 -> Phase 7B');
    c3.Panel.Layout.Row=2; c3.Panel.Layout.Column=3;

    c4 = create_kpi_card(grid,theme,'40 s / 2 Hz ensemble', ...
        sprintf('%.1f %%',evolution.phase7d.meanReduction_pct), ...
        'Mean max-error reduction');
    c4.Panel.Layout.Row=2; c4.Panel.Layout.Column=4;
    c4.Value.FontColor = theme.Quantum;

    chartPanel = uipanel(grid,'BorderType','line','BorderColor',theme.Border, ...
        'BackgroundColor',theme.PanelBackground);
    chartPanel.Layout.Row=3; chartPanel.Layout.Column=[1 2];
    pg = uigridlayout(chartPanel,[1 1]);
    pg.Padding=[12 10 12 8]; pg.BackgroundColor=theme.PanelBackground;
    ax = uiaxes(pg);
    ax.Color=theme.PanelBackground; ax.XColor=theme.TextMuted; ax.YColor=theme.TextMuted;
    ax.GridColor=theme.Border; ax.YGrid='on'; ax.Box='off';
    barObj = bar(ax,vals,0.58,'FaceColor',theme.Classical,'EdgeColor','none');
    ax.XTick = 1:numel(evolution.singleRun.phaseNames);
    ax.XTickLabel = evolution.singleRun.phaseNames;
    ax.XTickLabelRotation = 10;
    ylabel(ax,unit);
    title(ax,[metricLabel ' across comparable single-run phases'],'FontWeight','bold');

    pathPanel = uipanel(grid,'BorderType','line','BorderColor',theme.Border, ...
        'BackgroundColor',theme.PanelBackground);
    pathPanel.Layout.Row=3; pathPanel.Layout.Column=[3 4];
    rg = uigridlayout(pathPanel,[5 2]);
    rg.RowHeight={30,'1x','1x','1x','1x'};
    rg.ColumnWidth={110,'1x'};
    rg.Padding=[16 12 16 12]; rg.RowSpacing=7; rg.BackgroundColor=theme.PanelBackground;
    hdr=uilabel(rg,'Text','RESEARCH PROGRESSION','FontSize',10,'FontWeight','bold','FontColor',theme.TextMuted);
    hdr.Layout.Column=[1 2];
    addStep(rg,'Phase 3','MEMS dead reckoning','Quantify unbounded inertial drift',theme);
    addStep(rg,'Phase 5','Classical GPS/MEMS EKF','Establish corrected baseline',theme);
    addStep(rg,'Phase 7B','Quantum-aided EKF','Add low-rate bias-reference correction',theme);
    addStep(rg,'Phase 7D','Paired sensitivity study','Quantify benefit vs outage and update rate',theme);

    statPanel = uipanel(grid,'BorderType','line','BorderColor',theme.Border, ...
        'BackgroundColor',theme.PanelBackground);
    statPanel.Layout.Row=4; statPanel.Layout.Column=[1 4];
    sg=uigridlayout(statPanel,[2 5]);
    sg.RowHeight={30,'1x'};
    sg.ColumnWidth={130,'1x','1x','1x','1x'};
    sg.Padding=[16 10 16 10]; sg.ColumnSpacing=12; sg.BackgroundColor=theme.PanelBackground;
    h=uilabel(sg,'Text','PHASE 7D - SEPARATE ENSEMBLE RESULT','FontSize',10,'FontWeight','bold','FontColor',theme.TextMuted);
    h.Layout.Column=[1 5];
    uilabel(sg,'Text','40 s outage / 2 Hz','FontWeight','bold','FontColor',theme.TextPrimary);
    uilabel(sg,'Text',sprintf('Mean max: %.3f -> %.3f m',evolution.phase7d.classicalMeanMax_m,evolution.phase7d.quantumMeanMax_m),'FontColor',theme.TextSecondary);
    uilabel(sg,'Text',sprintf('P95: %.3f -> %.3f m',evolution.phase7d.classicalP95_m,evolution.phase7d.quantumP95_m),'FontColor',theme.TextSecondary);
    uilabel(sg,'Text',sprintf('P95 reduction: %.1f%%',evolution.phase7d.p95Reduction_pct),'FontColor',theme.TextSecondary);
    uilabel(sg,'Text',sprintf('Runs improved: %.0f%%',evolution.phase7d.runsImproved_pct),'FontWeight','bold','FontColor',theme.Quantum);

    handles.Panel=panel;
    handles.MetricDropDown=metricDropDown;
    handles.Axes=ax;
    handles.Bar=barObj;
end

function addStep(grid,phase,name,desc,theme)
    uilabel(grid,'Text',phase,'FontWeight','bold','FontColor',theme.AccentDark);
    box=uigridlayout(grid,[2 1]); box.RowHeight={18,'1x'}; box.Padding=[0 0 0 0]; box.RowSpacing=0; box.BackgroundColor=theme.PanelBackground;
    uilabel(box,'Text',name,'FontWeight','bold','FontColor',theme.TextPrimary);
    uilabel(box,'Text',desc,'FontSize',9,'FontColor',theme.TextSecondary);
end

function [v,u,l] = getEvolutionMetric(evolution,selection)
    switch char(selection)
        case 'Position RMSE'
            v=evolution.singleRun.positionRMSE_m; u='Position RMSE [m]'; l='Position RMSE';
        case 'Velocity RMSE'
            v=evolution.singleRun.velocityRMSE_mps; u='Velocity RMSE [m/s]'; l='Velocity RMSE';
        case 'Heading RMSE'
            v=evolution.singleRun.headingRMSE_deg; u='Heading RMSE [deg]'; l='Heading RMSE';
        case 'Maximum Outage Error'
            v=evolution.singleRun.maxOutageError_m; u='Maximum outage error [m]'; l='Maximum outage error';
        otherwise
            error('Unknown evolution metric: %s',char(selection));
    end
end
