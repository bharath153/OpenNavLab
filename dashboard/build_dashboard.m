function app = build_dashboard(caseSource)
%BUILD_DASHBOARD Build the OpenNavLab Dashboard v1.0.2 UI.

    if nargin < 1
        caseSource = [];
    end

    dashboardVersion = '1.0.2';

    theme = dashboard_theme();
    data = load_dashboard_case(caseSource);
    metrics = compute_dashboard_metrics(data);

    % v1.0 starts from the repository's actual saved research artifacts.
    research = struct();
    research.mc = load_builtin_phase7c_results();
    research.sensitivity = load_builtin_phase7d_results();
    research.meta.monteCarloSource = 'Published OpenNavLab Phase 7C paired runs';
    research.meta.sensitivitySource = 'Published OpenNavLab Phase 7D sensitivity summary';
    research.meta.monteCarloIsProduction = true;
    research.meta.sensitivityIsProduction = true;

    evolution = create_phase_evolution_data();

    screenSize = get(groot, 'ScreenSize');
    figWidth = min(1440, max(1050, screenSize(3) - 80));
    figHeight = min(860, max(680, screenSize(4) - 100));
    figLeft = max(20, (screenSize(3) - figWidth)/2);
    figBottom = max(20, (screenSize(4) - figHeight)/2);

    fig = uifigure( ...
        'Name', 'OpenNavLab - Resilient Navigation Research Dashboard', ...
        'Tag', 'OpenNavLabDashboard', ...
        'Color', theme.Background, ...
        'Position', [figLeft figBottom figWidth figHeight], ...
        'Resize', 'on');

    fig.CloseRequestFcn = @(src,evt) close_dashboard(src);

    main = uigridlayout(fig, [3 2]);
    main.RowHeight = {72, '1x', 38};
    main.ColumnWidth = {180, '1x'};
    main.RowSpacing = 0;
    main.ColumnSpacing = 0;
    main.Padding = [0 0 0 0];
    main.BackgroundColor = theme.Background;

    header = uipanel(main, 'BorderType', 'none', ...
        'BackgroundColor', theme.PanelBackground);
    header.Layout.Row = 1;
    header.Layout.Column = [1 2];

    hg = uigridlayout(header, [1 3]);
    hg.ColumnWidth = {'1x', 180, 130};
    hg.Padding = [24 12 20 10];
    hg.ColumnSpacing = 12;
    hg.BackgroundColor = theme.PanelBackground;

    titleBox = uigridlayout(hg, [2 1]);
    titleBox.RowHeight = {30, 20};
    titleBox.Padding = [0 0 0 0];
    titleBox.RowSpacing = 0;
    titleBox.BackgroundColor = theme.PanelBackground;

    uilabel(titleBox, 'Text', 'OpenNavLab', 'FontSize', 24, ...
        'FontWeight', 'bold', 'FontColor', theme.TextPrimary);

    uilabel(titleBox, 'Text', 'Resilient Navigation Research Dashboard', ...
        'FontSize', 12, 'FontColor', theme.TextSecondary);

    scenarioLabel = uilabel(hg, ...
        'Text', sprintf('%g s outage  /  Q = %g Hz', ...
            metrics.outageDuration_s, data.meta.quantumRate_Hz), ...
        'HorizontalAlignment', 'center', 'FontSize', 12, ...
        'FontColor', theme.TextSecondary);

    validLabel = uilabel(hg, 'Text', 'UI VERIFIED', ...
        'HorizontalAlignment', 'center', 'FontSize', 11, ...
        'FontWeight', 'bold', 'FontColor', theme.Success, ...
        'BackgroundColor', theme.SuccessBackground);

    sidebar = uipanel(main, 'BorderType', 'none', ...
        'BackgroundColor', theme.SidebarBackground);
    sidebar.Layout.Row = 2;
    sidebar.Layout.Column = 1;

    sg = uigridlayout(sidebar, [12 1]);
    sg.RowHeight = {18,42,42,42,42,42,14,42,42,42,42,'1x'};
    sg.Padding = [12 18 12 12];
    sg.RowSpacing = 7;
    sg.BackgroundColor = theme.SidebarBackground;

    uilabel(sg, 'Text', 'WORKSPACE', 'FontSize', 9, ...
        'FontWeight', 'bold', 'FontColor', theme.TextMuted);

    navOverview = uibutton(sg,'push','Text','Overview','HorizontalAlignment','left');
    navReplay = uibutton(sg,'push','Text','Replay','HorizontalAlignment','left');
    navMission = uibutton(sg,'push','Text','Mission','HorizontalAlignment','left');
    navErrors = uibutton(sg,'push','Text','Errors','HorizontalAlignment','left');
    navEvolution = uibutton(sg,'push','Text','Evolution','HorizontalAlignment','left');
    uilabel(sg,'Text','');
    navQuantum = uibutton(sg,'push','Text','Quantum','HorizontalAlignment','left');
    navMonteCarlo = uibutton(sg,'push','Text','Monte Carlo','HorizontalAlignment','left');
    navSensitivity = uibutton(sg,'push','Text','Sensitivity','HorizontalAlignment','left');
    navEvidence = uibutton(sg,'push','Text','Evidence','HorizontalAlignment','left');

    navButtons = [navOverview, navReplay, navMission, navErrors, navEvolution, navQuantum, navMonteCarlo, navSensitivity, navEvidence];
    for k = 1:numel(navButtons)
        navButtons(k).BackgroundColor = theme.SidebarBackground;
        navButtons(k).FontColor = theme.TextSecondary;
        navButtons(k).FontSize = 12;
    end

    % Grid-managed page host. Using a grid here avoids DPI/scaling issues
    % where manually positioned child panels can remain at their default
    % ~160x120 pixel size instead of filling the available workspace.
    content = uigridlayout(main, [1 1]);
    content.Layout.Row = 2;
    content.Layout.Column = 2;
    content.RowHeight = {'1x'};
    content.ColumnWidth = {'1x'};
    content.Padding = [0 0 0 0];
    content.RowSpacing = 0;
    content.ColumnSpacing = 0;
    content.BackgroundColor = theme.Background;

    overview = build_overview_page(content, theme, data, metrics);
    replay = build_replay_page(content, theme, data, metrics);
    mission = build_mission_page(content, theme, data, metrics);
    errors = build_errors_page(content, theme, data, metrics);
    quantum = build_quantum_page(content, theme, data);
    evidence = build_evidence_page(content, theme);
    monteCarlo = build_monte_carlo_page(content, theme, research);
    sensitivity = build_sensitivity_page(content, theme, research);
    evolutionPage = build_evolution_page(content, theme, evolution);

    % Data provenance is intentionally visible in the UI.
    monteCarlo.LoadStatus.Text = 'Published Phase 7C';
    monteCarlo.LoadStatus.FontColor = theme.Success;
    sensitivity.LoadStatus.Text = 'Published Phase 7D';
    sensitivity.LoadStatus.FontColor = theme.Success;

    replay.Panel.Visible = 'off';
    mission.Panel.Visible = 'off';
    errors.Panel.Visible = 'off';
    quantum.Panel.Visible = 'off';
    evidence.Panel.Visible = 'off';
    monteCarlo.Panel.Visible = 'off';
    sensitivity.Panel.Visible = 'off';
    evolutionPage.Panel.Visible = 'off';

    footer = uipanel(main, 'BorderType', 'none', ...
        'BackgroundColor', theme.PanelBackground);
    footer.Layout.Row = 3;
    footer.Layout.Column = [1 2];

    fg = uigridlayout(footer, [1 5]);
    fg.ColumnWidth = {165,175,'1x',150,115};
    fg.Padding = [18 4 18 4];
    fg.ColumnSpacing = 10;
    fg.BackgroundColor = theme.PanelBackground;

    footerGPS = uilabel(fg,'Text','GPS AVAILABLE','FontWeight','bold', ...
        'FontSize',10,'FontColor',theme.Success);
    footerQuantum = uilabel(fg,'Text','QUANTUM ACTIVE','FontWeight','bold', ...
        'FontSize',10,'FontColor',theme.Accent);
    footerMessage = uilabel(fg,'Text', ...
        'Phase 7B reference run | Published Phase 7C and 7D results active.', ...
        'FontSize',10,'FontColor',theme.TextMuted);
    footerTime = uilabel(fg,'Text',sprintf('t = %.2f s',data.time(1)), ...
        'HorizontalAlignment','right','FontSize',10,'FontColor',theme.TextSecondary);
    footerStatus = uilabel(fg,'Text','READY','HorizontalAlignment','center', ...
        'FontWeight','bold','FontSize',10,'FontColor',theme.TextPrimary);

    app = struct();
    app.Version = dashboardVersion;
    app.Figure = fig;
    app.Theme = theme;
    app.Data = data;
    app.Metrics = metrics;
    app.Research = research;
    app.Evolution = evolution;
    app.Header.Scenario = scenarioLabel;
    app.Header.Validation = validLabel;

    app.Nav.Overview = navOverview;
    app.Nav.Replay = navReplay;
    app.Nav.Mission = navMission;
    app.Nav.Errors = navErrors;
    app.Nav.Evolution = navEvolution;
    app.Nav.Quantum = navQuantum;
    app.Nav.MonteCarlo = navMonteCarlo;
    app.Nav.Sensitivity = navSensitivity;
    app.Nav.Evidence = navEvidence;

    app.Pages.Overview = overview;
    app.Pages.Replay = replay;
    app.Pages.Mission = mission;
    app.Pages.Errors = errors;
    app.Pages.Quantum = quantum;
    app.Pages.Evidence = evidence;
    app.Pages.MonteCarlo = monteCarlo;
    app.Pages.Sensitivity = sensitivity;
    app.Pages.Evolution = evolutionPage;

    app.Footer.GPS = footerGPS;
    app.Footer.Quantum = footerQuantum;
    app.Footer.Message = footerMessage;
    app.Footer.Time = footerTime;
    app.Footer.Status = footerStatus;
    app.LastSelfTest = struct('passed',false,'summary','Not run');

    app.Playback.currentIndex = 1;
    app.Playback.speed = 1.0;
    % Full 100 Hz results use 50 ms timer ticks. Compact GitHub snapshots
    % are stored at 20 Hz; use 100 ms ticks so 0.5x/1x/2x/5x remain meaningful.
    app.Playback.period_s = max(0.05,2*data.meta.dt_s);
    app.Playback.isPlaying = false;
    app.Playback.Timer = create_playback_timer(fig, app.Playback.period_s);

    fig.UserData = app;

    navOverview.ButtonPushedFcn = @(src,evt) navigation_callback(fig,'overview');
    navReplay.ButtonPushedFcn = @(src,evt) navigation_callback(fig,'replay');
    navMission.ButtonPushedFcn = @(src,evt) navigation_callback(fig,'mission');
    navErrors.ButtonPushedFcn = @(src,evt) navigation_callback(fig,'errors');
    navEvolution.ButtonPushedFcn = @(src,evt) navigation_callback(fig,'evolution');
    navQuantum.ButtonPushedFcn = @(src,evt) navigation_callback(fig,'quantum');
    navMonteCarlo.ButtonPushedFcn = @(src,evt) navigation_callback(fig,'montecarlo');
    navSensitivity.ButtonPushedFcn = @(src,evt) navigation_callback(fig,'sensitivity');
    navEvidence.ButtonPushedFcn = @(src,evt) navigation_callback(fig,'evidence');
    replay.PlayPauseButton.ButtonPushedFcn = @(src,evt) play_pause_callback(fig);
    replay.ResetButton.ButtonPushedFcn = @(src,evt) reset_replay(fig);
    replay.SpeedDropDown.ValueChangedFcn = @(src,evt) speed_callback(fig,src.Value);
    replay.TimeSlider.ValueChangingFcn = @(src,evt) seek_callback(fig,evt.Value);
    replay.TimeSlider.ValueChangedFcn = @(src,evt) seek_callback(fig,src.Value);

    mission.ApplyButton.ButtonPushedFcn = @(src,evt) apply_mission_callback(fig);
    mission.RestoreButton.ButtonPushedFcn = @(src,evt) restore_baseline_callback(fig);
    mission.LoadButton.ButtonPushedFcn = @(src,evt) load_results_callback(fig);
    evidence.ExportButton.ButtonPushedFcn = @(src,evt) export_evidence_callback(fig);
    evidence.SelfTestButton.ButtonPushedFcn = @(src,evt) self_test_callback(fig);

    monteCarlo.MetricDropDown.ValueChangedFcn = @(src,evt) monte_carlo_metric_callback(fig);
    monteCarlo.RunSpinner.ValueChangedFcn = @(src,evt) monte_carlo_run_callback(fig);
    monteCarlo.LoadButton.ButtonPushedFcn = @(src,evt) load_research_results_callback(fig);

    sensitivity.MetricDropDown.ValueChangedFcn = @(src,evt) sensitivity_metric_callback(fig);
    sensitivity.OutageDropDown.ValueChangedFcn = @(src,evt) sensitivity_selection_callback(fig);
    sensitivity.RateDropDown.ValueChangedFcn = @(src,evt) sensitivity_selection_callback(fig);
    sensitivity.LoadButton.ButtonPushedFcn = @(src,evt) load_research_results_callback(fig);
    evolutionPage.MetricDropDown.ValueChangedFcn = @(src,evt) evolution_metric_callback(fig);

    navigation_callback(fig,'overview');
    render_replay_frame(fig,1);

    app = fig.UserData;
end
