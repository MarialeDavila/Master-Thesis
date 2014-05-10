function labels = segmentation(image, method)
% Image Segmentation
%
% INPUTS:
% image                - Matrix of data image
% MethodSegmentation   - Name of method to segment image(string)
%                      - 'graph-based', 'EDISON', 'supervoxels',
%                      - or 'contours2regions'
%
% OUTPUT:
% labels               - Matrix indicating label of segment belong every pixel
%

switch method
    
    case 'graph-based'
        % Segmentation (graph based - Pedro)
        imwrite(image,'image.ppm');
        system('./../libs/segment/segment 1 200 50 ./image.ppm image_out.ppm');   % 100 10
        image_segmented=imread('image_out.ppm');
        % numerizeLabels function -> code "What is an object?" (view LICENSE.TXT)
        labels=numerizeLabels(image_segmented); %label segments
        
    case 'EDISON'
        % Segmentation EDISON
        R=image(:,:,1);
        G=image(:,:,2);
        B=image(:,:,3);
        image_gray=rgb2gray(image);
        [image_segmented, labels] = edison_wrapper(image_gray, rgb2lab(R,G,B), 'synergistic', false, 'RangeBandWidth', 3);
        
    case 'supervoxels'
        % segmentation (supervoxels)
        SupervoxelSegmentation_PATH='./../../codes_others/code_eval_supervoxel/libsvx.v2.0/';
        addpath(genpath(SupervoxelSegmentation_PATH));
        Nystrom_video('./../../codes_others/code_eval_supervoxel/libsvx.v2.0/example/frames_ppm', '../code_eval_supervoxel/libsvx.v2.0/example/output_nys', 10, 100, 5, 1, 1, 0)
        
    case 'contours2regions'
        % segmentation (contours2regions - arbelaez)
        image_gray=rgb2gray(image);
        dir_seg='./../../codes_others/contours2regions_arbelaez/BSR/grouping/lib';
        addpath(genpath(dir_seg));
        % compute globalPb on a BSDS image (5Gb of RAM required)
        imwrite(image_gray,'image.jpg');
        tic; gPb_orient = globalPb('image.jpg', 'image_out'); toc
        % for boundaries
        tic; ucm = contours2ucm(gPb_orient, 'imageSize'); toc;
        % for regions
        tic; ucm2 = contours2ucm(gPb_orient, 'doubleSize'); toc %double sized ucm
        % convert ucm to the size of the original image
        ucm = ucm2(3:2:end, 3:2:end);
        % get the boundaries of segmentation at scale k in range [0 1]
        k = 0.1;
        bdry = (ucm >= k);
        % get superpixels at scale k without boundaries:
        labels2 = bwlabel(ucm2 <= k);
        labels = labels2(2:2:end, 2:2:end);
        % figure;imshow(ucm);
        % %         figure;imshow(bdry);
        % figure;imshow(labels,[]);colormap(jet);
        image_segmented=label2rgb(labels);
        
    case 'SLIC'
        % Segmentation (SLIC)
        NumberSuperpixels=1500;
        Compactness=30;
        labels=SLIC_mex(image, NumberSuperpixels, Compactness);
        
    otherwise
        fprintf('%s','Invalid Method')
end



