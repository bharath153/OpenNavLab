function refresh_research_pages(fig)
%REFRESH_RESEARCH_PAGES Refresh MC and sensitivity controls after data load.
    if isempty(fig) || ~isvalid(fig), return; end
    app=fig.UserData;

    if isfield(app.Research,'mc')
        mc=app.Research.mc;
        app.Pages.MonteCarlo.RunSpinner.Limits=[1 numel(mc.run)];
        app.Pages.MonteCarlo.RunSpinner.Value=1;
        fig.UserData=app;
        monte_carlo_metric_callback(fig);
        app=fig.UserData;
        app.Pages.MonteCarlo.LoadStatus.Text=sprintf('Loaded %d paired runs',numel(mc.run));
        app.Pages.MonteCarlo.LoadStatus.FontColor=app.Theme.Success;
        app.Pages.Evidence.MonteCarloSource.Text=sprintf('Monte Carlo: loaded %d paired runs',numel(mc.run));
        app.Pages.Evidence.MonteCarloSource.FontColor=app.Theme.Success;
    end

    if isfield(app.Research,'sensitivity')
        s=app.Research.sensitivity;
        if numel(s.rates_Hz) ~= numel(app.Pages.Sensitivity.RateLines)
            error('Loaded sensitivity data must contain %d quantum rates for this dashboard layout.',numel(app.Pages.Sensitivity.RateLines));
        end
        app.Pages.Sensitivity.OutageDropDown.Items=string(s.outage_s);
        app.Pages.Sensitivity.RateDropDown.Items=string(s.rates_Hz);
        app.Pages.Sensitivity.OutageDropDown.Value=string(s.outage_s(end));
        app.Pages.Sensitivity.RateDropDown.Value=string(s.rates_Hz(end));
        app.Pages.Sensitivity.ClassicalLine.XData=s.outage_s;
        app.Pages.Sensitivity.ClassicalLine.YData=s.classicalMeanMax_m;
        for k=1:numel(s.rates_Hz)
            app.Pages.Sensitivity.RateLines(k).XData=s.outage_s;
            app.Pages.Sensitivity.RateLines(k).YData=s.quantumMeanMax_m(k,:);
        end
        app.Pages.Sensitivity.HeatAxes.XTick=1:numel(s.outage_s);
        app.Pages.Sensitivity.HeatAxes.XTickLabel=string(s.outage_s);
        app.Pages.Sensitivity.HeatAxes.YTick=1:numel(s.rates_Hz);
        app.Pages.Sensitivity.HeatAxes.YTickLabel=string(s.rates_Hz);
        app.Pages.Sensitivity.LoadStatus.Text=sprintf('Loaded %d x %d sensitivity grid',numel(s.rates_Hz),numel(s.outage_s));
        app.Pages.Sensitivity.LoadStatus.FontColor=app.Theme.Success;
        app.Pages.Evidence.SensitivitySource.Text=sprintf('Sensitivity: loaded %d x %d grid',numel(s.rates_Hz),numel(s.outage_s));
        app.Pages.Evidence.SensitivitySource.FontColor=app.Theme.Success;
        fig.UserData=app;
        sensitivity_metric_callback(fig);
        sensitivity_selection_callback(fig);
        app=fig.UserData;
    end
    fig.UserData=app;
end
