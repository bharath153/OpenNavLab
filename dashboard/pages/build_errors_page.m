function handles = build_errors_page(parent, theme, data, metrics)
%BUILD_ERRORS_PAGE Build synchronized error-analysis page.

    panel = uipanel(parent,'BorderType','none','BackgroundColor',theme.Background);
    panel.Layout.Row = 1;
    panel.Layout.Column = 1;

    grid = uigridlayout(panel,[5 3]);
    grid.RowHeight = {54,96,'1x','1x','1x'};
    grid.ColumnWidth = {'1x','1x','1x'};
    grid.RowSpacing = 10;
    grid.ColumnSpacing = 12;
    grid.Padding = [24 16 24 16];
    grid.BackgroundColor = theme.Background;

    title = uilabel(grid,'Text','Error Analysis','FontSize',22, ...
        'FontWeight','bold','FontColor',theme.TextPrimary);
    title.Layout.Row = 1;
    title.Layout.Column = [1 2];

    hint = uilabel(grid,'Text','Synchronized classical vs quantum-aided error history', ...
        'HorizontalAlignment','right','FontSize',11,'FontColor',theme.TextMuted);
    hint.Layout.Row = 1;
    hint.Layout.Column = 3;

    posCard = create_kpi_card(grid,theme,'Position RMSE', ...
        sprintf('%.2f -> %.2f m',metrics.classicalPositionRMSE_m,metrics.quantumPositionRMSE_m), ...
        sprintf('%.1f%% reduction',metrics.positionRMSEreduction_pct));
    posCard.Panel.Layout.Row = 2;
    posCard.Panel.Layout.Column = 1;

    velCard = create_kpi_card(grid,theme,'Velocity RMSE', ...
        sprintf('%.3f -> %.3f m/s',metrics.classicalVelocityRMSE_mps,metrics.quantumVelocityRMSE_mps), ...
        sprintf('%.1f%% reduction',metrics.velocityRMSEreduction_pct));
    velCard.Panel.Layout.Row = 2;
    velCard.Panel.Layout.Column = 2;

    headCard = create_kpi_card(grid,theme,'Heading RMSE', ...
        sprintf('%.2f -> %.2f deg',metrics.classicalHeadingRMSE_deg,metrics.quantumHeadingRMSE_deg), ...
        sprintf('%.1f%% reduction',metrics.headingRMSEreduction_pct));
    headCard.Panel.Layout.Row = 2;
    headCard.Panel.Layout.Column = 3;

    [posPanel,posAx,posC,posQ,posCursor,posPatch] = makeErrorAxis( ...
        grid,3,[1 3],theme,data.time, ...
        data.errors.classical.position_m,data.errors.quantum.position_m, ...
        'Position error','Error [m]',metrics);

    [velPanel,velAx,velC,velQ,velCursor,velPatch] = makeErrorAxis( ...
        grid,4,[1 3],theme,data.time, ...
        data.errors.classical.velocity_mps,data.errors.quantum.velocity_mps, ...
        'Velocity error','Error [m/s]',metrics);

    [headPanel,headAx,headC,headQ,headCursor,headPatch] = makeErrorAxis( ...
        grid,5,[1 3],theme,data.time, ...
        data.errors.classical.heading_deg,data.errors.quantum.heading_deg, ...
        'Heading error','Error [deg]',metrics);

    handles.Panel = panel;
    handles.PositionCard = posCard;
    handles.VelocityCard = velCard;
    handles.HeadingCard = headCard;

    handles.PositionAxes = posAx;
    handles.VelocityAxes = velAx;
    handles.HeadingAxes = headAx;

    handles.PositionClassical = posC;
    handles.PositionQuantum = posQ;
    handles.VelocityClassical = velC;
    handles.VelocityQuantum = velQ;
    handles.HeadingClassical = headC;
    handles.HeadingQuantum = headQ;

    handles.PositionCursor = posCursor;
    handles.VelocityCursor = velCursor;
    handles.HeadingCursor = headCursor;

    handles.PositionOutagePatch = posPatch;
    handles.VelocityOutagePatch = velPatch;
    handles.HeadingOutagePatch = headPatch;
end

function [panel,ax,cLine,qLine,cursor,outagePatch] = makeErrorAxis( ...
    grid,row,col,theme,t,cErr,qErr,titleText,yLabel,metrics)

    panel = uipanel(grid,'BorderType','line','BorderColor',theme.Border, ...
        'BackgroundColor',theme.PanelBackground);
    panel.Layout.Row = row;
    panel.Layout.Column = col;

    pg = uigridlayout(panel,[1 1]);
    pg.Padding = [10 8 10 6];
    pg.BackgroundColor = theme.PanelBackground;

    ax = uiaxes(pg);
    ax.Color = theme.PanelBackground;
    ax.XColor = theme.TextMuted;
    ax.YColor = theme.TextMuted;
    ax.GridColor = theme.Border;
    ax.Box = 'off';
    ax.XGrid = 'on';
    ax.YGrid = 'on';
    hold(ax,'on');

    ymax = max([cErr(:);qErr(:)]);
    if ymax <= 0, ymax = 1; end
    ymax = 1.08*ymax;

    outagePatch = patch(ax, ...
        [metrics.outageStart_s metrics.outageEnd_s metrics.outageEnd_s metrics.outageStart_s], ...
        [0 0 ymax ymax], ...
        [0.97 0.92 0.92], ...
        'EdgeColor','none', ...
        'FaceAlpha',0.55);

    cLine = plot(ax,t,cErr,'Color',theme.Classical,'LineWidth',1.3);
    qLine = plot(ax,t,qErr,'Color',theme.Quantum,'LineWidth',1.3);

    cursor = plot(ax,[t(1) t(1)],[0 ymax],'--', ...
        'Color',theme.TextPrimary,'LineWidth',1.0);

    xlim(ax,[t(1) t(end)]);
    ylim(ax,[0 ymax]);
    title(ax,titleText,'FontWeight','bold');
    ylabel(ax,yLabel);
    xlabel(ax,'Time [s]');

    legend(ax,{'GPS outage','Classical','Quantum-aided','Replay cursor'}, ...
        'Location','northeast','Box','off');
end
