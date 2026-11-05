function handles = build_quantum_page(parent, theme, data)
%BUILD_QUANTUM_PAGE Quantum aiding and consistency analysis.

    panel = uipanel(parent,'BorderType','none','BackgroundColor',theme.Background);
    panel.Layout.Row = 1;
    panel.Layout.Column = 1;

    grid = uigridlayout(panel,[5 3]);
    grid.RowHeight = {54,78,'1x','1x','1x'};
    grid.ColumnWidth = {'1x','1x','1x'};
    grid.RowSpacing = 10;
    grid.ColumnSpacing = 12;
    grid.Padding = [24 16 24 16];
    grid.BackgroundColor = theme.Background;

    title = uilabel(grid,'Text','Quantum Analysis','FontSize',22, ...
        'FontWeight','bold','FontColor',theme.TextPrimary);
    title.Layout.Row = 1;
    title.Layout.Column = [1 2];

    hint = uilabel(grid,'Text','Bias-reference tracking and innovation consistency', ...
        'HorizontalAlignment','right','FontSize',11,'FontColor',theme.TextMuted);
    hint.Layout.Row = 1;
    hint.Layout.Column = 3;

    gpsMean = mean(data.nis.gps,'omitnan');
    qMean = mean(data.nis.quantum,'omitnan');
    qCount = sum(data.quantum.updateMask);

    cardRate = create_kpi_card(grid,theme,'Quantum rate', ...
        sprintf('%g Hz',data.meta.quantumRate_Hz), ...
        sprintf('%d update events',qCount));
    cardRate.Panel.Layout.Row = 2; cardRate.Panel.Layout.Column = 1;

    cardGPS = create_kpi_card(grid,theme,'GPS NIS mean', ...
        formatMetricSafe(gpsMean), ...
        sprintf('Expected %.0f',data.nis.gpsExpected));
    cardGPS.Panel.Layout.Row = 2; cardGPS.Panel.Layout.Column = 2;

    cardQ = create_kpi_card(grid,theme,'Quantum NIS mean', ...
        formatMetricSafe(qMean), ...
        sprintf('Expected %.0f',data.nis.quantumExpected));
    cardQ.Panel.Layout.Row = 2; cardQ.Panel.Layout.Column = 3;

    [p1,ax1] = makePanel(grid,3,[1 3],theme,'Accelerometer bias X','Bias [m/s^2]');
    true1 = plot(ax1,data.time,data.bias.true.accel_x_mps2,'Color',theme.Truth,'LineWidth',1.2);
    c1 = plot(ax1,data.time,data.bias.classical.accel_x_mps2,'Color',theme.Classical,'LineWidth',1.2);
    q1 = plot(ax1,data.time,data.bias.quantum.accel_x_mps2,'Color',theme.Quantum,'LineWidth',1.2);
    legend(ax1,{'True','Classical estimate','Quantum-aided estimate'},'Box','off','Location','best');

    [p2,ax2] = makePanel(grid,4,[1 3],theme,'Gyroscope bias Z','Bias [deg/s]');
    true2 = plot(ax2,data.time,rad2deg(data.bias.true.gyro_z_rps),'Color',theme.Truth,'LineWidth',1.2);
    c2 = plot(ax2,data.time,rad2deg(data.bias.classical.gyro_z_rps),'Color',theme.Classical,'LineWidth',1.2);
    q2 = plot(ax2,data.time,rad2deg(data.bias.quantum.gyro_z_rps),'Color',theme.Quantum,'LineWidth',1.2);
    legend(ax2,{'True','Classical estimate','Quantum-aided estimate'},'Box','off','Location','best');

    [p3,ax3] = makePanel(grid,5,[1 3],theme,'Innovation consistency','NIS');
    gpsN = plot(ax3,data.time,data.nis.gps,'.','Color',theme.Classical,'MarkerSize',7);
    qN = plot(ax3,data.time,data.nis.quantum,'.','Color',theme.Quantum,'MarkerSize',7);
    gpsExpected = yline(ax3,data.nis.gpsExpected,'--','GPS expected','Color',theme.Classical);
    qExpected = yline(ax3,data.nis.quantumExpected,'--','Quantum expected','Color',theme.Quantum);
    legend(ax3,{'GPS NIS','Quantum NIS'},'Box','off','Location','best');

    handles.Panel = panel;
    handles.CardRate = cardRate;
    handles.CardGPS = cardGPS;
    handles.CardQuantum = cardQ;

    handles.BiasXAxes = ax1;
    handles.BiasXTrue = true1;
    handles.BiasXClassical = c1;
    handles.BiasXQuantum = q1;

    handles.GyroAxes = ax2;
    handles.GyroTrue = true2;
    handles.GyroClassical = c2;
    handles.GyroQuantum = q2;

    handles.NISAxes = ax3;
    handles.GPSNIS = gpsN;
    handles.QuantumNIS = qN;
    handles.GPSExpected = gpsExpected;
    handles.QuantumExpected = qExpected;
end

function [panel,ax] = makePanel(grid,row,col,theme,titleText,yLabel)
    panel = uipanel(grid,'BorderType','line','BorderColor',theme.Border, ...
        'BackgroundColor',theme.PanelBackground);
    panel.Layout.Row = row;
    panel.Layout.Column = col;

    pg = uigridlayout(panel,[1 1]);
    pg.Padding = [10 8 10 6];
    pg.BackgroundColor = theme.PanelBackground;

    ax = uiaxes(pg);
    ax.Color = theme.PanelBackground;
    ax.XColor = theme.TextMuted;
    ax.YColor = theme.TextMuted;
    ax.GridColor = theme.Border;
    ax.XGrid = 'on'; ax.YGrid = 'on'; ax.Box = 'off';
    hold(ax,'on');
    title(ax,titleText,'FontWeight','bold');
    ylabel(ax,yLabel);
    xlabel(ax,'Time [s]');
end

function txt = formatMetricSafe(v)
    if isnan(v)
        txt = '--';
    else
        txt = sprintf('%.3f',v);
    end
end
