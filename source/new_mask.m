function new_segments = new_mask(I1,I2,mask_initial)
% function to create mask based on initial mask

% change mask to unique object in groud truth
mask_initial(mask_initial~=1)=0;
% segment based on previous mask
% Optical Flow
[of_dx of_dy reliab]=opticalFlow(I1, I2,'type','LK');
idx=find(mask_initial==1);
reliab=abs(reliab); mean_r=mean(mean(reliab));
of_dx_mask=of_dx(idx).*double(reliab(idx)>=mean_r);
of_dy_mask=of_dy(idx).*double(reliab(idx)>=mean_r);
average_ofx=double(round(mean(of_dx_mask)));
average_ofy=double(round(mean(of_dy_mask)));
% average_ratio=average_ofx/average_ofy;
average_x=average_ofx*sign(average_ofx);
average_y=average_ofy*sign(average_ofy);
% average_y=round(average_x/average_ratio)*sign(average_ofy);

% first option --> to do corrections
% new_segments=circshift(mask_initial,[average_y, average_x]);

%second option
if sign(average_ofx)==-1
    x_min=1+abs(average_x);
    x_max=size(I1,2);
    Xmin=1;
    Xmax=size(I1,2)-abs(average_x);
else
    x_min=1;
    x_max=size(I1,2)-average_x;
    Xmin=1+average_x;
    Xmax=size(I1,2);
end

if sign(average_ofy)==-1
    y_min=1;
    y_max=size(I1,1)-abs(average_y);
    Ymin=1+abs(average_y);
    Ymax=size(I1,1);       
else
    y_min=1+average_y;
    y_max=size(I1,1);
    Ymin=1;
    Ymax=size(I1,1)-average_y;
end
new_segments=zeros(size(I2));
new_segments(Ymin:Ymax,Xmin:Xmax)=mask_initial(y_min:y_max,x_min:x_max);
% new_segments(y_max:size(I1,1),x_max:size(I1,2))=0;
% new_segments(y_max:size(I1,1),x_max:size(I1,2))=0;
end