function data = load_dashboard_case(caseSource)
%LOAD_DASHBOARD_CASE Load a dashboard-compatible single-run result.

    if nargin < 1 || isempty(caseSource)
        data = load_builtin_single_run_results();
        return;
    end

    if isstruct(caseSource)
        data = caseSource;
        validateCase(data);
        return;
    end

    if ischar(caseSource) || isstring(caseSource)
        fileName = char(caseSource);
        if ~isfile(fileName)
            error('OpenNavLab:Dashboard:MissingFile', ...
                'Dashboard case file not found: %s',fileName);
        end

        % Directly recognize the repository Phase 7B MAT schema.
        raw = whos('-file',fileName);
        names = {raw.name};
        if all(ismember({'truth','classical_ekf','quantum_aided_ekf','gps','imu','quantum'},names))
            data = load_builtin_single_run_results(fileName);
            return;
        end

        data = adapt_opennavlab_results(fileName);
        validateCase(data);
        return;
    end

    error('OpenNavLab:Dashboard:UnsupportedSource', ...
        'caseSource must be empty, a struct, or a MAT-file path.');
end

function validateCase(data)
    required = {'time','truth','classical','quantum','gps','errors','meta'};
    for k = 1:numel(required)
        if ~isfield(data,required{k})
            error('Missing field data.%s',required{k});
        end
    end

    n = numel(data.time);
    assert(size(data.truth.position,1)==n,'truth.position length mismatch.');
    assert(size(data.classical.position,1)==n,'classical.position length mismatch.');
    assert(size(data.quantum.position,1)==n,'quantum.position length mismatch.');
    assert(numel(data.gps.outageMask)==n,'gps.outageMask length mismatch.');
    assert(numel(data.quantum.updateMask)==n,'quantum.updateMask length mismatch.');
end
