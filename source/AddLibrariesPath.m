function AddLibrariesPath()
% Add libraries path
libs_PATH='./../libs/';
% add libraries paths
addpath(genpath(libs_PATH));

% add only necessary directories to VLFEAT toolbox
vlfeat_PATH=[libs_PATH,'vlfeat-0.9.16/'];
rmpath(genpath(vlfeat_PATH));
addpath(genpath([vlfeat_PATH, 'toolbox/']));
rmpath(genpath([vlfeat_PATH,'toolbox/mex/']));
addpath(genpath([vlfeat_PATH,'toolbox/mex/',mexext]));
% run(cat(2,vlfeat_PATH,'toolbox/vl_setup'))

