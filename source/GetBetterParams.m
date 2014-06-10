function [value_sum,value_avg, params_sum,params_avg] = GetBetterParams(OverlapGlobal)

VideoNames=fieldnames(OverlapGlobal);
NumVideos=numel(VideoNames);
NumAlphaValues=4;
NumBetaValues=4;
NumOmegaValues=4;

suma=zeros(NumAlphaValues,NumBetaValues,NumOmegaValues,NumVideos);
avg=zeros(NumAlphaValues,NumBetaValues,NumOmegaValues,NumVideos);
params_sum=zeros(NumVideos,3);
params_avg=zeros(NumVideos,3);
value_sum=zeros(NumVideos,1);
value_avg=zeros(NumVideos,1);
for idVideo=1:NumVideos
    NameVideo=VideoNames(idVideo);
    NameVideo=NameVideo{1};
    suma_vector=zeros(NumAlphaValues*NumBetaValues*NumOmegaValues,1);
    avg_vector=zeros(NumAlphaValues*NumBetaValues*NumOmegaValues,1);
    id=zeros(NumAlphaValues*NumBetaValues*NumOmegaValues,3);
    count=0;
    for a=1:NumAlphaValues
        for b=1:NumBetaValues
            for w=1:NumOmegaValues
                Data=OverlapGlobal.(NameVideo){a,b,w};
                count=count+1;
                if ~isempty(Data)
                    suma(a,b,w,idVideo)=sum(Data);
                    avg(a,b,w,idVideo)=suma(a,b,w,idVideo)/numel(Data);
                    suma_vector(count)=suma(a,b,w,idVideo);
                    avg_vector(count)=avg(a,b,w,idVideo);
                    id(count,:)=[a, b, w];
                end
            end
        end
    end
    [value_sum(idVideo) position]=max(suma_vector);
    params_sum(idVideo,:)=id(position,:);
    
    [value_avg(idVideo) position]=max(avg_vector);
    params_avg(idVideo,:)=id(position,:);
end

% results
AlphaValues=[0.25, 0.5, 0.75, 1];
BetaValues=[0.25, 0.5, 0.75, 1];
OmegaValues=[0.5, 1, 1.5, 2];
alpha=AlphaValues(params_avg(:,1));
beta=BetaValues(params_avg(:,2));
omega=OmegaValues(params_avg(:,3));
params=[alpha' beta' omega'];

%%
% Visualize results
for idVideo=1:NumVideos
    NameVideo=VideoNames(idVideo);
    NameVideo=NameVideo{1};
    h=figure;
    set(h,'Name',['Video ' NameVideo],'NumberTitle','off')
    for k=1:4
        subplot(2,2,k)
        matrix_overlap=avg(:,:,k,idVideo);
        clims=[0 0.8];
        imagesc(matrix_overlap,clims), colorbar, axis square
        set(gca,'xtick', [], 'ytick', [])
        xlabel(['\beta ' num2str(BetaValues)],'FontSize',10)        
        ylabel(['\alpha ' num2str(AlphaValues)],'Rotation',90,'FontSize',10)
%         hold on
%         for j=1:4
%             for i=1:4
%                 % text(Y,X,data)
%                 text(j,i,num2str(matrix_overlap(i,j)), ...
%                     'HorizontalAlignment','center','BackgroundColor',[1 1 1] )
%             end
%         end
        title(['Overlap for \omega ' num2str(OmegaValues(k))],'FontSize',12)
    end

    suptitle(['Overlap for video ' NameVideo])
end