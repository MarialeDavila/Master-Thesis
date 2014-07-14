%% Utilities

%% Segmentation

% Segmentation (graph based - Pedro)
imwrite(rgb2gray(Image1),'image.ppm');
system('./segment/segment 1 100 10 ./image.ppm image_out.ppm');
image_segmented_gt=imread('image_out.ppm');

% Segmentation EDISON
[fimage, labels] = edison_wrapper(I1, RGB2Lab, 'synergistic', false, 'RangeBandWidth', 3);
figure(220); imagesc(labels)

% segmentation (supervoxels)
SupervoxelSegmentation_PATH=' ../code_eval_supervoxel/libsvx.v2.0/';
addpath(genpath(SupervoxelSegmentation_PATH));
Nystrom_video('../code_eval_supervoxel/libsvx.v2.0/example/frames_ppm', '../code_eval_supervoxel/libsvx.v2.0/example/output_nys', 10, 100, 5, 1, 1, 0)

% segmentation (contours2regions - arbelaez)
dir_seg='../contours2regions_arbelaez/BSR/grouping/lib';
addpath(genpath(dir_seg));
% compute globalPb on a BSDS image (5Gb of RAM required)
imwrite(I,'image.jpg');
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
% figure;imshow(bdry);
% figure;imshow(labels,[]);colormap(jet);

%% Generate regions in different positions and scales
% -----------------------------------------------------------
% Generate new mask based on shift of the previous mask
mask_initial=new_mask(I1,single(rgb2gray(I)),mask_initial);
% -----------------------------------------------------------


%% Convertion of color space

%-----------RGB normalized------------
%     Image1_rgb
ImgR=double(Image1(:,:,1));
ImgG=double(Image1(:,:,2));
ImgB=double(Image1(:,:,3));
sum_img=sum(Image1,3);
Img_R=ImgR./sum_img;
Img_G=ImgG./sum_img;
Img_B=ImgB./sum_img;
ImgRGB_norm(:,:,1)=Img_R;
ImgRGB_norm(:,:,2)=Img_G;
ImgRGB_norm(:,:,3)=Img_B;
%-------------------------------------

% Convertion RGB to HSV
Image1_hsv=rgb2hsv(Image1);

%% Color Histograms concatenated channels
nbins=256;
hist_color=zeros(3,nbins);
for channel=1:3
    Image_one_segment=Image(:,:,channel);
    Image_one_segment(labels~=i)=[];
    vector_one_channel=reshape(Image_one_segment,[1 numel(Image_one_segment)]);
    % color histogram
    hist_color(channel,:)=hist(vector_one_channel,0:nbins-1);
end
% color_hist(i,:)=max(hist_color);     % gmm?
color_hist(i,:)=reshape(permute(hist_color,[2 1]),[1,nbins*3]);   % concatenate histograms

%% Choose segments overlaped with groundtruth
segments_fg=double(labels).*mask_initial;  % mask
% image_mask=multiTimes(image_segmented,mask_initial,5); %function modified from piotr' toolbox
label_segments_fg=unique(segments_fg);
% Delete label 0 - background
label_segments_fg(label_segments_fg==0)=[];
% Number of segments labeled like foreground
numSegmentsFg=numel(label_segments_fg);

% Choose segments overlaped with foreground
NumSegments=max(max(labels));  % Number of segments on image

segments_label_fg=zeros(size(labels));
label_segments_fg=[];
for i=1:NumSegments
    fg_segment=zeros(size(labels));
    fg_segment(labels==i)=1;             % mask segment
    area_segment=sum(sum(fg_segment));   % area segment
    overlapped_area_segment=sum(sum(fg_segment.*mask_initial)); % overlap
    s =overlapped_area_segment/area_segment;
    threshold=0.5;
    if (s >= threshold)
        label_segments_fg=[label_segments_fg i];
        segments_label_fg(labels==i)=1;
    end
end
% Number of segments labeled like foreground
numSegmentsFg=numel(label_segments_fg);

if FlagFigures
    figure(10), imshow(segments_label_fg)
end

%% Renames files
FilesPath='/home/mariale/Documents/codes/codes_others/FastVideoSegment/Data/inputs/MCCD/';
list_dir=dir([FilesPath,'/*.ppm']);
% id=true(1,numel(list_dir));
% id(1:2)=false;
list_name={list_dir.name};
N=numel(list_name);
for i=1:N
    %     name=['video11_' sprintf('%02d',i) '.jpg'];
    name=[sprintf('%08d',i) '.jpg'];
    system(['mv ', FilesPath, list_name{i}, ' ', FilesPath, name]);
end
%% Centroids
edges=(pairwise_matrix);
% compute centroids
cX=ones(1,NumSegments);
cY=ones(1,NumSegments);
for i=1:NumSegments
    [idx idy]=find(labels==i);
    idX=unique(idx);
    idY=unique(idy);
    cX(1,i)=fix(mean(idX));
    cY(1,i)=fix(mean(idY));
    % find pixel nearest to centroid within segment
    [dummy,id]=min(pdist2([idx idy],[mean(idX) mean(idY)]));
    if dummy <= 10
        cX(1,i)=idx(id);
        cY(1,i)=idy(id);
    else
        mask=zeros(size(labels));
        mask(labels==i)=1;
        figure (1), imshow(mask), hold on,
        plot(idy(id),idx(id),'r.','MarkerSize',12),
        plot(cY(1,i),cX(1,i),'g.','MarkerSize',12),
        hold off
        h=impoint;
        point=wait(h);
        cX(1,i)=point(2);
        cY(1,i)=point(1);
        close figure 1
    end
end


%% pairwise
% code of pairwise taken of a fragment of compute_score_contour2
% Pairwise term of the minimization equation
pairwise_matrix=sparse(NumSegments,NumSegments);
for i=1:size(labels,1)-1
    for j=1:size(labels,2)-1
        if labels(i,j)~=labels(i+1,j)
            pairwise_matrix(labels(i,j),labels(i+1,j))=1;
            pairwise_matrix(labels(i+1,j),labels(i,j))=1;
        else
            if labels(i,j)~=labels(i,j+1)
                pairwise_matrix(labels(i,j),labels(i,j+1))=1;
                pairwise_matrix(labels(i,j+1),labels(i,j))=1;
            else
                if labels(i,j)~=labels(i+1,j+1)
                    pairwise_matrix(labels(i,j),labels(i+1,j+1))=1;
                    pairwise_matrix(labels(i+1,j+1),labels(i,j))=1;
                end
            end
        end
    end
end
[id1 id2]=find(pairwise_matrix);
data_pair1=descriptor_new(id1,:);
data_pair2=descriptor_new(id2,:);

distance_seg2seg=pdist2(data_pair1,data_pair2);
% similarity_seg2seg=exp(-distance_seg2seg);
% similitude_seg2seg=1./(1+distance_seg2seg);
media_seg=mean(mean(distance_seg2seg));
similarity_keyseg=exp(-params.gamma*distance_seg2seg/media_seg);
% weight_edges_minus=data_pair1-data_pair2;
edges_costs=diag(similarity_keyseg);
pairwise=params.omega*pairwise_matrix;
pairwise(pairwise_matrix==1)=edges_costs;

%% Unary term
% Compute unary term for every node of the graph

% k - neighbors
k=2;
% alpha=params.alpha;
% beta=params.beta;

% distance each segment to bg model
if sum(~id_label_fg)~=0
    desc_bg=descriptor_gt(~id_label_fg,:);
    distance_bg=pdist2(desc_bg,descriptor_new,'chisq');
    sort_distance_bg=sort(distance_bg,1);
    data_term_bg=mean(sort_distance_bg(1:k,:),1);
else
    data_term_bg=10*ones(1,NumSegments);
end

% distance each segment to fg model
if sum(id_label_fg)~=0
    desc_fg=descriptor_gt(id_label_fg,:);
    distance_fg=pdist2(desc_fg,descriptor_new,'chisq');
    sort_distance_fg=sort(distance_fg,1);
    data_term_fg=mean(sort_distance_fg(1:k,:),1);
else
    data_term_fg=10*ones(1,NumSegments);
end

% Unary term => data term
% Distance => closer to 0 if belongs to this class
data_term=[data_term_bg; data_term_fg];

% % data term normalized 0 - 1
% data_term_norm=( data_term- min(min(data_term)) ) / range(reshape(data_term,[1,numel(data_term)]));
% data_term=data_term_norm;

% Penalize according to Target Score
% Sum the target score for each segment, to the opposite class to
% increase the distance value
lim_inferior_ts=-1; range_ts=2;
target_score=(target_score'-(lim_inferior_ts))/range_ts; % normalized ts
target_score_penalty=[target_score; 1-target_score];
data_term = data_term + alpha*target_score_penalty;

%% Unary term
% computing an unique distances among descriptors, not separately
% distance each segment to bg model
if sum(~id_label_fg)~=0
    desc_bg=descriptor_gt(~id_label_fg,:);
    distance_bg=pdist2(desc_bg,descriptor_new,'chisq');
    if sum(~id_label_fg)<4
        data_term_bg=mean(distance_bg,1);
    else
        sort_distance_bg=sort(distance_bg,1);
        data_term_bg=mean(sort_distance_bg(1:k,:),1);
    end
else
    data_term_bg=ones(1,NumSegments);
end

% distance each segment to fg model
if sum(id_label_fg)~=0
    desc_fg=descriptor_gt(id_label_fg,:);
    distance_fg=pdist2(desc_fg,descriptor_new,'chisq');
    if sum(id_label_fg)<4
        data_term_fg=mean(distance_fg,1);
    else
        sort_distance_fg=sort(distance_fg,1);
        data_term_fg=mean(sort_distance_fg(1:k,:),1);
    end
else
    data_term_fg=ones(1,NumSegments);
end
%     % data term normalized 0 - 1
%     %background
%     min_dt_bg=min(min(data_term_bg));
%     range_dt_bg=range(reshape(data_term_bg,[1,numel(data_term_bg)]));
%     data_term_bg = (data_term_bg-min_dt_bg) / range_dt_bg;
%     % foreground
%     min_dt_fg=min(min(data_term_fg));
%     range_dt_fg=range(reshape(data_term_fg,[1,numel(data_term_fg)]));
%     data_term_fg = (data_term_fg-min_dt_fg) / range_dt_fg;

%% Normalize
% data term normalized 0 - 1
min_dt=min(min(data_term));
range_dt=range(reshape(data_term,[1,numel(data_term)]));
data_term_norm = (data_term-min_dt) / range_dt;

%% find points sorted in a contour vector
%  1st option
% bw => image
[x y]=find(bw==1);
id=[x y];
for i =1 :11944
    idx=id(i,:);
    dist=pdist2(id,idx,'euclidean');
    [dist_sorted position]=sort(dist);
    point1=id(position(2,:),:);
    point2=id(position(3,:),:);
end
% 2nd option
[x y]=find(bw==1);
id=[x y];
dist2=pdist2(id,id,'euclidean');
[dist_sorted position2]=sort(dist2,1);
point1=id(position2(2,:),:);
point2=id(position2(3,:),:);


%% Plot 3D histogram
% plot cuboid of color histogram
% hist_segment => [n x n x n]
bins=1:8;
x=reshape(repmat(bins,8,8),1,[]);
y=repmat(bins,1,64);
z=reshape(repmat(bins,64,1),1,[]);

s=hist_segment(:)+1;
s=300*s/max(s);
% s=repmat(300,1,512);

color=1:256/8:255;
cx=reshape(repmat(color,8,8),[],1);
cy=reshape(repmat(color,1,64),[],1);
cz=reshape(repmat(color,64,1),[],1);

c=[cx,cy,cz];
c=c/256;

figure,
scatter3(x,y,z,s,c,'filled'), view(135,35)

%% GMM
% imdir => image directory
% Segs.Proposals
% Segs.imname
% Segs.frameNdx
% selind => indexes of the key hypotheses of the video
% Param.FgNbStates
% Param.BgNbStates

% Visualize frames
figure
for i=1:150
    imshow(mask{1,i})
    drawnow
end

%% comments
% if Nframe==2
% image with groundtruth
% Compute descriptors for segments of initial frame
[color_histogram_gt, HOOF_gt]=compute_descriptors(Image1,of_dx,of_dy,labels_frame1,NumSegmentsGT);
% Merge descriptors to build Color and Movement Models
% to Background and Foreground
model.color_fg=color_histogram_gt(id_label_fg,:);
model.color_bg=color_histogram_gt(~id_label_fg,:);

model.movement_fg=HOOF_gt(id_label_fg,:);
model.movement_bg=HOOF_gt(~id_label_fg,:);
% end

%---------------------------------

% %% Build Model of Object by color and movement
% % Merge descriptors to build Color and Movement Models
% % to Background and Foreground
% labels_out=logical(labels_out);
% model.color_fg=[model.color_fg; color_histogram_new(labels_out,:)];
% model.color_bg=[model.color_bg; color_histogram_new(~labels_out,:)];
%
% model.movement_fg=[model.movement_fg; HOOF_new(labels_out,:)];
% model.movement_bg=[model.movement_bg; HOOF_new(~labels_out,:)];

%% Review error in cluster jobs
% load output file and create unique data file
ErrorPath='./../results/error/joberror/';
list=dir(ErrorPath);
NameFiles={list(3:end).name};
NumFiles=numel(NameFiles);
Error=cell(NumFiles,1);
idJob=zeros(NumFiles,1);
for i=1:NumFiles
    Name=NameFiles{i};
    strName=textscan(Name,'%s','Delimiter','-');
    
    idJob(i)=str2double(strName{1}{2});
    idFile=fopen([ErrorPath Name]);
    Error{i}=fscanf(idFile,'%s');
    fclose(idFile);
end

Error1=cell(1,1);
k=1; idError=[];
for i=1:640
    if ~isempty(Error{i})
        Error1{k,1}=Error{i};
        k=k+1;
        idError=[idError; idJob(i)];
    end
end

idArrayToRepeat=[];
for i=1:NumFiles
    if ~isempty(Error{i}) %%&& ~strcmp(Error{i}(1:21),'Licensecheckoutfailed')
        idArrayToRepeat=[idArrayToRepeat, idJob(i)];
    end
end

% ---------------------------------------------------------------------
% load output file and create unique data file
ErrorPath='./../results/error/joboutput/';
list=dir(ErrorPath);
NameFiles={list(3:end).name};
NumFiles=numel(NameFiles);
Out=cell(NumFiles,1);
idJob=zeros(NumFiles,1);
for i=1:NumFiles
    Name=NameFiles{i};
    strName=textscan(Name,'%s','Delimiter','-');
    
    idJob(i)=str2double(strName{1}{2});
    if idJob(i)==412 || idJob(i)==416 || idJob(i)==478
        break
    end
    idFile=fopen([ErrorPath Name]);
    Out{i}=fscanf(idFile,'%s');
    fclose(idFile);
end

idArrayBad=[];
for i=1:NumFiles
    if ~isempty(Out{i}) %&& ~strcmp(Out{i}(1:21),'Licensecheckoutfailed')
        idArrayBad=[idArrayBad, idJob(i)];
    end
end

IdEmpty=[]; idbad=[]; idgood=[];
for i=1:numel(Out)
    msge=Out{i};
    if isempty(msge)
        IdEmpty=[IdEmpty,idJob(i)];
    else
        if strcmp(msge(1:7),'Jobdone')
            idgood=[idgood,idJob(i)];
        end
        if strcmp(msge(3:26),'Warning:Matrixissingular')
            idbad=[idbad,idJob(i)];
        end
    end
end

%%
output_path='../results/experiments/moseg_dataset/GMM/';
list=dir(output_path);
NameFiles={list(3:end).name};
ArrayIdFailed=[];
for i=1:numel(NameFiles)
    load([output_path NameFiles{i}])
    if exist('Overlap','var')==1 && exist('IdFramesWithGT','var')==1 && exist('OutputMetrics','var')==1
        disp('ok')
    else
        ArrayIdFailed=[ArrayIdFailed, idJob(i)];
    end
    clear Overlap IdFramesWithGT OutputMetrics
end

%% Visualizaciones

NumSegments=double(max(max(labels)));  % Number of segments on image
sizeLabels=numel(labels);
Rsegment=zeros(size(labels));Gsegment=zeros(size(labels));Bsegment=zeros(size(labels));

ColorPerSegment=255*uniqueColors(20,90);
order=randperm(NumSegments);
for i=1:NumSegments
    id=find(labels==i);
    Rsegment(id)=ColorPerSegment(order(i),1);
    Gsegment(id)=ColorPerSegment(order(i),2);
    Bsegment(id)=ColorPerSegment(order(i),3);
end

img_out(:,:,1)=Rsegment; img_out(:,:,2)=Gsegment; img_out(:,:,3)=Bsegment;
img_out=uint8(img_out);
if FlagFigures
    figure(50000),
    imshow(img_out);
end

figure(1500), clims=[0 1];
subplot(121),
imagesc(ImageSeg_dist_color_bg,clims); axis image; axis off; colorbar
title('Unary term related to Color in background model')
subplot(122),
imagesc(ImageSeg_dist_color_fg,clims); axis image; axis off; colorbar
title('Unary term related to Color in foreground model')

figure,  clims=[0 1];
subplot(121),
imagesc(ImageSeg_dist_of_bg,clims); axis image; axis off; colorbar
title('Unary term related to Movement in background model')
subplot(122),
imagesc(ImageSeg_dist_of_fg,clims); axis image; axis off; colorbar
title('Unary term related to Movement in foreground model')

figure(152), clims=[0 1];
subplot(121),
imagesc(ImageSeg_DataTerm_wP_bg,clims); axis image; axis off; colorbar
title('Unary term of color and movement in background model')
subplot(122),
imagesc(ImageSeg_DataTerm_wP_fg,clims); axis image; axis off; colorbar
title('Unary term of color and movement in foreground model')

subplot(121),
imagesc(ImageSeg_DataTerm_bg,clims); axis image; axis off; colorbar
title('Unary term overall in background model')
subplot(122),
imagesc(ImageSeg_DataTerm_fg,clims); axis image; axis off; colorbar
title('Unary term overall in foreground model')

%--
psbg=2*(data_term_bg-0.5*data_term_wP_bg);
psfg=2*(data_term_fg-0.5*data_term_wP_fg);
PS_bg=zeros(size(labels));
PS_fg=zeros(size(labels));
for i=1:NumSegments
    PS_bg(labels==i)=psbg(i);
    PS_fg(labels==i)=psfg(i);
end
subplot(121),
imagesc(PS_bg,clims); axis image; axis off; colorbar
title('Unary term related to Points Score in background model')
subplot(122),
imagesc(PS_fg,clims); axis image; axis off; colorbar
title('Unary term related to Points Score in foreground model')