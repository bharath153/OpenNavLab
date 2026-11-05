function [c,q,unit,label,decimals] = get_mc_metric(mc,selection)
%GET_MC_METRIC Map Monte Carlo metric dropdown text to paired vectors.

    switch char(selection)
        case 'Maximum Outage Error'
            c = mc.maxOutage.classical;
            q = mc.maxOutage.quantum;
            unit = 'm';
            label = 'Maximum outage error';
            decimals = 3;

        case 'Position RMSE'
            c = mc.positionRMSE.classical;
            q = mc.positionRMSE.quantum;
            unit = 'm';
            label = 'Position RMSE';
            decimals = 3;

        case 'Final Position Error'
            c = mc.finalPosition.classical;
            q = mc.finalPosition.quantum;
            unit = 'm';
            label = 'Final position error';
            decimals = 3;

        case 'Velocity RMSE'
            c = mc.velocityRMSE.classical;
            q = mc.velocityRMSE.quantum;
            unit = 'm/s';
            label = 'Velocity RMSE';
            decimals = 4;

        case 'Heading RMSE'
            c = mc.headingRMSE.classical;
            q = mc.headingRMSE.quantum;
            unit = 'deg';
            label = 'Heading RMSE';
            decimals = 3;

        otherwise
            error('OpenNavLab:Dashboard:UnknownMCMetric', ...
                'Unknown Monte Carlo metric: %s',char(selection));
    end
end
