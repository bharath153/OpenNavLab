function t = create_playback_timer(fig,period_s)
%CREATE_PLAYBACK_TIMER Create the dashboard playback timer.
%
% MATLAB timer Period is limited to millisecond precision. Quantize the
% requested period explicitly so floating-point arithmetic does not produce
% the harmless "sub-millisecond precision will be ignored" warning.

    period_s = max(0.001, round(double(period_s),3));

    t = timer('Name','OpenNavLab navigation playback', ...
        'ExecutionMode','fixedSpacing', ...
        'Period',period_s, ...
        'BusyMode','drop', ...
        'TimerFcn',@(~,~) update_replay_frame(fig), ...
        'ErrorFcn',@(~,evt) playback_timer_error(fig,evt));
end

function playback_timer_error(fig,evt)
    if isempty(fig) || ~isvalid(fig), return; end

    app = fig.UserData;
    app.Playback.isPlaying = false;
    app.Pages.Replay.PlayPauseButton.Text = 'Play';
    app.Footer.Status.Text = 'TIMER ERROR';
    app.Footer.Status.FontColor = app.Theme.Error;

    try
        app.Footer.Message.Text = evt.Data.Message;
    catch
        app.Footer.Message.Text = 'Playback timer error.';
    end

    fig.UserData = app;
end
