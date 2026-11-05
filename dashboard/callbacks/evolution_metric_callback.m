function evolution_metric_callback(fig)
%EVOLUTION_METRIC_CALLBACK Update the cross-phase comparison chart.

    if isempty(fig) || ~isvalid(fig), return; end
    app=fig.UserData;
    h=app.Pages.Evolution;
    e=app.Evolution;
    [v,u,l]=getMetric(e,h.MetricDropDown.Value);
    h.Bar.YData=v;
    ylabel(h.Axes,u);
    title(h.Axes,[l ' across comparable single-run phases'],'FontWeight','bold');
    finiteVals=v(isfinite(v));
    if ~isempty(finiteVals)
        ymax=max(finiteVals);
        if ymax<=0, ymax=1; end
        ylim(h.Axes,[0 1.12*ymax]);
    end
    app.Pages.Evolution=h;
    fig.UserData=app;
end

function [v,u,l]=getMetric(e,selection)
    switch char(selection)
        case 'Position RMSE'
            v=e.singleRun.positionRMSE_m; u='Position RMSE [m]'; l='Position RMSE';
        case 'Velocity RMSE'
            v=e.singleRun.velocityRMSE_mps; u='Velocity RMSE [m/s]'; l='Velocity RMSE';
        case 'Heading RMSE'
            v=e.singleRun.headingRMSE_deg; u='Heading RMSE [deg]'; l='Heading RMSE';
        case 'Maximum Outage Error'
            v=e.singleRun.maxOutageError_m; u='Maximum outage error [m]'; l='Maximum outage error';
    end
end
