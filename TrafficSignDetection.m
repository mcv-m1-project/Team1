%
% Template example for using on the validation set.
%

function TrafficSignDetection(directory, set, pixel_method, window_method, decision_method)
    tic
    % TrafficSignDetection
    % Perform detection of Traffic signs on images. Detection is performed first at the pixel level
    % using a color segmentation. Then, using the color segmentation as a basis, the most likely window
    % candidates to contain a traffic sign are selected using basic features (form factor, filling factor).
    % Finally, a decision is taken on these windows using geometric heuristics (Hough) or template matching.
    %
    %    Parameter name      Value
    %    --------------      -----
    %    'directory'         directory where the test images to analize  (.jpg) reside
    %    'set'               'train' (training) or 'val' (validation)
    %    'pixel_method'      Name of the color space: 'opp', 'normrgb', 'lab', 'hsv', etc. (Weeks 2-5)
    %    'window_method'     'SegmentationCCL' or 'SlidingWindow' (Weeks 3-5)
    %    'decision_method'   'GeometricHeuristics' or 'TemplateMatching' (Weeks 4-5)


    global CANONICAL_W;        CANONICAL_W = 64;
    global CANONICAL_H;        CANONICAL_H = 64;
    global SW_STRIDEX;         SW_STRIDEX = 8;
    global SW_STRIDEY;         SW_STRIDEY = 8;
    global SW_CANONICALW;      SW_CANONICALW = 32;
    global SW_ASPECTRATIO;     SW_ASPECTRATIO = 1;
    global SW_MINS;            SW_MINS = 1;
    global SW_MAXS;            SW_MAXS = 2.5;
    global SW_STRIDES;         SW_STRIDES = 1.2;


    % Load models
    %global circleTemplate;
    %global givewayTemplate;
    %global stopTemplate;
    %global rectangleTemplate;
    %global triangleTemplate;
    %
    %if strcmp(decision_method, 'TemplateMatching')
    %   circleTemplate    = load('TemplateCircles.mat');
    %   givewayTemplate   = load('TemplateGiveways.mat');
    %   stopTemplate      = load('TemplateStops.mat');
    %   rectangleTemplate = load('TemplateRectangles.mat');
    %   triangleTemplate  = load('TemplateTriangles.mat');
    %end

    % windowTP=0; windowFN=0; windowFP=0; % (Needed after Week 3)
    pixelTP=0; pixelFN=0; pixelFP=0; pixelTN=0;


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

    %Load histogram
    histogram = loadHistograms('joint', pixel_method,'');
    %Normalize histogram
    histogram = histogram/max(max(histogram));

    for i=1:size(dataset_split,2)
        % Read image
        im = imread(dataset_split(i).image);

        % Candidate Generation (pixel) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pixelCandidates = CandidateGenerationPixel(im, pixel_method, histogram);
        
        % Morphological filtering of candidate pixels
        pixelCandidates = MorphologicalFiltering(pixelCandidates);

        % Candidate Generation (window)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % windowCandidates = CandidateGenerationWindow_Example(im, pixelCandidates, window_method); %%'SegmentationCCL' or 'SlidingWindow'  (Needed after Week 3)

        % Accumulate pixel performance of the current image %%%%%%%%%%%%%%%%%
        pixelAnnotation = imread(dataset_split(i).mask)>0;

        [localPixelTP, localPixelFP, localPixelFN, localPixelTN] = PerformanceAccumulationPixel(pixelCandidates, pixelAnnotation);
        pixelTP = pixelTP + localPixelTP;
        pixelFP = pixelFP + localPixelFP;
        pixelFN = pixelFN + localPixelFN;
        pixelTN = pixelTN + localPixelTN;

        % Accumulate object performance of the current image %%%%%%%%%%%%%%%%  (Needed after Week 3)
        % windowAnnotations = LoadAnnotations(strcat(directory, '/gt/gt.', files(i).name(1:size(files(i).name,2)-3), 'txt'));
        % [localWindowTP, localWindowFN, localWindowFP] = PerformanceAccumulationWindow(windowCandidates, windowAnnotations);
        % windowTP = windowTP + localWindowTP;
        % windowFN = windowFN + localWindowFN;
        % windowFP = windowFP + localWindowFP;
    end

    % Performance evaluation
    [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity] = PerformanceEvaluationPixel(pixelTP, pixelFP, pixelFN, pixelTN);
    Fmeasure = (2*pixelPrecision*pixelSensitivity)/(pixelPrecision+pixelSensitivity);
    fprintf('Precision: %f\n', pixelPrecision)
    fprintf('Recall: %f\n', pixelSensitivity)
    fprintf('F measure: %f\n', Fmeasure)
    fprintf('Pixel accuracy: %f\n', pixelAccuracy)
    fprintf('Pixel specificity: %f\n', pixelSpecificity)

    % [windowPrecision, windowAccuracy] = PerformanceEvaluationWindow(windowTP, windowFN, windowFP); % (Needed after Week 3)

    % [windowPrecision, windowAccuracy]
    %profile report
    %profile off
    toc
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CandidateGeneration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [windowCandidates] = CandidateGenerationWindow_Example(im, pixelCandidates, window_method)
windowCandidates = [ struct('x',double(12),'y',double(17),'w',double(32),'h',double(32)) ];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Performance Evaluation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PerformanceEvaluationROC(scores, labels, thresholdRange)
% PerformanceEvaluationROC
%  ROC Curve with precision and accuracy

roc = [];
for t=thresholdRange
    TP=0;
    FP=0;
    for i=1:size(scores,1)
        if scores(i) > t    % scored positive
            if labels(i)==1 % labeled positive
                TP=TP+1;
            else            % labeled negative
                FP=FP+1;
            end
        else                % scored negative
            if labels(i)==1 % labeled positive
                FN = FN+1;
            else            % labeled negative
                TN = TN+1;
            end
        end
    end

    precision = TP / (TP+FP+FN+TN);
    accuracy = TP / (TP+FN+FP);

    roc = [roc ; precision accuracy];
end

plot(roc);
end
