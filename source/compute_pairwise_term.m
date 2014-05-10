function [pairwise, edges_costs] = compute_pairwise_term(color_histogram_new, HOOF_new,labels, params)
% Compute unary term for every node of the graph

% Pairwise term of the minimization equation
NumSegments=double(max(max(labels))); 
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

% Define descriptors to every pair of segments connected
data_pair1_color=color_histogram_new(id1,:);
data_pair1_of=HOOF_new(id1,:);
data_pair2_color=color_histogram_new(id2,:);
data_pair2_of=HOOF_new(id2,:);
distance_color = pdist2(data_pair1_color,data_pair2_color,'chisq');
distance_of = pdist2(data_pair1_of,data_pair2_of,'chisq');

% Compute distance between pair of segments
distance_seg2seg = params.beta*distance_color + (1-params.beta)*distance_of;

% similarity_seg2seg=exp(-distance_seg2seg);
% similitude_seg2seg=1./(1+distance_seg2seg);
media_seg=mean(mean(distance_seg2seg));
similarity_keyseg=exp(-distance_seg2seg/media_seg);
% weight_edges_minus=data_pair1-data_pair2;
edges_costs=diag(similarity_keyseg);
pairwise=pairwise_matrix;
pairwise(pairwise_matrix==1)=params.omega*edges_costs;
