function handles = build_evidence_page(parent, theme)
%BUILD_EVIDENCE_PAGE Build final evidence/export and regression page.

    panel = uipanel(parent,'BorderType','none','BackgroundColor',theme.Background);
    panel.Layout.Row = 1;
    panel.Layout.Column = 1;

    grid = uigridlayout(panel,[5 2]);
    grid.RowHeight = {58,112,122,165,'1x'};
    grid.ColumnWidth = {'1x','1x'};
    grid.RowSpacing = 12;
    grid.ColumnSpacing = 14;
    grid.Padding = [24 18 24 18];
    grid.BackgroundColor = theme.Background;

    pageTitle = uilabel(grid,'Text','Evidence & Validation','FontSize',22, ...
        'FontWeight','bold','FontColor',theme.TextPrimary);
    pageTitle.Layout.Row = 1; pageTitle.Layout.Column = 1;

    hint = uilabel(grid,'Text','Regression check and reproducible evidence export', ...
        'HorizontalAlignment','right','FontSize',11,'FontColor',theme.TextMuted);
    hint.Layout.Row = 1; hint.Layout.Column = 2;

    sourcePanel = uipanel(grid,'BorderType','line','BorderColor',theme.Border, ...
        'BackgroundColor',theme.PanelBackground);
    sourcePanel.Layout.Row = 2; sourcePanel.Layout.Column = [1 2];

    sg = uigridlayout(sourcePanel,[2 3]);
    sg.RowHeight = {28,'1x'};
    sg.ColumnWidth = {'1x','1x','1x'};
    sg.Padding = [16 12 16 12];
    sg.BackgroundColor = theme.PanelBackground;

    h = uilabel(sg,'Text','DATA SOURCES','FontSize',10,'FontWeight','bold', ...
        'FontColor',theme.TextMuted);
    h.Layout.Column = [1 3];

    singleRunSource = uilabel(sg,'Text','Single-run: Phase 7B repository result', ...
        'HorizontalAlignment','center','FontWeight','bold','FontColor',theme.Success);

    monteCarloSource = uilabel(sg,'Text','Monte Carlo: published Phase 7C paired runs', ...
        'HorizontalAlignment','center','FontWeight','bold','FontColor',theme.Success);

    sensitivitySource = uilabel(sg,'Text','Sensitivity: published Phase 7D summary', ...
        'HorizontalAlignment','center','FontWeight','bold','FontColor',theme.Success);

    testPanel = uipanel(grid,'BorderType','line','BorderColor',theme.Border, ...
        'BackgroundColor',theme.PanelBackground);
    testPanel.Layout.Row = 3; testPanel.Layout.Column = [1 2];

    tg = uigridlayout(testPanel,[2 3]);
    tg.RowHeight = {32,'1x'};
    tg.ColumnWidth = {'1x',190,'1x'};
    tg.Padding = [16 12 16 12];
    tg.BackgroundColor = theme.PanelBackground;

    selfTestStatus = uilabel(tg,'Text','Self-test not run in this session.', ...
        'HorizontalAlignment','center','FontSize',11,'FontColor',theme.TextSecondary);
    selfTestStatus.Layout.Row = 1;
    selfTestStatus.Layout.Column = [1 3];

    selfTestButton = uibutton(tg,'push','Text','Run Dashboard Self-Test', ...
        'BackgroundColor',theme.PanelBackground,'FontColor',theme.TextPrimary, ...
        'FontWeight','bold');
    selfTestButton.Layout.Row = 2; selfTestButton.Layout.Column = 2;

    exportPanel = uipanel(grid,'BorderType','line','BorderColor',theme.Border, ...
        'BackgroundColor',theme.PanelBackground);
    exportPanel.Layout.Row = 4; exportPanel.Layout.Column = [1 2];

    eg = uigridlayout(exportPanel,[3 3]);
    eg.RowHeight = {34,42,'1x'};
    eg.ColumnWidth = {'1x',230,'1x'};
    eg.Padding = [16 14 16 14];
    eg.BackgroundColor = theme.PanelBackground;

    status = uilabel(eg,'Text','No evidence package exported in this session.', ...
        'HorizontalAlignment','center','FontSize',11,'FontColor',theme.TextSecondary);
    status.Layout.Row = 1; status.Layout.Column = [1 3];

    exportButton = uibutton(eg,'push','Text','Export Evidence Package', ...
        'BackgroundColor',theme.Accent,'FontColor',[1 1 1],'FontWeight','bold');
    exportButton.Layout.Row = 2; exportButton.Layout.Column = 2;

    pathLabel = uilabel(eg,'Text','', ...
        'HorizontalAlignment','center','FontSize',10,'FontColor',theme.TextMuted, ...
        'WordWrap','on');
    pathLabel.Layout.Row = 3; pathLabel.Layout.Column = [1 3];

    note = uilabel(grid,'Text', ...
        ['v1.0 starts from saved OpenNavLab repository outputs: Phase 7B single-run, ' ...
         'Phase 7C paired Monte Carlo and Phase 7D sensitivity results. ' ...
         'Mission preview mode is explicitly non-production. Evidence export never reruns an estimator.'], ...
        'FontSize',10,'FontColor',theme.TextMuted,'WordWrap','on');
    note.Layout.Row = 5; note.Layout.Column = [1 2];

    handles.Panel = panel;
    handles.ExportButton = exportButton;
    handles.Status = status;
    handles.PathLabel = pathLabel;
    handles.SelfTestButton = selfTestButton;
    handles.SelfTestStatus = selfTestStatus;
    handles.SingleRunSource = singleRunSource;
    handles.MonteCarloSource = monteCarloSource;
    handles.SensitivitySource = sensitivitySource;
end
