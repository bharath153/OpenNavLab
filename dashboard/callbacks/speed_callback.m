function speed_callback(fig,value)
%SPEED_CALLBACK Update playback speed.

    if isempty(fig) || ~isvalid(fig), return; end

    speed = str2double(erase(string(value),"x"));
    if ~isfinite(speed) || speed <= 0, speed = 1; end

    app = fig.UserData;
    app.Playback.speed = speed;
    app.Footer.Message.Text = sprintf('Playback speed set to %.1fx.',speed);
    fig.UserData = app;
end
