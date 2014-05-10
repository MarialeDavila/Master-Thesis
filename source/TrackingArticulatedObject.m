function [OutputMask]=TrackingArticulatedObject(NameVideo,Params)
% Object Tracking in Video
%
% INPUTS:
% NameVideo          - Name video (string)
%                    - 'cars1'-'cars10', 'marple1'-'marple13', 'people1',
%                    - 'people2' or 'tennis'
% Params             - Parameters values set for the tracking method (struct)
%                    - .alpha := Defined from 0 to 1
%                    - .beta  := Defined from 0 to 1
%                    - .omega := Defined like a positive value
%
% OUTPUT:
% OutputMask         - is locations of cluster centers (cell = 1xnumFrames)
%                    - mask of contours, 0's and 1's 
%
%
% Maria Alejandra Davila Salazar April.2014
% References:
% - "Dynamic Objectness for Adaptive Tracking"
%   Stalder, S., Grabner, H., & Van Gool, L. ACCV 2012
% % 

%% Initialization

% path libraries
libs_PATH='./../libs/';
% add libraries paths
addpath(genpath(libs_PATH));

% path video frames
% VideoPath=['./../../dataset/moseg_dataset/', NameVideo, '/'];
VideoPath=['/share/storage/vision/mariale/dataset/moseg_dataset/', NameVideo, '/'];

% Initial Parameters 
% FlagFigures        - Display graphics with results of tracking (logical)
%                    - true or false ; 1 or 0
FlagFigures=0;
% MethodClustering   - Name of method to cluster points (string)
%                    - 'MeanShift', 'Graph-Based' or 'GANC'
MethodClustering='MeanShift';


% Get video frames and extract features per image
data = GetVideoFrames(VideoPath);
MaskGT = GetGroundtruth(VideoPath);
features = GetFeaturesPerFrame(data,NameVideo);

% First video frame
I_color=data.Image{1};
I = rgb2gray(I_color);
% Ground truth mask of the first frame
InitialGT=MaskGT{1,1};

% Detect inital interest points
% Initializate set of Object-Scene-Unseen points
points=InitializatePoints(I,InitialGT,features,FlagFigures);

% Create model SIFT to every object point
[model points]=BuildModelSIFT(points,features);

NumFrames=numel(data.Image);
OutputMask=cell(1,NumFrames);
OutputMask{1,1}=InitialGT;
PreviousMask=InitialGT;
I2=I; Image2=I_color;

% video
SaveName_Video=['./../results/output/output_',NameVideo,'_a:',num2str(Params.alpha),'_b:',num2str(Params.beta),'_w:',num2str(Params.omega),'.avi'];
VideoObject = VideoWriter(SaveName_Video);
open(VideoObject);

% ticid = ticStatus('tracking');
for idFrame=2:NumFrames
    %% Get new frames
    Image1=Image2;
    I1 = I2;
    Image2 = data.Image{idFrame};  % Get new frame
    I2 = rgb2gray(Image2);
    %% Propagation
    % Track all local image features in the image, Object-Scene-Unseen
    [points] = PropagatePoints(points,data,features,idFrame,FlagFigures);
    %% Detection
    % Detect local image features add them to Unknow
    unknown=DetectUnknowPoints(points,features,idFrame);
    % Find matches of Unseen with target model and Update Object points
    if ~isempty(unknown)
        [model, points]=AddUnknownToModelAndPoints(unknown,model,points,features,idFrame);
    end
    
    %% Visualize points
    if FlagFigures
        figure(205);
        PlotPointsAndContour(I1, points, PreviousMask)
    end
    
    %% Exploring and Grouping
    groups=ClusteringPoints(points,features,idFrame,MethodClustering);
    % Visualize groups of points
    if FlagFigures
        points_alive=points.position(~points.type.dead,:);
        visualize_clustering(I2,groups,points_alive,MethodClustering);
    end
    
    % Get possible object regions - differents scale, aspect ratio, position, shape
    % Compute dynamic objectness score and target score
    [ActualMask, model,VideoObject]=ComputeSegmentsFeatures(PreviousMask,data,features,points,model,groups,idFrame,FlagFigures,Params,VideoObject);
    % Update object model
    % update involves changing the object and scene points
    [points, model]=UpdatePointsAndModel(ActualMask,points, model, I2);
    
    %% Visualize points updated
    if FlagFigures
        figure(210); 
        PlotPointsAndContour(Image2, points, ActualMask)
    end
    
    OutputMask{1,idFrame}=ActualMask;
    PreviousMask=ActualMask;
    %     tocStatus(ticid, i/NumFrames)
end
close(VideoObject);
