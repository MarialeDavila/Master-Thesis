%% 
% This is a very simple Matlab interface to run GANC
% Please see README.txt and make sure the C++ program
% is compiled prior to using this script
%% plotting parameters
MarkerSize = 12;
LineWidth = 2;
FontSize = 18; 
AxisFontSize = 16; 

%% 
k_range = [1:10]; % the range in which curvature is plotted


% fname = './example_networks/zachary';
% netfname = './example_networks/zachary.wpairs';
% system(['./ganc --one-based -f ' netfname]); 

fname='output';
netfname='output.wpairs';
system(['/home/mariale/Documents/codes/codigos_prueba/ganc_v1.0/ganc --one-based -f ' netfname]);


curv = load(strcat(fname,'.curv'));
n = size(curv,1);

NAssoc = load(strcat(fname,'.nassoc'));
% % 
% % subplot(2,1,1); 
% % plot(NAssoc(:,1),NAssoc(:,2),'LineWidth',LineWidth)
% % set (gca, 'FontSize', AxisFontSize);
% % ylabel('Normalized Association');
% % xlabel('k');
% % subplot(2,1,2); 
% % plot(curv(k_range,1),curv(k_range,2),'LineWidth',LineWidth)
% % set (gca, 'FontSize', AxisFontSize);
% % ylabel('Curvature');
% % xlabel('k');


k = input('Enter k: ');

% now run a flat partitioning with refinement
system(['/home/mariale/Documents/codes/codigos_prueba/ganc_v1.0/ganc --one-based -f ' netfname ' --refine -c ' num2str(n-k) ]);

% the final partitioning result
c = load(strcat(fname,'.groups2'))
