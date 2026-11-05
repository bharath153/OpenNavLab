function self_test_callback(fig)
%SELF_TEST_CALLBACK Run dashboard regression checks and show result.

    if isempty(fig) || ~isvalid(fig), return; end

    app = fig.UserData;
    result = run_dashboard_self_test(fig);
    app.LastSelfTest = result;

    if result.passed
        app.Pages.Evidence.SelfTestStatus.Text = result.summary;
        app.Pages.Evidence.SelfTestStatus.FontColor = app.Theme.Success;
        app.Pages.Evidence.SelfTestStatus.BackgroundColor = app.Theme.SuccessBackground;
        app.Footer.Status.Text = 'SELF-TEST PASS';
        app.Footer.Status.FontColor = app.Theme.Success;
    else
        app.Pages.Evidence.SelfTestStatus.Text = result.summary;
        app.Pages.Evidence.SelfTestStatus.FontColor = app.Theme.Error;
        app.Pages.Evidence.SelfTestStatus.BackgroundColor = app.Theme.ErrorBackground;
        app.Footer.Status.Text = 'SELF-TEST FAIL';
        app.Footer.Status.FontColor = app.Theme.Error;
    end

    app.Footer.Message.Text = result.summary;
    fig.UserData = app;

    if ~result.passed
        msg = strjoin(result.failures,newline);
        uialert(fig,msg,'Dashboard self-test failed','Icon','error');
    end
end
