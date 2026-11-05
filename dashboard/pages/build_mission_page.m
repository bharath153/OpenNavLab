function handles = build_mission_page(parent, theme, data, metrics)
%BUILD_MISSION_PAGE Build demo-scenario configuration page.

    panel = uipanel(parent,'BorderType','none','BackgroundColor',theme.Background);
    panel.Layout.Row = 1;
    panel.Layout.Column = 1;

    grid = uigridlayout(panel,[4 3]);
    grid.RowHeight = {58,210,150,'1x'};
    grid.ColumnWidth = {'1x','1x','1x'};
    grid.RowSpacing = 14;
    grid.ColumnSpacing = 14;
    grid.Padding = [24 20 24 20];
    grid.BackgroundColor = theme.Background;

    title = uilabel(grid,'Text','Mission','FontSize',22, ...
        'FontWeight','bold','FontColor',theme.TextPrimary);
    title.Layout.Row = 1;
    title.Layout.Column = [1 2];

    hint = uilabel(grid,'Text','Reference run plus optional what-if visualization', ...
        'HorizontalAlignment','right','FontSize',11,'FontColor',theme.TextMuted);
    hint.Layout.Row = 1;
    hint.Layout.Column = 3;

    simPanel = uipanel(grid,'BorderType','line','BorderColor',theme.Border, ...
        'BackgroundColor',theme.PanelBackground);
    simPanel.Layout.Row = 2;
    simPanel.Layout.Column = 1;

    sg = uigridlayout(simPanel,[5 2]);
    sg.RowHeight = {28,30,30,30,'1x'};
    sg.ColumnWidth = {'1x',100};
    sg.Padding = [16 14 16 14];
    sg.BackgroundColor = theme.PanelBackground;

    header = uilabel(sg,'Text','SIMULATION','FontSize',10,'FontWeight','bold', ...
        'FontColor',theme.TextMuted);
    header.Layout.Column = [1 2];

    uilabel(sg,'Text','Duration','FontColor',theme.TextSecondary);
    duration = uieditfield(sg,'numeric','Value',data.time(end),'Enable','off');

    uilabel(sg,'Text','IMU rate','FontColor',theme.TextSecondary);
    imuRate = uieditfield(sg,'numeric','Value',data.meta.imuRate_Hz,'Enable','off');

    uilabel(sg,'Text','GPS rate','FontColor',theme.TextSecondary);
    gpsRate = uieditfield(sg,'numeric','Value',data.meta.gpsRate_Hz,'Enable','off');

    info = uilabel(sg,'Text','Reference-run simulation rates are read from the Phase 7B result.', ...
        'WordWrap','on','FontSize',10,'FontColor',theme.TextMuted);
    info.Layout.Column = [1 2];

    gpsPanel = uipanel(grid,'BorderType','line','BorderColor',theme.Border, ...
        'BackgroundColor',theme.PanelBackground);
    gpsPanel.Layout.Row = 2;
    gpsPanel.Layout.Column = 2;

    gg = uigridlayout(gpsPanel,[5 2]);
    gg.RowHeight = {28,32,32,32,'1x'};
    gg.ColumnWidth = {'1x',110};
    gg.Padding = [16 14 16 14];
    gg.BackgroundColor = theme.PanelBackground;

    header = uilabel(gg,'Text','GPS DENIAL','FontSize',10,'FontWeight','bold', ...
        'FontColor',theme.TextMuted);
    header.Layout.Column = [1 2];

    uilabel(gg,'Text','Start time [s]','FontColor',theme.TextSecondary);
    outageStart = uieditfield(gg,'numeric','Value',metrics.outageStart_s, ...
        'Limits',[0 120]);

    uilabel(gg,'Text','Duration [s]','FontColor',theme.TextSecondary);
    outageDuration = uieditfield(gg,'numeric','Value',metrics.outageDuration_s, ...
        'Limits',[0 70]);

    uilabel(gg,'Text','End time [s]','FontColor',theme.TextSecondary);
    outageEnd = uieditfield(gg,'numeric','Value',metrics.outageEnd_s,'Enable','off');

    note = uilabel(gg,'Text','The end time is recomputed when Apply Scenario is pressed.', ...
        'WordWrap','on','FontSize',10,'FontColor',theme.TextMuted);
    note.Layout.Column = [1 2];

    qPanel = uipanel(grid,'BorderType','line','BorderColor',theme.Border, ...
        'BackgroundColor',theme.PanelBackground);
    qPanel.Layout.Row = 2;
    qPanel.Layout.Column = 3;

    qg = uigridlayout(qPanel,[5 2]);
    qg.RowHeight = {28,32,32,32,'1x'};
    qg.ColumnWidth = {'1x',150};
    qg.Padding = [16 14 16 14];
    qg.BackgroundColor = theme.PanelBackground;

    header = uilabel(qg,'Text','QUANTUM AIDING','FontSize',10,'FontWeight','bold', ...
        'FontColor',theme.TextMuted);
    header.Layout.Column = [1 2];

    uilabel(qg,'Text','Enabled','FontColor',theme.TextSecondary);
    enabled = uicheckbox(qg,'Value',true,'Enable','off','Text','');

    uilabel(qg,'Text','Update rate [Hz]','FontColor',theme.TextSecondary);
    rate = uidropdown(qg,'Items',{'0.25','0.5','1','2'}, ...
        'Value',num2str(data.meta.quantumRate_Hz));

    uilabel(qg,'Text','Mode','FontColor',theme.TextSecondary);
    mode = uieditfield(qg,'text','Value','Bias-reference','Enable','off');

    note = uilabel(qg,'Text', ...
        'Preview scenarios visualize parameter changes; they do not rerun the EKFs.', ...
        'WordWrap','on','FontSize',10,'FontColor',theme.TextMuted);
    note.Layout.Column = [1 2];

    summaryPanel = uipanel(grid,'BorderType','line','BorderColor',theme.Border, ...
        'BackgroundColor',theme.PanelBackground);
    summaryPanel.Layout.Row = 3;
    summaryPanel.Layout.Column = [1 3];

    rg = uigridlayout(summaryPanel,[2 4]);
    rg.RowHeight = {30,'1x'};
    rg.ColumnWidth = {'1x','1x','1x',180};
    rg.Padding = [16 12 16 12];
    rg.BackgroundColor = theme.PanelBackground;

    summaryTitle = uilabel(rg,'Text','Scenario preview','FontSize',12, ...
        'FontWeight','bold','FontColor',theme.TextPrimary);
    summaryTitle.Layout.Column = [1 3];

    status = uilabel(rg,'Text','REFERENCE RUN','HorizontalAlignment','center', ...
        'FontSize',9,'FontWeight','bold','FontColor',theme.Success, ...
        'BackgroundColor',theme.SuccessBackground);
    status.Layout.Column = 4;

    previewGPS = uilabel(rg,'Text',sprintf('GPS denied from %.1f to %.1f s', ...
        metrics.outageStart_s,metrics.outageEnd_s), ...
        'FontSize',11,'FontColor',theme.TextSecondary);

    previewQuantum = uilabel(rg,'Text',sprintf('Quantum reference: %g Hz',data.meta.quantumRate_Hz), ...
        'FontSize',11,'FontColor',theme.TextSecondary);

    previewReduction = uilabel(rg,'Text',sprintf('Current max-error reduction: %.1f%%', ...
        metrics.maxOutageReduction_pct), ...
        'FontSize',11,'FontColor',theme.TextSecondary);

    buttonPanel = uipanel(grid,'BorderType','none','BackgroundColor',theme.Background);
    buttonPanel.Layout.Row = 4;
    buttonPanel.Layout.Column = [1 3];

    bg = uigridlayout(buttonPanel,[1 6]);
    bg.ColumnWidth = {'1x',150,160,160,180,'1x'};
    bg.Padding = [0 14 0 0];
    bg.ColumnSpacing = 10;
    bg.BackgroundColor = theme.Background;

    uilabel(bg,'Text','');

    restoreButton = uibutton(bg,'push','Text','Restore Reference', ...
        'BackgroundColor',theme.PanelBackground,'FontColor',theme.TextSecondary);

    applyButton = uibutton(bg,'push','Text','Apply Preview', ...
        'BackgroundColor',theme.Accent,'FontColor',[1 1 1],'FontWeight','bold');

    loadButton = uibutton(bg,'push','Text','Load MAT Results', ...
        'BackgroundColor',theme.PanelBackground,'FontColor',theme.TextSecondary);

    runHint = uilabel(bg,'Text','Then inspect Replay / Errors', ...
        'HorizontalAlignment','center','FontSize',10,'FontColor',theme.TextMuted);

    uilabel(bg,'Text','');

    handles.Panel = panel;
    handles.OutageStart = outageStart;
    handles.OutageDuration = outageDuration;
    handles.OutageEnd = outageEnd;
    handles.QuantumRate = rate;
    handles.ApplyButton = applyButton;
    handles.RestoreButton = restoreButton;
    handles.LoadButton = loadButton;
    handles.Status = status;
    handles.PreviewGPS = previewGPS;
    handles.PreviewQuantum = previewQuantum;
    handles.PreviewReduction = previewReduction;
end
