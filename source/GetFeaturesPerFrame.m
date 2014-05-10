function features = GetFeaturesPerFrame(data, NameVideo)

% Load features file if exist else compute features
FeaturesFile=['./../data/features/','features_',NameVideo,'.mat'];

if exist(FeaturesFile,'file')==2   % if exist file .mat
    load(FeaturesFile)
    % Verify if exist the labels for a different method of segmentation
    SegmentationMethod ='SLIC';
    if ~isfield(features.Segmentation,SegmentationMethod)
        NumberFrames=numel(data.Image);
        for idFrame=1:NumberFrames
            Image=data.Image{idFrame};
            SegmentationLabels = segmentation(Image,SegmentationMethod);
            features.Segmentation.(SegmentationMethod){idFrame}=double(SegmentationLabels);
        end
    end
else
    % Compute Features Per fame
    NumberFrames=numel(data.Image);
    for idFrame=1:NumberFrames
        tic
        Image=data.Image{idFrame};
        ImageGray=rgb2gray(Image);
        
        % Point Detection [X Y]
        features.points{idFrame} = corner(ImageGray, 'MinimumEigenvalue',1000);
        
        % Compuet SIFT
        features.sift{idFrame} = ComputeSIFT(ImageGray,features.points{idFrame});
        
        % Compute Optical Flow (Piotr's toolbox)
        if idFrame==1
            % Assumptions: First video frame OF will be consider equal to second OF
            Image2=data.Image{idFrame+1};
            ImageGray2=rgb2gray(Image2);
            [OFdx OFdy reliability]=Optical_Flow_FW_BW(ImageGray,ImageGray2);
        else
            ImageGrayPrevious=rgb2gray(ImagePrevious);
            [OFdx OFdy reliability]=Optical_Flow_FW_BW(ImageGrayPrevious,ImageGray);
        end
        features.OpticalFlow.dx{idFrame}=OFdx;
        features.OpticalFlow.dy{idFrame}=OFdy;
        features.OpticalFlow.reliability{idFrame}=reliability;
        
        % Segmentation
        SegmentationMethod ='SLIC'; %contours2regions
        SegmentationLabels = segmentation(Image,SegmentationMethod);
        features.Segmentation.(SegmentationMethod){idFrame}=double(SegmentationLabels);
        
        ImagePrevious=Image;
        TimeFrame=toc; disp(['Frame ' num2str(idFrame) ' ... ' num2str(TimeFrame) ' seconds'])
    end
    
end
% Save features computed
save(['./../data/features/','features_',NameVideo,'.mat'],'features','-v7.3')
