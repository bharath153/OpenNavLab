function update_replay_frame(fig)
%UPDATE_REPLAY_FRAME Advance playback by one timer interval.

    if isempty(fig) || ~isvalid(fig), return; end

    app = fig.UserData;
    n = numel(app.Data.time);

    dt = app.Data.meta.dt_s;
    step = max(1,round(app.Playback.period_s*app.Playback.speed/dt));

    nextIndex = min(n,app.Playback.currentIndex+step);
    app.Playback.currentIndex = nextIndex;
    fig.UserData = app;

    render_replay_frame(fig,nextIndex);

    if nextIndex >= n
        app = fig.UserData;
        if strcmp(app.Playback.Timer.Running,'on')
            stop(app.Playback.Timer);
        end
        app.Playback.isPlaying = false;
        app.Pages.Replay.PlayPauseButton.Text = 'Play';
        app.Footer.Status.Text = 'COMPLETE';
        fig.UserData = app;
    end
end
