function export_evidence_callback(fig)
%EXPORT_EVIDENCE_CALLBACK Export the current case without exporting live UIAxes.
%
% The export is generated from app.Data into temporary standard MATLAB
% figures. This avoids UIAxes/exportgraphics instability on some MATLAB
% releases and Windows DPI configurations.

    if isempty(fig) || ~isvalid(fig)
        return;
    end

    app = fig.UserData;

    wasRunning = false;
    try
        wasRunning = strcmp(app.Playback.Timer.Running,'on');
        if wasRunning
            stop(app.Playback.Timer);
        end
    catch
    end

    baseDir = uigetdir(pwd,'Select folder for OpenNavLab evidence package');
    if isequal(baseDir,0)
        resumeIfNeeded(fig,wasRunning);
        return;
    end

    stamp = datestr(now,'yyyymmdd_HHMMSS');
    outDir = fullfile(baseDir,['OpenNavLab_Evidence_' stamp]);

    try
        mkdir(outDir);
        data = app.Data;
        metrics = app.Metrics;
        research = app.Research;
        evolution = app.Evolution;
        dashboardVersion = app.Version;

        selfTest = run_dashboard_self_test(fig);
        app.LastSelfTest = selfTest;
        fig.UserData = app;

        save(fullfile(outDir,'dashboard_case.mat'), ...
            'data','metrics','research','evolution','dashboardVersion','selfTest');

        names = { ...
            'OutageStart_s';'OutageEnd_s';'OutageDuration_s';'QuantumRate_Hz'; ...
            'ClassicalMaxOutageError_m';'QuantumMaxOutageError_m'; ...
            'MaxOutageReduction_pct'; ...
            'ClassicalPositionRMSE_m';'QuantumPositionRMSE_m'; ...
            'ClassicalVelocityRMSE_mps';'QuantumVelocityRMSE_mps'; ...
            'ClassicalHeadingRMSE_deg';'QuantumHeadingRMSE_deg'; ...
            'MeanGPSNIS';'MeanQuantumNIS'};

        values = [ ...
            metrics.outageStart_s;metrics.outageEnd_s;metrics.outageDuration_s; ...
            data.meta.quantumRate_Hz; ...
            metrics.classicalMaxOutageError_m;metrics.quantumMaxOutageError_m; ...
            metrics.maxOutageReduction_pct; ...
            metrics.classicalPositionRMSE_m;metrics.quantumPositionRMSE_m; ...
            metrics.classicalVelocityRMSE_mps;metrics.quantumVelocityRMSE_mps; ...
            metrics.classicalHeadingRMSE_deg;metrics.quantumHeadingRMSE_deg; ...
            mean(data.nis.gps,'omitnan');mean(data.nis.quantum,'omitnan')];

        T = table(names,values,'VariableNames',{'Metric','Value'});
        writetable(T,fullfile(outDir,'summary_metrics.csv'));

        fid = fopen(fullfile(outDir,'scenario.txt'),'w');
        if fid < 0
            error('Could not create scenario.txt in the export directory.');
        end
        fprintf(fid,'OpenNavLab Dashboard Evidence Package\n');
        fprintf(fid,'Generated: %s\n',datestr(now));
        fprintf(fid,'Source: %s\n',data.meta.source);
        fprintf(fid,'Outage: %.3f to %.3f s\n',metrics.outageStart_s,metrics.outageEnd_s);
        fprintf(fid,'Quantum rate: %.3f Hz\n',data.meta.quantumRate_Hz);
        fprintf(fid,['Note: this package captures the currently loaded case; ' ...
                     'it does not rerun any estimator.\n']);
        fclose(fid);

        % Dashboard manifest and regression result.
        fid = fopen(fullfile(outDir,'dashboard_manifest.txt'),'w');
        if fid < 0
            error('Could not create dashboard_manifest.txt.');
        end
        fprintf(fid,'OpenNavLab Dashboard v%s\n',dashboardVersion);
        fprintf(fid,'Generated: %s\n',datestr(now));
        fprintf(fid,'Single-run source: %s\n',data.meta.source);
        fprintf(fid,'Monte Carlo source: %s\n',research.meta.monteCarloSource);
        fprintf(fid,'Sensitivity source: %s\n',research.meta.sensitivitySource);
        fprintf(fid,'Self-test: %s\n',selfTest.summary);
        if ~selfTest.passed
            fprintf(fid,'Failed checks:\n');
            for k=1:numel(selfTest.failures)
                fprintf(fid,'- %s\n',selfTest.failures{k});
            end
        end
        fclose(fid);

        % Preserve exact repository statistical source tables in the package.
        phase7cCsv = find_reference_result_file('phase7c_quantum_monte_carlo_runs.csv');
        phase7dCsv = find_reference_result_file('phase7d_quantum_sensitivity_summary.csv');
        if isfile(phase7cCsv)
            copyfile(phase7cCsv,fullfile(outDir,'phase7c_quantum_monte_carlo_runs.csv'));
        end
        if isfile(phase7dCsv)
            copyfile(phase7dCsv,fullfile(outDir,'phase7d_quantum_sensitivity_summary.csv'));
        end

        saveTrajectoryFigure(data,fullfile(outDir,'trajectory_comparison.png'));
        saveErrorFigure(data,metrics,'position',fullfile(outDir,'position_error.png'));
        saveErrorFigure(data,metrics,'velocity',fullfile(outDir,'velocity_error.png'));
        saveErrorFigure(data,metrics,'heading',fullfile(outDir,'heading_error.png'));
        saveBiasFigure(data,'accel_x',fullfile(outDir,'quantum_bias_accel_x.png'));
        saveBiasFigure(data,'gyro_z',fullfile(outDir,'quantum_bias_gyro_z.png'));
        saveNISFigure(data,fullfile(outDir,'nis_consistency.png'));
        saveEvolutionFigure(evolution,fullfile(outDir,'project_evolution.png'));
        saveSensitivityFigure(research.sensitivity, ...
            fullfile(outDir,'phase7d_sensitivity.png'));

        if isvalid(fig)
            app = fig.UserData;
            app.Pages.Evidence.Status.Text = 'EVIDENCE PACKAGE EXPORTED';
            app.Pages.Evidence.Status.FontColor = app.Theme.Success;
            app.Pages.Evidence.SelfTestStatus.Text = selfTest.summary;
            if selfTest.passed
                app.Pages.Evidence.SelfTestStatus.FontColor = app.Theme.Success;
                app.Pages.Evidence.SelfTestStatus.BackgroundColor = app.Theme.SuccessBackground;
            else
                app.Pages.Evidence.SelfTestStatus.FontColor = app.Theme.Error;
                app.Pages.Evidence.SelfTestStatus.BackgroundColor = app.Theme.ErrorBackground;
            end
            app.Pages.Evidence.PathLabel.Text = outDir;
            app.Footer.Message.Text = ['Evidence exported: ' outDir];
            app.Footer.Status.Text = 'READY';
            fig.UserData = app;
        end

    catch ME
        if isvalid(fig)
            app = fig.UserData;
            app.Pages.Evidence.Status.Text = 'EXPORT FAILED';
            app.Pages.Evidence.Status.FontColor = app.Theme.Error;
            app.Footer.Status.Text = 'EXPORT ERROR';
            app.Footer.Message.Text = ME.message;
            fig.UserData = app;
            uialert(fig,ME.message,'Evidence export failed','Icon','error');
        else
            warning('OpenNavLab:EvidenceExport', ...
                'Evidence export failed after dashboard closure: %s',ME.message);
        end
    end

    resumeIfNeeded(fig,wasRunning);
end

function saveTrajectoryFigure(data,fileName)
    f = makeHiddenFigure();
    cleanupObj = onCleanup(@() safeDeleteFigure(f));
    ax = axes(f);
    hold(ax,'on');
    plot(ax,data.truth.position(:,1),data.truth.position(:,2), ...
        'Color',[0.15 0.15 0.15],'LineWidth',1.5);
    plot(ax,data.classical.position(:,1),data.classical.position(:,2), ...
        'Color',[0.26 0.49 0.78],'LineWidth',1.4);
    plot(ax,data.quantum.position(:,1),data.quantum.position(:,2), ...
        'Color',[0.10 0.62 0.50],'LineWidth',1.4);
    grid(ax,'on'); axis(ax,'equal');
    xlabel(ax,'East / x [m]'); ylabel(ax,'North / y [m]');
    title(ax,'Navigation trajectory comparison');
    legend(ax,{'Truth','Classical EKF','Quantum-aided EKF'}, ...
        'Location','best','Box','off');
    print(f,fileName,'-dpng','-r180');
    clear cleanupObj
    safeDeleteFigure(f);
end

function saveErrorFigure(data,metrics,kind,fileName)
    switch lower(kind)
        case 'position'
            cErr = data.errors.classical.position_m;
            qErr = data.errors.quantum.position_m;
            yLabel = 'Position error [m]'; ttl = 'Position error comparison';
        case 'velocity'
            cErr = data.errors.classical.velocity_mps;
            qErr = data.errors.quantum.velocity_mps;
            yLabel = 'Velocity error [m/s]'; ttl = 'Velocity error comparison';
        case 'heading'
            cErr = data.errors.classical.heading_deg;
            qErr = data.errors.quantum.heading_deg;
            yLabel = 'Heading error [deg]'; ttl = 'Heading error comparison';
        otherwise
            error('Unknown error plot type: %s',kind);
    end

    f = makeHiddenFigure();
    cleanupObj = onCleanup(@() safeDeleteFigure(f));
    ax = axes(f); hold(ax,'on');

    ymax = max([cErr(:);qErr(:)]);
    if ~isfinite(ymax) || ymax <= 0, ymax = 1; end
    ymax = 1.08*ymax;

    haveOutage = isfinite(metrics.outageStart_s) && isfinite(metrics.outageEnd_s);
    if haveOutage
        patch(ax,[metrics.outageStart_s metrics.outageEnd_s metrics.outageEnd_s metrics.outageStart_s], ...
            [0 0 ymax ymax],[0.97 0.92 0.92],'EdgeColor','none','FaceAlpha',0.55);
    end

    plot(ax,data.time,cErr,'Color',[0.26 0.49 0.78],'LineWidth',1.4);
    plot(ax,data.time,qErr,'Color',[0.10 0.62 0.50],'LineWidth',1.4);
    grid(ax,'on'); xlabel(ax,'Time [s]'); ylabel(ax,yLabel); title(ax,ttl);
    xlim(ax,[data.time(1) data.time(end)]); ylim(ax,[0 ymax]);
    if haveOutage
        legend(ax,{'GPS outage','Classical','Quantum-aided'},'Location','best','Box','off');
    else
        legend(ax,{'Classical','Quantum-aided'},'Location','best','Box','off');
    end
    print(f,fileName,'-dpng','-r180');
    clear cleanupObj
    safeDeleteFigure(f);
end

function saveBiasFigure(data,kind,fileName)
    f = makeHiddenFigure();
    cleanupObj = onCleanup(@() safeDeleteFigure(f));
    ax = axes(f); hold(ax,'on');

    switch lower(kind)
        case 'accel_x'
            y1 = data.bias.true.accel_x_mps2;
            y2 = data.bias.classical.accel_x_mps2;
            y3 = data.bias.quantum.accel_x_mps2;
            yLabel = 'Bias [m/s^2]'; ttl = 'Accelerometer X bias tracking';
        case 'gyro_z'
            y1 = rad2deg(data.bias.true.gyro_z_rps);
            y2 = rad2deg(data.bias.classical.gyro_z_rps);
            y3 = rad2deg(data.bias.quantum.gyro_z_rps);
            yLabel = 'Bias [deg/s]'; ttl = 'Gyroscope Z bias tracking';
        otherwise
            error('Unknown bias plot type: %s',kind);
    end

    plot(ax,data.time,y1,'Color',[0.15 0.15 0.15],'LineWidth',1.4);
    plot(ax,data.time,y2,'Color',[0.26 0.49 0.78],'LineWidth',1.3);
    plot(ax,data.time,y3,'Color',[0.10 0.62 0.50],'LineWidth',1.3);
    grid(ax,'on'); xlabel(ax,'Time [s]'); ylabel(ax,yLabel); title(ax,ttl);
    xlim(ax,[data.time(1) data.time(end)]);
    legend(ax,{'True','Classical estimate','Quantum-aided estimate'},'Location','best','Box','off');
    print(f,fileName,'-dpng','-r180');
    clear cleanupObj
    safeDeleteFigure(f);
end

function saveNISFigure(data,fileName)
    f = makeHiddenFigure();
    cleanupObj = onCleanup(@() safeDeleteFigure(f));
    ax = axes(f); hold(ax,'on');
    plot(ax,data.time,data.nis.gps,'.','Color',[0.26 0.49 0.78],'MarkerSize',7);
    plot(ax,data.time,data.nis.quantum,'.','Color',[0.10 0.62 0.50],'MarkerSize',7);
    yline(ax,data.nis.gpsExpected,'--','Color',[0.26 0.49 0.78],'LineWidth',1.0);
    yline(ax,data.nis.quantumExpected,'--','Color',[0.10 0.62 0.50],'LineWidth',1.0);
    grid(ax,'on'); xlabel(ax,'Time [s]'); ylabel(ax,'NIS'); title(ax,'Innovation consistency');
    xlim(ax,[data.time(1) data.time(end)]);
    legend(ax,{'GPS NIS','Quantum NIS','GPS expected','Quantum expected'},'Location','best','Box','off');
    print(f,fileName,'-dpng','-r180');
    clear cleanupObj
    safeDeleteFigure(f);
end


function saveEvolutionFigure(e,fileName)
    f = makeHiddenFigure();
    c = onCleanup(@() safeDeleteFigure(f));
    ax = axes(f);
    vals = e.singleRun.positionRMSE_m;
    bar(ax,vals,0.58,'FaceColor',[0.26 0.49 0.78],'EdgeColor','none');
    ax.XTick=1:numel(e.singleRun.phaseNames);
    ax.XTickLabel=e.singleRun.phaseNames;
    ax.XTickLabelRotation=10;
    ylabel(ax,'Position RMSE [m]');
    title(ax,'OpenNavLab project evolution - comparable single-run position RMSE');
    grid(ax,'on');
    print(f,fileName,'-dpng','-r180');
end


function saveSensitivityFigure(sensitivity,fileName)
    f = makeHiddenFigure();
    cleanupObj = onCleanup(@() safeDeleteFigure(f));
    ax = axes(f);
    hold(ax,'on');

    plot(ax,sensitivity.outage_s,sensitivity.classicalMeanMax_m, ...
        '-o','Color',[0.15 0.15 0.15],'LineWidth',1.7,'MarkerSize',4);

    cols = [ ...
        0.55 0.68 0.86; ...
        0.39 0.57 0.82; ...
        0.22 0.46 0.76; ...
        0.10 0.62 0.50];

    for k=1:numel(sensitivity.rates_Hz)
        plot(ax,sensitivity.outage_s,sensitivity.quantumMeanMax_m(k,:), ...
            '-o','Color',cols(k,:),'LineWidth',1.4,'MarkerSize',4);
    end

    grid(ax,'on');
    xlabel(ax,'GPS outage duration [s]');
    ylabel(ax,'Mean maximum position error [m]');
    title(ax,'OpenNavLab Phase 7D sensitivity - published results');
    legend(ax,{'Classical','Q 0.25 Hz','Q 0.5 Hz','Q 1 Hz','Q 2 Hz'}, ...
        'Location','northwest','Box','off');

    print(f,fileName,'-dpng','-r180');
    clear cleanupObj
    safeDeleteFigure(f);
end

function f = makeHiddenFigure()
    f = figure('Visible','off','Color','w','Units','pixels', ...
        'Position',[100 100 1100 600],'HandleVisibility','callback');
end

function safeDeleteFigure(f)
    try
        if ~isempty(f) && isvalid(f), delete(f); end
    catch
    end
end

function resumeIfNeeded(fig,wasRunning)
    if ~wasRunning || isempty(fig) || ~isvalid(fig), return; end
    try
        app = fig.UserData;
        if strcmp(app.Playback.Timer.Running,'off')
            start(app.Playback.Timer);
            app.Playback.isPlaying = true;
            app.Pages.Replay.PlayPauseButton.Text = 'Pause';
            app.Footer.Status.Text = 'PLAYING';
            fig.UserData = app;
        end
    catch
    end
end
