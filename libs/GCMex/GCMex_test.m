
W = 10;
H = 5;
segclass = zeros(50,1);
pairwise = sparse(50,50);
unary = zeros(7,25);
[X Y] = meshgrid(1:7, 1:7);
labelcost = min(4, (X - Y).*(X - Y));

for row = 0:H-1
  for col = 0:W-1
    pixel = 1+ row*W + col;
    if row+1 < H, pairwise(pixel, 1+col+(row+1)*W) = 1; end
    if row-1 >= 0, pairwise(pixel, 1+col+(row-1)*W) = 1; end 
    if col+1 < W, pairwise(pixel, 1+(col+1)+row*W) = 1; end
    if col-1 >= 0, pairwise(pixel, 1+(col-1)+row*W) = 1; end 
    if pixel < 25
      unary(:,pixel) = [0 10 10 10 10 10 10]'; 
    else
      unary(:,pixel) = [10 10 10 10 0 10 10]'; 
    end
  end
end

[labels E Eafter] = GCMex(segclass, single(unary), pairwise, single(labelcost),0);

fprintf('E: %d (should be 260), Eafter: %d (should be 44)\n', E, Eafter);
fprintf('unique(labels) should be [0 4] and is: [');
fprintf('%d ', unique(labels));
fprintf(']\n');




%%
I=imread('image.ppm');
% imwrite(I,'image.ppm');
system('../segment/segment 1 200 50 ./image.ppm image_out.ppm');
image_segmented=imread('image_out.ppm');
% figure (100); imshow(image_segmented);
labels=numerizeLabels(image_segmented); 

% Detector ------------------------
% Input image
inImage = im2double(rgb2gray(I));
% Re-scaling image
scale=512;
inImg = imresize(inImage,[scale,scale],'bilinear');
% Parameters
filtersize=20;
%Spectral Residual
myFFT = fft2(inImg);
myLogAmplitude = log(abs(myFFT));
myPhase = angle(myFFT);
mySmooth = imfilter(myLogAmplitude,fspecial('average',filtersize),'replicate');
mySpectralResidual = myLogAmplitude-mySmooth;
saliencyMAP = abs(ifft2(exp(mySpectralResidual+1i*myPhase))).^2;
%After Effect
saliencyMAP = imfilter(saliencyMAP,fspecial('disk',filtersize));
saliencyMAP = mat2gray(saliencyMAP);
[h,w]=size(inImage);
SaliencyMAP = imresize(saliencyMAP,[h,w],'bilinear');
%----------------------------------

% class=reshape(labels,[1 480*640]);
% unary=reshape(rgb2gray(image_segmented),[1 480*640]);

class=unique(labels);
C=2;
N=max(class);
unary=zeros(C,N);
segclass=zeros(1,N);
score_class=zeros(1,N);
pairwise=zeros(N,N);
img=rgb2gray(image_segmented);
for i=1:N
    id=find(labels==i);
    unary(1,i)=sum(img(id))/numel(id); % average color 
    
    % class
    initial_score=zeros(size(labels));
    initial_score(id)=SaliencyMAP(id); 
    score_class(1,i)=mean(mean(initial_score));
    threshold=min(min(score_class))+0.75*range(range(score_class));
    if score_class>=threshold
        segclass(1,i)=1;
    end
    pairwise(i,i)=1;
end
pairwise=sparse(pairwise);


pairwise_matrix=zeros(N,N);
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
pairwise_matrix=sparse(pairwise_matrix);

% % pairwise term
% pairwise=zeros(N,N);
% dist_matrix=pdist2(repmat(data_term,N,1),repmat(data_term',1,N));
% threshold=min(min(dist_matrix))+0.25*range(range(dist_matrix));
% id=find(dist_matrix<=threshold);
% pairwise(id)=1;
% pairwise=sparse(pairwise);

% labelcost=ones(C,C);
labelcost=[0 1; 1 0];


%%%-------------------------------------
% Visualizar grafo

% pairwise
% edges=zeros(N,N);
% id_random=randi(N*N,1,5);
% edges(id_random)=1;
edges=triu(pairwise_matrix);
% visualize edges

% compute centroids
cX=ones(1,N);
cY=ones(1,N);
for i=1:N
    [idx idy]=find(labels==i);
    idX=unique(idx);
    idY=unique(idy);
    cX(1,i)=fix(mean(idX));
    cY(1,i)=fix(mean(idY));  
    [dummy,id]=min(pdist2([idx idy],[mean(idX) mean(idY)]));
    cX(1,i)=idx(id);
    cY(1,i)=idy(id);
end
[point_initial point_end]=find(edges);
linksXin=cX(point_initial);
linksYin=cY(point_initial);
linksXend=cX(point_end);
linksYend=cY(point_end);
linksX=[linksXin; linksXend];
linksY=[linksYin; linksYend];

figure(200);
% imagesc(labels); 
imshow(image_segmented)
hold on;
plot(cY,cX,'wo','MarkerSize',6,'MarkerFaceColor',[1 1 1])
line(linksY,linksX,'Color',[1 1 1])
hold off;

%%%-------------------------------------


% GCMex test
[labels_out E_out Eafter_out] = GCMex(segclass, single(unary), pairwise_matrix, single(labelcost),0);


%% 
% class=zeros(1,numel(dyn_objectness));
% class(numel(label_segment_overlap_with_mask)+1)=1;
% score_obj=(dyn_objectness).*(target_score);
% if_obj=zeros(1,numel(score_obj));
% if_obj(score_obj>=0)=score_obj(score_obj>=0);
% if_scn=zeros(1,numel(score_obj));
% if_scn(score_obj<0)=score_obj(score_obj<0);
% unary=[if_obj; if_scn];

