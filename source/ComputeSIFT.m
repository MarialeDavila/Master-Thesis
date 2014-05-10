function sift =ComputeSIFT(ImageGray,points)

ImageGray=im2single(ImageGray);
NumPoints=size(points,1);
sift=cell(1,NumPoints);
for idPoints=1:NumPoints
    % Compute sift to every point
    X=points(idPoints,1);
    Y=points(idPoints,2);
    fc = [X;Y;10;0] ;    
    [dummy, sift{1,idPoints}] = vl_sift(ImageGray,'frames',fc,'orientations');
end
