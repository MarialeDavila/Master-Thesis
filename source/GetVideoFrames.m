function data = GetVideoFrames(VideoPath)

data=struct();
ListFrames=[dir([VideoPath,'*.jpg']);  dir([VideoPath,'*.png']); dir([VideoPath,'*.bmp']); dir([VideoPath,'*.ppm'])] ;
NumFrames=numel(ListFrames);
for idFrame=1:NumFrames
    ImageColor=imread([VideoPath, ListFrames(idFrame).name]);
    data.Image{idFrame} = ImageColor;
    data.ImageGray{idFrame} = rgb2gray(ImageColor);
end