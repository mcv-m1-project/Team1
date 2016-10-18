function [pixelPrecision_max, pixelAccuracy_max, pixelSpecificity_max,...
    pixelSensitivity_max, Fmeasure_max, threshold, time] = calculatePerformance(histogram,Nbins,set)
%Modified version of TrafficSignDetection to calculate the performance of
%the system depending on the histogram (passed as input parameter) and the
%threshold (in range from 0 to 1, with 0.1 steps)

tic

%directory of the dataset, so the images can be found in directory/train
directory = 'DataSetDelivered';
%Initialize 
pixelTP=zeros(1,11); pixelFN=zeros(1,11); pixelFP=zeros(1,11); pixelTN=zeros(1,11);
Fmeasure_max=0;
pixelPrecision_max=0; pixelAccuracy_max=0; pixelSpecificity_max=0; pixelSensitivity_max=0;
[train_split, val_split] = read_train_val_split(directory);
if strcmp(set, 'train')
    set_split = train_split;
    clear val_split;
elseif strcmp(set, 'val')
    set_split = val_split;
    clear train_split
else
    clear train_split val_split
    error('The set type indicated in the input parameters is not valid');
end

%Get the selected dataset split
dataset_split = read_train_dataset([directory '/train/'], set_split);

histogram = histogram/max(max(histogram));

for i=1:size(dataset_split,2)
    % Read image
    im = imread(dataset_split(i).image);
    
    % Candidate Generation (pixel) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Initialize result mask
    score=zeros(size(im,1),size(im,2));
    
    %Transform the image to HSV
    im_cs=rgb2hsv(im);
    %Take the Hue and Saturation components
    H=im_cs(:,:,1);
    S=im_cs(:,:,2);
    
    %For each pixel in the test image, check its probability of
    %belonging to a signal (if its color is represented in the signal
    %histograms)
    for s1=1:size(im,1)
        for s2=1:size(im,2)
            score(s1,s2) = histogram(round(H(s1,s2)*(Nbins-1))+1,round(S(s1,s2)*(Nbins-1))+1);
        end
    end
    
    for thr = 0.1
        
        pixelCandidates = score > thr;
        
        % Accumulate pixel performance of the current image %%%%%%%%%%%%%%%%%
        pixelAnnotation = imread(dataset_split(i).mask)>0;
     
        [localPixelTP, localPixelFP, localPixelFN, localPixelTN] = PerformanceAccumulationPixel(pixelCandidates, pixelAnnotation);
        
        k = round(thr*10)+1;
        pixelTP(1,k) = pixelTP(1,k) + localPixelTP;
        pixelFP(1,k) = pixelFP(1,k) + localPixelFP;
        pixelFN(1,k) = pixelFN(1,k) + localPixelFN;
        pixelTN(1,k) = pixelTN(1,k) + localPixelTN;
    end
    
end

% Performance evaluation
for k = 1:11
    
    [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity] = PerformanceEvaluationPixel(pixelTP(1,k), pixelFP(1,k), pixelFN(1,k), pixelTN(1,k));
    Fmeasure = (2*pixelPrecision*pixelSensitivity)/(pixelPrecision+pixelSensitivity);
    
    %If the Fmeasure is improved, save the settings 
    if Fmeasure > Fmeasure_max
        Fmeasure_max = Fmeasure;
        pixelPrecision_max = pixelPrecision;
        pixelAccuracy_max = pixelAccuracy;
        pixelSpecificity_max = pixelSpecificity;
        pixelSensitivity_max = pixelSensitivity;
        threshold = (k-1)/10;
    end
    
end

time = toc;


end