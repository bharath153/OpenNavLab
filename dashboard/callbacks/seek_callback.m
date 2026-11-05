function seek_callback(fig,timeValue)
%SEEK_CALLBACK Seek to the nearest sample.

    if isempty(fig) || ~isvalid(fig), return; end

    app = fig.UserData;
    [~,idx] = min(abs(app.Data.time-timeValue));
    app.Playback.currentIndex = idx;
    fig.UserData = app;

    render_replay_frame(fig,idx);
end
