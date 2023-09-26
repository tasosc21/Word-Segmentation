clc;
clear;
close all;
more off;

% ------------------------------------------------------
% PART B EVALUATION
% ------------------------------------------------------

% --- INIT
if exist('OCTAVE_VERSION', 'builtin')>0
    % If in OCTAVE load the image package
    warning off;
    pkg load image;
    warning on;
end

% ------------------------------------------------------
% COMPARE RESULTS TO GROUND TRUTH
% ------------------------------------------------------

% --- Step B1
% load the ground truth
GT=dlmread('Troizina 1827_ground_truth.txt');
% load our results (if available)
if exist('results.txt','file')
    R=dlmread('results.txt');
else
    error('Ooooops! There is no results.txt file!');
end

% --- Step B2
% define the threshold for the IOU matrix
T=0.5; % or 0.3 or 0.7

% calculate IOU for all the results
IOU=calcIOU(R,GT);

% apply the IOU threshold
% TIP: check the last part of iou_demo.m
% ...
% ...
IOUFinal=IOU>=T;
%fprintf('Final IOU is:\n');
%disp(IOUFinal);


% calculate TP, FP, FN, Recall, Precision and F-Measure
% TIP: check the last part of iou_demo.m
r=zeros(size(IOUFinal,1),1);
for i=1:size(IOUFinal,1)
    if sum(IOUFinal(i,:))>=1
        r(i,1)=1;
    end
end

p=zeros(1,size(IOUFinal,2));
for i=1:size(IOUFinal,2)
    if sum(IOUFinal(:,i))>=1
        p(1,i)=1;
    end
end

TP = sum(p==1); %True Positive
FN = sum(p==0); %False Negative
FP = sum(r==0); %False Positive

Recall = TP/(TP+FN); %Recall
Precision = TP/(TP+FP); %Precision
F1 = (2*Recall*Precision)/(Recall+Precision); %F-Measure


% and show the results
fprintf('Recall %0.2f\n',Recall);
fprintf('Precision %0.2f\n',Precision);
fprintf('F-Measure %0.2f\n',F1);

