function handles = build_replay_page(parent, theme, data, metrics)
%BUILD_REPLAY_PAGE Create the interactive trajectory replay page.

    panel = uipanel(parent,'BorderType','none','BackgroundColor',theme.Background);
    panel.Layout.Row = 1;
    panel.Layout.Column = 1;

    grid = uigridlayout(panel,[4 4]);
    grid.RowHeight = {54,'1x',110,64};
    grid.ColumnWidth = {'1x','1x',240,240};
    grid.RowSpacing = 12;
    grid.ColumnSpacing = 12;
    grid.Padding = [24 20 24 16];
    grid.BackgroundColor = theme.Background;

    title = uilabel(grid,'Text','Navigation Replay','FontSize',22, ...
        'FontWeight','bold','FontColor',theme.TextPrimary);
    title.Layout.Row = 1; title.Layout.Column = [1 2];

    gpsBadge = uilabel(grid,'Text','GPS AVAILABLE','HorizontalAlignment','center', ...
        'FontWeight','bold','FontSize',10,'FontColor',theme.Success, ...
        'BackgroundColor',theme.SuccessBackground);
    gpsBadge.Layout.Row = 1; gpsBadge.Layout.Column = 3;

    quantumBadge = uilabel(grid,'Text',sprintf('QUANTUM %g Hz',data.meta.quantumRate_Hz), ...
        'HorizontalAlignment','center','FontWeight','bold','FontSize',10, ...
        'FontColor',theme.Accent,'BackgroundColor',theme.AccentSoft);
    quantumBadge.Layout.Row = 1; quantumBadge.Layout.Column = 4;

    plotPanel = uipanel(grid,'BorderType','line','BorderColor',theme.Border, ...
        'BackgroundColor',theme.PanelBackground);
    plotPanel.Layout.Row = 2; plotPanel.Layout.Column = [1 2];

    pg = uigridlayout(plotPanel,[1 1]);
    pg.Padding = [12 12 12 12];
    pg.BackgroundColor = theme.PanelBackground;

    ax = uiaxes(pg);
    ax.Color = theme.PanelBackground;
    ax.XColor = theme.TextMuted;
    ax.YColor = theme.TextMuted;
    ax.GridColor = theme.Border;
    ax.XGrid = 'on'; ax.YGrid = 'on'; ax.Box = 'off';
    ax.DataAspectRatio = [1 1 1];
    xlabel(ax,'East / x [m]'); ylabel(ax,'North / y [m]');
    hold(ax,'on');

    plot(ax,data.truth.position(:,1),data.truth.position(:,2),'-', ...
        'Color',[0.80 0.81 0.83],'LineWidth',1.0);

    truthTrace = plot(ax,nan,nan,'-','Color',theme.Truth,'LineWidth',1.5);
    classicalTrace = plot(ax,nan,nan,'-','Color',theme.Classical,'LineWidth',1.8);
    quantumTrace = plot(ax,nan,nan,'-','Color',theme.Quantum,'LineWidth',1.8);

    truthMarker = plot(ax,nan,nan,'o','MarkerSize',7, ...
        'MarkerFaceColor',theme.Truth,'MarkerEdgeColor',theme.Truth);
    classicalMarker = plot(ax,nan,nan,'o','MarkerSize',6, ...
        'MarkerFaceColor',theme.Classical,'MarkerEdgeColor',theme.Classical);
    quantumMarker = plot(ax,nan,nan,'o','MarkerSize',6, ...
        'MarkerFaceColor',theme.Quantum,'MarkerEdgeColor',theme.Quantum);

    legend(ax,{'Full truth','Truth replay','Classical EKF','Quantum-aided EKF'}, ...
        'Location','best','Box','off');

    metricsPanel = uipanel(grid,'BorderType','line','BorderColor',theme.Border, ...
        'BackgroundColor',theme.PanelBackground);
    metricsPanel.Layout.Row = 2; metricsPanel.Layout.Column = [3 4];

    mg = uigridlayout(metricsPanel,[8 2]);
    mg.RowHeight = {30,28,28,14,28,28,14,'1x'};
    mg.ColumnWidth = {'1x','1x'};
    mg.Padding = [18 16 18 14];
    mg.RowSpacing = 5; mg.ColumnSpacing = 10;
    mg.BackgroundColor = theme.PanelBackground;

    liveTitle = uilabel(mg,'Text','Live estimator state','FontSize',13, ...
        'FontWeight','bold','FontColor',theme.TextPrimary);
    liveTitle.Layout.Column = [1 2];

    uilabel(mg,'Text','Classical position error','FontSize',10,'FontColor',theme.TextSecondary);
    classicalError = uilabel(mg,'Text','--','HorizontalAlignment','right', ...
        'FontSize',13,'FontWeight','bold','FontColor',theme.Classical);

    uilabel(mg,'Text','Quantum position error','FontSize',10,'FontColor',theme.TextSecondary);
    quantumError = uilabel(mg,'Text','--','HorizontalAlignment','right', ...
        'FontSize',13,'FontWeight','bold','FontColor',theme.Quantum);

    spacer1 = uilabel(mg,'Text',''); spacer1.Layout.Column = [1 2];

    uilabel(mg,'Text','Current improvement','FontSize',10,'FontColor',theme.TextSecondary);
    currentImprovement = uilabel(mg,'Text','--','HorizontalAlignment','right', ...
        'FontSize',13,'FontWeight','bold','FontColor',theme.TextPrimary);

    uilabel(mg,'Text','Playback time','FontSize',10,'FontColor',theme.TextSecondary);
    timeLabel = uilabel(mg,'Text',sprintf('%.2f s',data.time(1)), ...
        'HorizontalAlignment','right','FontSize',13,'FontWeight','bold', ...
        'FontColor',theme.TextPrimary);

    spacer2 = uilabel(mg,'Text',''); spacer2.Layout.Column = [1 2];

    note = uilabel(mg,'Text',sprintf( ...
        'Reference: classical max %.2f m, quantum %.2f m (%.1f%% reduction).', ...
        metrics.classicalMaxOutageError_m,metrics.quantumMaxOutageError_m, ...
        metrics.maxOutageReduction_pct), ...
        'FontSize',10,'FontColor',theme.TextMuted,'WordWrap','on');
    note.Layout.Column = [1 2];

    timelinePanel = uipanel(grid,'BorderType','line','BorderColor',theme.Border, ...
        'BackgroundColor',theme.PanelBackground);
    timelinePanel.Layout.Row = 3; timelinePanel.Layout.Column = [1 4];

    tg = uigridlayout(timelinePanel,[3 4]);
    tg.RowHeight = {20,38,24};
    tg.ColumnWidth = {85,'1x',160,110};
    tg.Padding = [14 8 14 8];
    tg.RowSpacing = 2; tg.ColumnSpacing = 10;
    tg.BackgroundColor = theme.PanelBackground;

    uilabel(tg,'Text','Timeline','FontSize',10,'FontWeight','bold', ...
        'FontColor',theme.TextSecondary);

    outageLabel = uilabel(tg,'Text',sprintf('GPS outage: %.1f-%.1f s', ...
        metrics.outageStart_s,metrics.outageEnd_s), ...
        'HorizontalAlignment','center','FontSize',10,'FontColor',theme.Error);
    outageLabel.Layout.Column = 2;

    hint = uilabel(tg,'Text','Drag to seek','HorizontalAlignment','right', ...
        'FontSize',9,'FontColor',theme.TextMuted);
    hint.Layout.Column = [3 4];

    timeCaption = uilabel(tg,'Text','t = 0.00 s','FontSize',10, ...
        'FontColor',theme.TextSecondary);

    timeSlider = uislider(tg,'Limits',[data.time(1),data.time(end)], ...
        'Value',data.time(1), ...
        'MajorTicks',[data.time(1),metrics.outageStart_s,metrics.outageEnd_s,data.time(end)], ...
        'MajorTickLabels',{sprintf('%.0f',data.time(1)), ...
                           sprintf('%.0f',metrics.outageStart_s), ...
                           sprintf('%.0f',metrics.outageEnd_s), ...
                           sprintf('%.0f',data.time(end))});
    timeSlider.Layout.Column = [2 4];

    stateText = uilabel(tg,'Text','GPS AVAILABLE','FontSize',9, ...
        'FontWeight','bold','FontColor',theme.Success);
    stateText.Layout.Column = 2;

    qHint = uilabel(tg,'Text','Quantum update events pulse in the header badge.', ...
        'HorizontalAlignment','right','FontSize',9,'FontColor',theme.TextMuted);
    qHint.Layout.Column = [3 4];

    controls = uipanel(grid,'BorderType','none','BackgroundColor',theme.Background);
    controls.Layout.Row = 4; controls.Layout.Column = [1 4];

    cg = uigridlayout(controls,[1 7]);
    cg.ColumnWidth = {'1x',90,110,90,90,110,'1x'};
    cg.Padding = [0 6 0 0]; cg.ColumnSpacing = 8;
    cg.BackgroundColor = theme.Background;

    uilabel(cg,'Text','');

    resetButton = uibutton(cg,'push','Text','Reset', ...
        'BackgroundColor',theme.PanelBackground,'FontColor',theme.TextSecondary);

    playPauseButton = uibutton(cg,'push','Text','Play', ...
        'BackgroundColor',theme.Accent,'FontColor',[1 1 1],'FontWeight','bold');

    uilabel(cg,'Text','Speed','HorizontalAlignment','right', ...
        'FontSize',10,'FontColor',theme.TextSecondary);

    speedDropDown = uidropdown(cg,'Items',{'0.5x','1x','2x','5x'},'Value','1x');

    uilabel(cg,'Text','REPLAY MODE','HorizontalAlignment','center', ...
        'FontSize',9,'FontWeight','bold','FontColor',theme.Accent, ...
        'BackgroundColor',theme.AccentSoft);

    uilabel(cg,'Text','');

    handles.Panel = panel;
    handles.Axes = ax;
    handles.TruthTrace = truthTrace;
    handles.ClassicalTrace = classicalTrace;
    handles.QuantumTrace = quantumTrace;
    handles.TruthMarker = truthMarker;
    handles.ClassicalMarker = classicalMarker;
    handles.QuantumMarker = quantumMarker;
    handles.GPSBadge = gpsBadge;
    handles.QuantumBadge = quantumBadge;
    handles.ClassicalError = classicalError;
    handles.QuantumError = quantumError;
    handles.CurrentImprovement = currentImprovement;
    handles.TimeLabel = timeLabel;
    handles.TimeCaption = timeCaption;
    handles.TimeSlider = timeSlider;
    handles.StateText = stateText;
    handles.OutageLabel = outageLabel;
    handles.ReferenceNote = note;
    handles.ResetButton = resetButton;
    handles.PlayPauseButton = playPauseButton;
    handles.SpeedDropDown = speedDropDown;
end
