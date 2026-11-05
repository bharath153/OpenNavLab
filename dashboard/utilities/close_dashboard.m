function close_dashboard(fig)
%CLOSE_DASHBOARD Stop and delete the playback timer before closing.

    if isempty(fig) || ~isvalid(fig), return; end

    try
        app = fig.UserData;
        if isfield(app,'Playback') && isfield(app.Playback,'Timer')
            t = app.Playback.Timer;
            if ~isempty(t) && isvalid(t)
                if strcmp(t.Running,'on'), stop(t); end
                delete(t);
            end
        end
    catch
    end

    delete(fig);
end
