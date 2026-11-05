function result = run_dashboard_self_test(fig)
%RUN_DASHBOARD_SELF_TEST Non-destructive v1.0 regression/provenance checks.

    result = struct('passed',true,'checks',{{}},'failures',{{}});

    if isempty(fig) || ~isvalid(fig)
        result = fail(result,'Dashboard figure is not valid.');
        return;
    end

    app = fig.UserData;

    result = check(result,strcmp(app.Version,'1.0.1'),'Dashboard version is 1.0.1.');

    timers = timerfindall('Name','OpenNavLab navigation playback');
    result = check(result,numel(timers)==1, ...
        sprintf('Exactly one playback timer while open (found %d).',numel(timers)));

    data = app.Data;
    n = numel(data.time);
    dimsOK = n>=1201 ...
        && size(data.truth.position,1)==n ...
        && size(data.classical.position,1)==n ...
        && size(data.quantum.position,1)==n;
    result = check(result,dimsOK,'Phase 7B single-run dimensions are consistent (full or compact snapshot).');

    prodSingle = isfield(data.meta,'isProductionResult') && logical(data.meta.isProductionResult);
    result = check(result,prodSingle,'Single-run page uses a repository production result.');

    m = app.Metrics;
    result = check(result,abs(m.classicalPositionRMSE_m-2.7659405281130756)<1e-10, ...
        'Phase 7B classical position RMSE matches repository result.');
    result = check(result,abs(m.quantumPositionRMSE_m-2.2322845701483662)<1e-10, ...
        'Phase 7B quantum position RMSE matches repository result.');
    result = check(result,abs(m.classicalMaxOutageError_m-8.849204971593345)<1e-10 ...
        && abs(m.quantumMaxOutageError_m-6.639959075601451)<1e-10, ...
        'Phase 7B maximum outage errors match repository result.');
    result = check(result,abs(data.meta.quantumRate_Hz-1)<1e-12 ...
        && abs(m.outageStart_s-50)<1e-12 && abs(m.outageEnd_s-70)<1e-12, ...
        'Phase 7B timing and quantum update rate match repository configuration.');

    mc = app.Research.mc;
    mcProd = isfield(mc,'meta') && isfield(mc.meta,'isProductionResult') ...
        && logical(mc.meta.isProductionResult);
    result = check(result,mcProd && numel(mc.run)==100, ...
        'Phase 7C page uses 100 published paired runs.');

    mcGain = mc.maxOutage.classical-mc.maxOutage.quantum;
    mcOK = abs(mean(mc.maxOutage.classical)-5.66242685608576)<1e-10 ...
        && abs(mean(mc.maxOutage.quantum)-4.82097065849828)<1e-10 ...
        && abs(mean(mcGain)-0.841456197587484)<1e-10 ...
        && abs(100*mean(mcGain>0)-66)<1e-12;
    result = check(result,mcOK,'Phase 7C maximum-outage statistics match repository CSV.');

    s = app.Research.sensitivity;
    shapeOK = isequal(size(s.quantumMeanMax_m),[4 6]) ...
        && isequal(s.outage_s,[0 5 10 20 30 40]) ...
        && isequal(s.rates_Hz,[0.25 0.5 1 2]);
    result = check(result,shapeOK,'Phase 7D grid is 4 rates x 6 outage durations.');

    prodSensitivity = isfield(s,'meta') && isfield(s.meta,'isProductionResult') ...
        && logical(s.meta.isProductionResult);
    result = check(result,prodSensitivity,'Sensitivity page uses repository production results.');

    [~,oi] = min(abs(s.outage_s-40));
    [~,ri] = min(abs(s.rates_Hz-2));

    keyOK = abs(s.classicalMeanMax_m(oi)-14.8177253746762)<1e-10 ...
        && abs(s.quantumMeanMax_m(ri,oi)-7.92914810615172)<1e-10 ...
        && abs(s.meanReduction_pct(ri,oi)-46.488763250378511)<1e-9 ...
        && abs(s.p95Reduction_pct(ri,oi)-49.542505592439532)<1e-9 ...
        && abs(s.runsImproved_pct(ri,oi)-78)<1e-12 ...
        && abs(s.quantumNIS(ri,oi)-2.99263076651901)<1e-10;
    result = check(result,keyOK,'Phase 7D 40 s / 2 Hz reference point matches repository CSV.');

    evo = app.Evolution;
    evoOK = isfield(evo,'meta') && isfield(evo.meta,'isProductionResult') ...
        && logical(evo.meta.isProductionResult);
    result = check(result,evoOK,'Evolution page uses repository phase metrics.');

    pageNames = {'Overview','Replay','Mission','Errors','Evolution','Quantum', ...
        'MonteCarlo','Sensitivity','Evidence'};
    pageOK = true;
    for k = 1:numel(pageNames)
        pageOK = pageOK && isfield(app.Pages,pageNames{k}) ...
            && isvalid(app.Pages.(pageNames{k}).Panel);
    end
    result = check(result,pageOK,'All dashboard pages are constructed and valid.');

    result.totalChecks = numel(result.checks);
    result.failedChecks = numel(result.failures);
    result.passed = result.failedChecks==0;

    if result.passed
        result.summary = sprintf('PASS - %d/%d checks passed.', ...
            result.totalChecks,result.totalChecks);
    else
        result.summary = sprintf('FAIL - %d of %d checks failed.', ...
            result.failedChecks,result.totalChecks);
    end
end

function result = check(result,condition,message)
    result.checks{end+1,1}=message;
    if ~condition
        result.failures{end+1,1}=message;
        result.passed=false;
    end
end

function result = fail(result,message)
    result.checks{end+1,1}=message;
    result.failures{end+1,1}=message;
    result.totalChecks=1;
    result.failedChecks=1;
    result.passed=false;
    result.summary='FAIL - dashboard figure invalid.';
end
