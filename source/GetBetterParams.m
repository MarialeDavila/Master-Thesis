function [value_sum,value_avg, params_sum,params_avg,NumPixelsWrong,better_params] = GetBetterParams(OverlapGlobal,OutputMetricsGlobal,NameDataset)

VideoNames=fieldnames(OverlapGlobal);
NumVideos=numel(VideoNames);
if strcmp(NameDataset,'moseg_dataset')
    AlphaValues=[0.25, 0.5, 0.75, 1];
    BetaValues=[0.25, 0.5, 0.75, 1];
    OmegaValues=[0.5, 1, 1.5, 2];
else
    AlphaValues=[0.25, 0.5, 0.75];
    BetaValues=[0.25, 0.5, 0.75];
    OmegaValues=[0.5, 1];
end
NumAlphaValues=numel(AlphaValues);
NumBetaValues=numel(BetaValues);
NumOmegaValues=numel(OmegaValues);

suma=zeros(NumAlphaValues,NumBetaValues,NumOmegaValues,NumVideos);
avg=zeros(NumAlphaValues,NumBetaValues,NumOmegaValues,NumVideos);
params_sum=zeros(NumVideos,3);
params_avg=zeros(NumVideos,3);
value_sum=zeros(NumVideos,1);
value_avg=zeros(NumVideos,1);
NumPixelsWrong=zeros(NumVideos,1);
for idVideo=1:NumVideos
    NameVideo=VideoNames(idVideo);
    NameVideo=NameVideo{1};
    [dimX dimY dimZ]=size(OverlapGlobal.(NameVideo));
    suma_vector=zeros(dimX*dimY*dimZ,1);
    avg_vector=zeros(dimX*dimY*dimZ,1);
    id=zeros(dimX*dimY*dimZ,3);
    numPixWrong_vector=zeros(dimX*dimY*dimZ,1);
    count=0; 
    for a=1:dimX
        for b=1:dimY
            for w=1:dimZ
                Data=OverlapGlobal.(NameVideo){a,b,w};
                count=count+1;
                if ~isempty(Data)
                    suma(a,b,w,idVideo)=sum(Data);
                    avg(a,b,w,idVideo)=suma(a,b,w,idVideo)/numel(Data);
                    suma_vector(count)=suma(a,b,w,idVideo);
                    avg_vector(count)=avg(a,b,w,idVideo);
                    id(count,:)=[a, b, w];
                end
                DataPerPixels=OutputMetricsGlobal.(NameVideo){a,b,w};
                if ~isempty(DataPerPixels)
                    numPixWrong_vector(count,1)=mean(DataPerPixels.FalseNegatives + DataPerPixels.FalsePositives);
                end
            end
        end
    end
    [value_sum(idVideo) position]=max(suma_vector);
    params_sum(idVideo,:)=id(position,:);
    
    [value_avg(idVideo) position]=max(avg_vector);
    params_avg(idVideo,:)=id(position,:);    
    % number pixels misleading
    NumPixelsWrong(idVideo,1)=numPixWrong_vector(position,1);
end

% results
alpha=AlphaValues(params_avg(:,1));
beta=BetaValues(params_avg(:,2));
omega=OmegaValues(params_avg(:,3));
better_params=[alpha' beta' omega'];

% %%
% % Visualize results
% for idVideo=1:NumVideos
%     NameVideo=VideoNames(idVideo);
%     NameVideo=NameVideo{1};
%     h=figure;
%     set(h,'Name',['Video ' NameVideo],'NumberTitle','off')
%     for k=1:4
%         subplot(2,2,k)
%         matrix_overlap=avg(:,:,k,idVideo);
%         clims=[0 0.8];
%         imagesc(matrix_overlap,clims), colorbar, axis square
%         set(gca,'xtick', [], 'ytick', [])
%         xlabel(['\beta ' num2str(BetaValues)],'FontSize',10)
%         ylabel(['\alpha ' num2str(AlphaValues)],'Rotation',90,'FontSize',10)
% %         hold on
% %         for j=1:4
% %             for i=1:4
% %                 % text(Y,X,data)
% %                 text(j,i,num2str(matrix_overlap(i,j)), ...
% %                     'HorizontalAlignment','center','BackgroundColor',[1 1 1] )
% %             end
% %         end
%         title(['Overlap for \omega ' num2str(OmegaValues(k))],'FontSize',12)
%     end
%
%     suptitle(['Overlap for video ' NameVideo])
% end