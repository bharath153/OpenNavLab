%STARTUP Add OpenNavLab folders to the MATLAB search path.

project_root = fileparts(mfilename('fullpath'));

addpath(fullfile(project_root, 'config'));
addpath(genpath(fullfile(project_root, 'src')));
addpath(fullfile(project_root, 'examples'));

fprintf('OpenNavLab paths added from:
%s
', project_root);
