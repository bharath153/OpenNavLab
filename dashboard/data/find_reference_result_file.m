function fileName = find_reference_result_file(baseName)
%FIND_REFERENCE_RESULT_FILE Locate an OpenNavLab reference result artifact.
%
% Priority:
%   1) Original repository results/data when dashboard is installed as
%      OpenNavLab/dashboard.
%   2) Bundled dashboard/data/reference fallback for standalone use.

    thisFile = mfilename('fullpath');
    dataFolder = fileparts(thisFile);
    dashboardRoot = fileparts(dataFolder);
    repositoryRoot = fileparts(dashboardRoot);

    repoCandidate = fullfile(repositoryRoot,'results','data',baseName);
    bundledCandidate = fullfile(dataFolder,'reference',baseName);

    if isfile(repoCandidate)
        fileName = repoCandidate;
        return;
    end

    if isfile(bundledCandidate)
        fileName = bundledCandidate;
        return;
    end

    error('OpenNavLab:Dashboard:MissingReferenceArtifact', ...
        'Could not locate reference result file: %s',baseName);
end
