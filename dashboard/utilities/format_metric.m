function txt = format_metric(value, unit, digits)
%FORMAT_METRIC Consistent numeric formatting.

    if nargin < 3, digits = 2; end
    if nargin < 2, unit = ''; end

    if isnan(value)
        txt = '--';
        return;
    end

    fmt = sprintf('%%.%df',digits);
    txt = sprintf(fmt,value);

    if ~isempty(unit)
        txt = sprintf('%s %s',txt,unit);
    end
end
