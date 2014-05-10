function [groups]=ClusteringPoints(points,features,idFrame,MethodClustering)

if nargin<3
    MethodClustering='MeanShift';
end

% Get data of Optical flow
OFdx=features.OpticalFlow.dx{idFrame-1};
OFdy=features.OpticalFlow.dy{idFrame-1};
reliability=features.OpticalFlow.reliability{idFrame-1};

% motion cluster
points_alive=points.position(points.type.dead~=1,:);
numPoints=size(points_alive,1); if (numPoints<31); nn=numPoints-1; else nn=30; end
matrix_affinity=zeros(numPoints,nn);
% matrix_dissimilarity=zeros(numPoints,nn);
% Use unique index for points in format row,col (Piotr's toolbox)
ind_pts=sub2ind2(size(OFdx),fliplr(points_alive));

matrix_dist=pdist2(points_alive,points_alive,'euclidean');
matrix_motion=sqrt(pdist2(OFdx(ind_pts),OFdx(ind_pts),'sqeuclidean')+pdist2(OFdy(ind_pts),OFdy(ind_pts),'sqeuclidean'));
matrix_affinity_dense=exp(-matrix_dist.*matrix_motion);
% matrix_dissimilarity_dense=matrix_dist.*matrix_motion;

idy1=zeros(numPoints,nn);
idx1=1:nn;
idx2=repmat(idx1,numPoints,1);
idx3=reshape(idx2,[],1);
for j=1:numPoints
    [~, id]=sort(matrix_dist(j,:));
    matrix_affinity(j,:)=matrix_affinity_dense(j,id(2:nn+1));
    %     matrix_dissimilarity(j,:)=matrix_dissimilarity_dense(j,id(2:nn+1));
    idy1(j,:)=id(1,2:nn+1);
end
idy2=reshape(idy1',[1,numPoints*nn]);
id_groups=[idx3, idy2'];


% [id1 id2 dist1]=find(sparse(matrix_affinity1));
switch MethodClustering
    case 'MeanShift'
        % clustering meanshift
        % first method
        % cluster by motion (optical flow)
        % datos_cluster=[of_dx(ind_pts) of_dy(ind_pts)];
        % cluster by by position (X Y) - motion (optical flow)
        datos_cluster=[10.*OFdx(ind_pts) 10.*OFdy(ind_pts) points_alive(:,1) points_alive(:,2)];
        DatosCluster=permute(datos_cluster,[2 1]);
        bw=0.05; % 0.1
        bandWidth = (max(max(DatosCluster))-min(min(DatosCluster)))*bw;
        % set initialization seed point
        rng(0)
        [Centers,Data2cluster,Clusters] = MeanShiftCluster(DatosCluster,bandWidth);
        groups=permute(Data2cluster,[2 1]);
        % -----------------------
        dim1=size(groups,1);
        if dim1~=numPoints
            disp(['Id de grupos = ', num2str(dim1), ', diferente a numero de puntos ', num2str(numPoints)])
        end
        % -----------------------
        %         % second method - set the bandwith for every set of data
        %         % cluster by position (X Y) - motion (optical flow)
        %         datos_cluster=[of_dx(ind_pts) of_dy(ind_pts) 0.5.*pts_track(:,1) 0.5.*pts_track(:,2)];
        %         DatosCluster=permute(datos_cluster,[2 1]);
        %         bandWidth = (max(DatosCluster,[],2)-min(DatosCluster,[],2)).*[1e-4; 1e-4; 5e-4; 5e-4];
        %         [Centers,Data2cluster,Clusters] = MeanShiftCluster2(DatosCluster,bandWidth);
        %         groups=permute(Data2cluster,[2 1]);
        
    case 'Graph-Based'
        % clustering Graph-based
        weight_dissimilarity=reshape(permute(matrix_affinity,[2 1]),[numPoints*nn,1]);
        clusters=segmentGraph(int32(id_groups), single(weight_dissimilarity));
        [num id groups]=unique(clusters);
        % -----------------------
        dim1=size(groups,1);
        if dim1~=numPoints
            disp(['Id de grupos = ', num2str(dim1), ', diferente a numero de puntos ', num2str(numPoints)])
        end
        % -----------------------
        
    case 'GANC'
        % clustering GANC
        mkdir TEMP_groups_ganc
        cd TEMP_groups_ganc
        matrix_affin=reshape(permute(matrix_affinity,[2 1]),[numPoints*nn,1]);
        data4cluster=[id_groups matrix_affin*100000];
        data4clustering=permute(data4cluster,[2 1]);
        fid=fopen('data.wpairs','wt');
        fprintf(fid,'%d %d %d \n',data4clustering(:));
        fclose(fid);
        
        system('./../../libs/ganc_v1.0/ganc -f data.wpairs --one-based');
        
        % optimal num_cluster
        eigen_val=eig(matrix_affinity_dense);
        [eigen_values id_eigen]=sort(eigen_val);
        num1=length(eigen_val); cte=1e-4; metric=ones(num1,1);
        for j=1:num1-1
            metric(j,1)=((eigen_values(j+1).^2)/sum((eigen_values(1:j)).^2))+cte*j;
        end
        [value num_cluster]=min(metric);
        n1=numPoints; k=n1-num_cluster;
        system(['./../../libs/ganc_v1.0/ganc -f data.wpairs', ' --one-based -c ',num2str(k),' --refine']);
        cd ..
        
        % read groups
        fid=fopen('./TEMP_groups_ganc/data.groups2');
        if (fid>=3)
            txt_data=textscan(fid, '%s');
            fclose(fid); fclose('all');
            dim1 = size(txt_data{1});
            clusters = zeros(dim1(1)/2,2);
            clusters(:,1) = str2double(txt_data{1}(1:2:end-1));
            clusters(:,2) = str2double(txt_data{1}(2:2:end));
        else
            fid=fopen('./TEMP_groups_ganc/data.groups');
            txt_data=textscan(fid, '%s');
            fclose(fid); fclose('all');
            %             dim1 = size(txt_data{1});
            clusters = ones(numPoints,2);
            clust1=0; IDcluster=cell(1,1);
            for j=1:size(txt_data{1})
                a=str2double(txt_data{1}(j,1));
                if (a==0)
                    clust1=clust1+1;
                    id1=0;
                else
                    id1=id1+1;
                    IDcluster{clust1,1}(1,id1)=a;
                    clusters(a,1)=a;
                    clusters(a,2)=clust1;
                end
            end
            
        end
        groups=clusters(:,2);
        % ------------------------------
        dim1=size(groups,1);
        if dim1~=numPoints
            disp(['Id de grupos ', num2str(dim1), ', diferente a numero de puntos', num2str(numPoints)])
        end
        % ------------------------------
        rmdir('TEMP_groups_ganc','s')
    case EDISON
        % Verify costraints to get Optical Flow of high reliability
        reliab=abs(reliability);
        meanr=mean(mean(reliab));
        rel1=(reliab>=meanr);
        of1=Vx1.*rel1;
        of2=Vy1.*rel1;
        % Normalize optical flow data
        minF = min(min(Vx1(:)), min(Vx1(:)));
        maxF = max(max(Vx1(:)), max(Vy1(:)));
        Vx1n = (Vx1 - minF) / (maxF-minF);
        Vy1n = (Vy1 - minF) / (maxF-minF);
        [fimage, labels] = edison_wrapper(repmat(I1, [1 1 3]), single(cat(3, Vx1, Vy1)), 'synergistic', false, 'RangeBandWidth', 3);
        figure(300); imagesc(labels)
        
        points_alive=points.position(~points.type.dead,:);
        ind_pts=sub2ind2(size(of1),fliplr(points_alive));
        grupos=labels(ind_pts);
        [idx1 idx2 groups]=unique(grupos);
        %         visualize_clustering(I2,grupos_edison,points_alive,MethodClustering);
    otherwise
        groups=[];
        fprintf('%s','Invalid Method')
end