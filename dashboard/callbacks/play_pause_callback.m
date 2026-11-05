function play_pause_callback(fig)
%PLAY_PAUSE_CALLBACK Toggle playback.

    if isempty(fig) || ~isvalid(fig), return; end

    app = fig.UserData;
    t = app.Playback.Timer;

    if app.Playback.currentIndex >= numel(app.Data.time)
        app.Playback.currentIndex = 1;
        fig.UserData = app;
        render_replay_frame(fig,1);
        app = fig.UserData;
    end

    if strcmp(t.Running,'on')
        stop(t);
        app.Playback.isPlaying = false;
        app.Pages.Replay.PlayPauseButton.Text = 'Play';
        app.Footer.Status.Text = 'PAUSED';
    else
        start(t);
        app.Playback.isPlaying = true;
        app.Pages.Replay.PlayPauseButton.Text = 'Pause';
        app.Footer.Status.Text = 'PLAYING';
    end

    fig.UserData = app;
end
