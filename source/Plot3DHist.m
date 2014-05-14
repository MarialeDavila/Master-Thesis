function Plot3DHist(hist_segment)

%%Visualize 3D histogram to every segment
nbins=size(hist_segment,1);
figure (70)
for j=1:nbins
    subplot(2,4,j)
    bar3(hist_segment(:,:,j))
end

%% Plot 3D histogram
% plot cuboid of color histogram
% hist_segment => [n x n x n]
bins=1:nbins;

x=reshape(repmat(bins,nbins,nbins),1,[]);
y=repmat(bins,1,nbins*nbins);
z=reshape(repmat(bins,nbins*nbins,1),1,[]);

% View every points, including with zero value
s=hist_segment(:)+1;

color=0:256/nbins:255;
cx=reshape(repmat(color,nbins,nbins),[],1);
cy=reshape(repmat(color,1,nbins*nbins),[],1);
cz=reshape(repmat(color,nbins*nbins,1),[],1);

c=[cx,cy,cz];
c=c/256;

figure(71),
scatter3(x,y,z,s,c,'filled'), view(175,35)
