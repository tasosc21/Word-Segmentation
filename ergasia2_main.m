clc;
clear;
close all;
more off;

% ------------------------------------------------------
% PART A MAIN 
% ------------------------------------------------------

% --- INIT
if exist('OCTAVE_VERSION', 'builtin')>0
    % If in OCTAVE load the image package
    warning off;
    pkg load image;
    warning on;
end

% ------------------------------------------------------
% LOAD AND SHOW THE IMAGE + CONVERT TO BLACK-AND-WHITE
% ------------------------------------------------------

% --- Step A1
% read the original RGB image 
Filename='Troizina 1827.jpg';
I=imread(Filename);

% show it (Eikona 1)
figure;
image(I), title('Original Image');
axis image off;
colormap(gray(256));

% --- Step A2
% convert the image to grayscale
A=any_image_to_grayscale_func('Troizina 1827.jpg');

% apply gamma correction (a value of 1.0 doesn't change the image)
GammaValue=1; 
A=imadjust(A,[],[],GammaValue); 

% show the grayscale image (Eikona 2)
figure;
image(A), title("Grayscale Image");
colormap(gray(256));
axis image off;
title('Grayscale image');

% --- Step A3
% convert the grayscale image to black-and-white using Otsu's method
Threshold= graythresh(A); 
BW = ~im2bw(A,Threshold);

% show the black-and-white image (Eikona 3)
figure;
image(~BW);
colormap(gray(2));
axis image;
set(gca,'xtick',[],'ytick',[]);
title('Binary image');

% ------------------------------------------------------
% CLEAN THE IMAGE
% ------------------------------------------------------
% --- Step A4

% make morphological operations to clean the image ...

se = strel("disk", 5); %create disk structuring element with radius 5
BW_dilated=imdilate(BW,se); %Dilate image BW

% %Show the dilated image
% figure;
% imshow(~BW_dilated);

%Clear border of BW_dilated image
BW_clear_border = imclearborder(BW_dilated, 8); 

% %Show BW_dilated image with clear border
% figure;
% imshow(~BW_clear_border);

%Get picture with no seal 
BW_noSeal = BW_clear_border & BW;
% figure;
% imshow(~BW_noSeal), , title('Binary Image-Without Seal');




% get statistical information from connected components ...

% Find connected components in the binary image
CC = bwconncomp(BW_noSeal,8);

% Get the sizes of all connected components
sizes = cellfun(@length, CC.PixelIdxList);




% find connected components that are statistical outliers
% (too small or too big)
% and remove them...

% Find small components
small_components = sizes < 35;

% Get the indices of the outliers
small_componentIndices = find(small_components);

[rows, cols] = size(BW); %BW dimensions
noise = zeros(rows, cols); %Initialize noise matrix

% Iterate over the connected components
for i = small_componentIndices
    % Get the indices of the pixels in the component
    component = CC.PixelIdxList{i};
    % For component set pixels as 1 in noise matrix
    noise(component) = 1;
end

% figure;
% imshow(~noise), title("Noise"); % Show noise image


% show cleaned image (Eikona 4) ...
Clear_BW=BW_noSeal-noise; %remove noise from BW_noSeal
figure;
imshow(~Clear_BW), title("Cleaned Image");


% ------------------------------------------------------
% WORD SEGMENTATION
% ------------------------------------------------------
% --- Step A5

% make morphological operations for word segmentation ...

se=strel("line", 17, 0); %Create line structuring element, size=17
Close_clearBW=imclose(Clear_BW,se); %use close operation to connect components into words

% figure;
% imshow(~Close_clearBW);

se=strel('diamond',1); %Create diamond structuring element
Dilated_clearBW=imdilate(Close_clearBW,se); %Dilate image
% figure;
% imshow(~Dilated_clearBW);



% find the connected components (using bwlabel) ...
[L, num] = bwlabel(Dilated_clearBW,4);
rgb_image = label2rgb(L, 'lines');



% show word segmentation (Eikona 5) ...
figure;
imshow(rgb_image), title("Morphological Processing");



% ------------------------------------------------------
% FINAL IMAGE WITH BOUNDING BOXES
% ------------------------------------------------------
% --- Step A6

% --- Store all the bounding boxes in an array R
R=[];
for i=1:num
    [r,c]=find(L==i);
    XY=[c r];
    x1=min(XY(:,1));
    y1=min(XY(:,2));
    x2=max(XY(:,1));
    y2=max(XY(:,2));
    R=[R;x1 y1 x2 y2]; % append to R the bounding box as [x1 y1 x2 y2]
end





% show the original image with the final bounding boxes (Eikona 6) ...
% TIP: check the last part of bwlabel_demo.m

ColorMap=lines;
figure('color','w');
image(I); 
colormap(gray(256));
axis image;
set(gca,'xtick',[],'ytick',[]);
title('Final results');

for i=1:size(R,1)
    x1=R(i,1);
    y1=R(i,2);
    x2=R(i,3);
    y2=R(i,4);
    line([x1-0.5 x2+0.5 x2+0.5 x1-0.5 x1-0.5],[y1-0.5 y1-0.5 y2+0.5 y2+0.5 y1-0.5],'color',ColorMap(mod(i-1,7)+1,:),'linewidth',2);
end

% --- Step A7
% let suppose matrix R contains all the N bounding boxes in the form
% x11 y11 x12 y12
% x21 y21 x22 y22
% ...
% xN1 yN1 xN2 yN2
% then save the bounding boxes in a text file results.txt ...
if exist('R','var')
    dlmwrite('results.txt',R,'\t');
else
    error('Ooooops! There is no R variable!');
end


