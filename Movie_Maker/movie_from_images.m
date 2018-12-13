%Find all the jpg files in the images folder
workingDir = 'C:\Users\user\Documents\MATLAB\Movie_Maker'
imageNames = dir(fullfile(workingDir,'St7_Images','*.BMP'))
imageNames = {imageNames.name}'
%Construct a VideoWriter object, which creates a Motion-JPEG AVI file by default.
outputVideo = VideoWriter(fullfile(workingDir,'st7_out.avi'));
%Frame rate frames per second
outputVideo.FrameRate = 1;
open(outputVideo)
%Loop through the image sequence, load each image, and then write it to the video.
for ii = 1:length(imageNames)
   img = imread(fullfile(workingDir,'St7_Images',imageNames{ii}));
   writeVideo(outputVideo,img)
end
%Finalize the video file.
close(outputVideo)
%View the Final Video  :-   Construct a reader object.
St7Avi = VideoReader(fullfile(workingDir,'st7_out.avi'));
%Create a MATLAB movie struct from the video frames.
ii = 1;
while hasFrame(St7Avi)
   mov(ii) = im2frame(readFrame(St7Avi));
   ii = ii+1;
end
%Resize the current figure and axes based on the video's width and height,
% and view the first frame of the movie.
figure 
imshow(mov(1).cdata, 'Border', 'tight')
%Play back the movie once at the video's frame rate.
movie(mov,1,St7Avi.FrameRate)