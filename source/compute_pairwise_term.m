function pairwise = compute_pairwise_term(color_histogram_new, HOOF_new,labels, params)
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

% Define descriptors to every pair of segments connected
distance_color = pdist2(color_histogram_new,color_histogram_new,'chisq');
distance_of = pdist2(HOOF_new,HOOF_new,'chisq');

% Compute distance between pair of segments
distance_seg2seg = params.beta*distance_color + (1-params.beta)*distance_of;
% Get the similarity based in the weighted distance
media_seg=mean(mean(distance_seg2seg));
similarity_seg2seg=exp(-distance_seg2seg/media_seg);
% weight_edges_minus=data_pair1-data_pair2;
pairwise=pairwise_matrix.*similarity_seg2seg;
pairwise=params.omega*pairwise;
