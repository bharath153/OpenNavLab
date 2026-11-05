function app = run_opennavlab_dashboard(caseSource)
%RUN_OPENNAVLAB_DASHBOARD Launch OpenNavLab Dashboard v0.1.
%
% Enforces a single active dashboard instance and removes orphan playback
% timers left by interrupted development runs.

    dashboardRoot = fileparts(mfilename('fullpath'));
    addpath(genpath(dashboardRoot));

    if nargin < 1
        caseSource = [];
    end

    % Clean up stale/orphan timers first.
    staleTimers = timerfindall('Name','OpenNavLab navigation playback');
    for k = 1:numel(staleTimers)
        try
            if strcmp(staleTimers(k).Running,'on')
                stop(staleTimers(k));
            end
        catch
        end
        try
            delete(staleTimers(k));
        catch
        end
    end

    % Close any previous dashboard figure.
    oldFigs = findall(groot,'Type','figure','Tag','OpenNavLabDashboard');
    for k = 1:numel(oldFigs)
        try
            delete(oldFigs(k));
        catch
        end
    end

    app = build_dashboard(caseSource);
end
