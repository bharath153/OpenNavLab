function restore_baseline_callback(fig)
%RESTORE_BASELINE_CALLBACK Restore the real Phase 7B repository reference run.

    if isempty(fig) || ~isvalid(fig), return; end

    data = load_builtin_single_run_results();
    apply_loaded_case(fig,data,'Phase 7B reference run restored.');

    app = fig.UserData;
    m = app.Pages.Mission;
    m.Status.Text = 'REFERENCE RUN';
    m.Status.FontColor = app.Theme.Success;
    m.Status.BackgroundColor = app.Theme.SuccessBackground;
    fig.UserData = app;
end
