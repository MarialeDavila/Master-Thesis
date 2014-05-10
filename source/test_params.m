%% Prueba 1
params=struct();
% params.alpha=1.2500;
% params.beta=1;
% params.gamma=1;
% params.omega=0.7500;
exponent=-4:1:0;
values=10.^exponent;
image_gt=imread('./video01/002.pgm');
groundtruth=bwlabel(image_gt);
mask_output=cell(5,5,5,5);
overlap=zeros(5,5,5,5);
for i=1:5
    params.alpha=values(i);
    for j=1:5
        params.beta=values(j);
        for k=1:5
            params.gamma=values(k);
            for l=1:1
                params.omega=values(l);
                mask=dyn_obj_contour('video01','MeanShift', 0, params);
                % overlap
                mask_int=sum(sum(mask.*groundtruth));  
                sum_gt=mask+groundtruth;
                sum_gt(sum_gt==2)=1;
                mask_union=sum(sum(sum_gt));  
                overlap(i,j,k,l)=mask_int./mask_union;
                mask_output{i,j,k,l}=mask;
            end
        end
    end
end
save('overlap_testing.mat','overlap');

% Visualize results
for l=1:5
    h=figure;
    set(h,'Name',['W ' num2str(values(l))],'NumberTitle','off')
    for k=1:5
        subplot(2,3,k)
        matrix_overlap=overlap(:,:,k,l);
        clims=[0.8 1];
        imagesc(matrix_overlap,clims), colorbar, axis square
        set(gca,'xtick', [], 'ytick', [])
        xlabel(['\beta ' num2str(values)],'FontSize',10)        
        ylabel(['\alpha ' num2str(values)],'Rotation',90,'FontSize',10)
        hold on
        for j=1:5
            for i=1:5
                % text(Y,X,data)
                text(j,i,num2str(matrix_overlap(i,j)), ...
                    'HorizontalAlignment','center','BackgroundColor',[1 1 1] )
            end
        end
        title(['Overlap for \gamma ' num2str(values(k))],'FontSize',12)
    end
    suptitle(['Overlap for \omega ' num2str(values(l))])
end


%% PRUEBA 2
params=struct();
% params.alpha=1.2500;
% params.beta=1;
% params.gamma=1;
% params.omega=0.7500;
exponent=-4:1:0;
values=10.^exponent;
num1=numel(values);
parameters=[0.01:0.01:0.1, 0.2:0.1:1];
num2=numel(parameters);
mask_output2=cell(num1,num1,num1,num2);
image_gt=imread('./video01/002.pgm');
groundtruth=bwlabel(image_gt);
overlap2=zeros(5,5,5,10);
overlap3=zeros(1,10);
for i=4:5
    params.alpha=values(i);
    for j=3:4
        params.beta=values(j);
        for k=2:5
            params.gamma=values(k);
            for l=1:numel(parameters)
                params.omega=parameters(l);
                mask=dyn_obj_contour('video01','MeanShift', 0, params);
                % overlap
                mask_int=sum(sum(mask.*groundtruth));  
                sum_gt=mask+groundtruth;
                sum_gt(sum_gt==2)=1;
                mask_union=sum(sum(sum_gt));  
                overlap2(i,j,k,l)=mask_int./mask_union;
                overlap3(l)=mask_int./mask_union;
                mask_output2{i,j,j,l}=mask;
            end
        end
    end
end
save('overlap_testing.mat','overlap');

% Visualize results
figure, line_w2=zeros(1,10);
for id=1:10; line_w2(id)=overlap2(i,j,k,id); end
plot(line_w2)

% Visualize results
figure
stem(overlap3,'o','fill');
