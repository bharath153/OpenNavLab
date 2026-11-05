function reset_replay(fig)
%RESET_REPLAY Return playback to the first sample.

    if isempty(fig) || ~isvalid(fig), return; end

    app = fig.UserData;

    if strcmp(app.Playback.Timer.Running,'on')
        stop(app.Playback.Timer);
    end

    app.Playback.currentIndex = 1;
    app.Playback.isPlaying = false;
    app.Pages.Replay.PlayPauseButton.Text = 'Play';
    app.Footer.Status.Text = 'READY';
    app.Footer.Status.FontColor = app.Theme.TextPrimary;

    fig.UserData = app;
    render_replay_frame(fig,1);
end
