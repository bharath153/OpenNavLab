function navigation_callback(fig,targetPage)
%NAVIGATION_CALLBACK Switch between dashboard pages.

    if isempty(fig) || ~isvalid(fig), return; end

    app = fig.UserData;
    theme = app.Theme;

    pageNames = {'Overview','Replay','Mission','Errors','Evolution','Quantum', ...
                 'MonteCarlo','Sensitivity','Evidence'};
    for k = 1:numel(pageNames)
        app.Pages.(pageNames{k}).Panel.Visible = 'off';
    end

    nav = [app.Nav.Overview app.Nav.Replay app.Nav.Mission app.Nav.Errors app.Nav.Evolution ...
           app.Nav.Quantum app.Nav.MonteCarlo app.Nav.Sensitivity app.Nav.Evidence];
    for k = 1:numel(nav)
        nav(k).BackgroundColor = theme.SidebarBackground;
        nav(k).FontColor = theme.TextSecondary;
        nav(k).FontWeight = 'normal';
    end

    switch lower(targetPage)
        case 'overview'
            app.Pages.Overview.Panel.Visible = 'on';
            selected = app.Nav.Overview;
            msg = 'Overview - scenario summary and animated navigation preview.';
        case 'replay'
            app.Pages.Replay.Panel.Visible = 'on';
            selected = app.Nav.Replay;
            msg = 'Replay - play, pause, seek and inspect GPS/quantum state changes.';
        case 'mission'
            app.Pages.Mission.Panel.Visible = 'on';
            selected = app.Nav.Mission;
            msg = 'Mission - configure demo parameters or load OpenNavLab MAT results.';
        case 'errors'
            app.Pages.Errors.Panel.Visible = 'on';
            selected = app.Nav.Errors;
            msg = 'Errors - synchronized position, velocity and heading comparisons.';
        case 'evolution'
            app.Pages.Evolution.Panel.Visible = 'on';
            selected = app.Nav.Evolution;
            msg = 'Evolution - cross-phase error reduction and project progression.';
        case 'quantum'
            app.Pages.Quantum.Panel.Visible = 'on';
            selected = app.Nav.Quantum;
            msg = 'Quantum - bias-reference tracking and NIS consistency.';
        case 'montecarlo'
            app.Pages.MonteCarlo.Panel.Visible = 'on';
            selected = app.Nav.MonteCarlo;
            msg = 'Monte Carlo - paired statistical comparison across 100 runs.';
        case 'sensitivity'
            app.Pages.Sensitivity.Panel.Visible = 'on';
            selected = app.Nav.Sensitivity;
            msg = 'Sensitivity - quantum rate versus GPS-outage operating envelope.';
        case 'evidence'
            app.Pages.Evidence.Panel.Visible = 'on';
            selected = app.Nav.Evidence;
            msg = 'Evidence - export the current case, metrics and figures.';
        otherwise
            error('OpenNavLab:Dashboard:UnknownPage','Unknown page: %s',targetPage);
    end

    selected.BackgroundColor = theme.AccentSoft;
    selected.FontColor = theme.AccentDark;
    selected.FontWeight = 'bold';

    app.Footer.Message.Text = msg;
    fig.UserData = app;
end
