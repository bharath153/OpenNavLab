function card = create_kpi_card(parent, theme, titleText, valueText, detailText)
%CREATE_KPI_CARD Create a restrained KPI card.

    panel = uipanel(parent,'BorderType','line', ...
        'BorderColor',theme.Border,'BackgroundColor',theme.PanelBackground);

    grid = uigridlayout(panel,[3 1]);
    grid.RowHeight = {18,30,18};
    grid.Padding = [12 8 12 8];
    grid.RowSpacing = 2;
    grid.BackgroundColor = theme.PanelBackground;

    titleLabel = uilabel(grid,'Text',upper(titleText),'FontSize',9, ...
        'FontWeight','bold','FontColor',theme.TextMuted);

    valueLabel = uilabel(grid,'Text',valueText,'FontSize',22, ...
        'FontWeight','bold','FontColor',theme.TextPrimary);

    detailLabel = uilabel(grid,'Text',detailText,'FontSize',10, ...
        'FontColor',theme.TextSecondary);

    card.Panel = panel;
    card.Title = titleLabel;
    card.Value = valueLabel;
    card.Detail = detailLabel;
end
