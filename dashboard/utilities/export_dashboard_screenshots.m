function files = export_dashboard_screenshots(app,outputDir)
%EXPORT_DASHBOARD_SCREENSHOTS Export GitHub-ready screenshots from the live UI.
%
% Example:
%   app = run_opennavlab_dashboard;
%   files = export_dashboard_screenshots(app);
%
% Default output:
%   <OpenNavLab>/docs/dashboard/screenshots/
%
% Requires a visible desktop MATLAB session. The function uses exportapp so
% the images are actual dashboard renders, not reconstructed figures.

    if nargin < 1 || isempty(app)
        figs = findall(groot,'Type','figure','Tag','OpenNavLabDashboard');
        if isempty(figs)
            error('OpenNavLab:Dashboard:NoFigure', ...
                'Launch the dashboard before exporting screenshots.');
        end
        fig = figs(1);
    elseif isstruct(app) && isfield(app,'Figure')
        fig = app.Figure;
    elseif isa(app,'matlab.ui.Figure')
        fig = app;
    else
        error('OpenNavLab:Dashboard:InvalidApp', ...
            'Pass the app returned by run_opennavlab_dashboard or its UIFigure.');
    end

    if isempty(fig) || ~isvalid(fig)
        error('OpenNavLab:Dashboard:InvalidFigure','Dashboard figure is not valid.');
    end

    dashboardRoot = fileparts(fileparts(mfilename('fullpath')));
    repositoryRoot = fileparts(dashboardRoot);

    if nargin < 2 || isempty(outputDir)
        outputDir = fullfile(repositoryRoot,'docs','dashboard','screenshots');
    end
    if ~isfolder(outputDir), mkdir(outputDir); end

    wasVisible = fig.Visible;
    fig.Visible = 'on';
    drawnow;

    files = strings(0,1);

    capture('overview','01_overview.png');

    % Replay at the midpoint of the real 50-70 s GPS outage.
    navigation_callback(fig,'replay');
    a = fig.UserData;
    [~,idx] = min(abs(a.Data.time-60));
    render_replay_frame(fig,idx);
    drawnow;
    captureCurrent('02_replay_gps_outage.png');

    capture('evolution','03_project_evolution.png');
    capture('montecarlo','04_monte_carlo.png');
    capture('sensitivity','05_sensitivity.png');

    self_test_callback(fig);
    capture('evidence','06_evidence_validation.png');

    fig.Visible = wasVisible;

    function capture(page,fileName)
        navigation_callback(fig,page);
        drawnow;
        pause(0.10);
        captureCurrent(fileName);
    end

    function captureCurrent(fileName)
        outFile = fullfile(outputDir,fileName);
        exportapp(fig,outFile);
        files(end+1,1) = string(outFile); %#ok<AGROW>
    end
end
