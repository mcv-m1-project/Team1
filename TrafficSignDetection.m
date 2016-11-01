%
% Template example for using on the validation set.
%

function TrafficSignDetection(directory, set, pixel_method, window_method, decision_method, plot_results)
    tic
    close all;

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
    %    'plot_results'       0 or 1


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

    windowTP=0; windowFN=0; windowFP=0; % (Needed after Week 3)
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
        % fprintf('Image %s of %s\r', int2str(i), int2str( size(dataset_split,2)));
        % Read image
        im = imread(dataset_split(i).image);

        % Candidate Generation (pixel) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pixelCandidates1 = CandidateGenerationPixel(im, pixel_method, histogram);
        
        % Morphological filtering of candidate pixels
        pixelCandidates = MorphologicalFiltering(pixelCandidates1);

        % Candidate Generation (window)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        windowCandidates = CandidateGenerationWindow(im, pixelCandidates, window_method); %%'SegmentationCCL' or 'SlidingWindow'  (Needed after Week 3)
        pixelCandidatesFinal=zeros(size(pixelCandidates));
        for ind=1:size(windowCandidates,1)
            pixelCandidatesFinal(windowCandidates(ind).y:windowCandidates(ind).y+windowCandidates(ind).h,windowCandidates(ind).x:windowCandidates(ind).x+windowCandidates(ind).w)=pixelCandidates(windowCandidates(ind).y:windowCandidates(ind).y+windowCandidates(ind).h,windowCandidates(ind).x:windowCandidates(ind).x+windowCandidates(ind).w);
        end
        pixelCandidates=pixelCandidatesFinal;
        % Accumulate pixel performance of the current image %%%%%%%%%%%%%%%%%
        pixelAnnotation = imread(dataset_split(i).mask)>0;
        [localPixelTP, localPixelFP, localPixelFN, localPixelTN] = PerformanceAccumulationPixel(pixelCandidates, pixelAnnotation);
        pixelTP = pixelTP + localPixelTP;
        pixelFP = pixelFP + localPixelFP;
        pixelFN = pixelFN + localPixelFN;
        pixelTN = pixelTN + localPixelTN;

        % Accumulate object performance of the current image %%%%%%%%%%%%%%%%  (Needed after Week 3)
        windowAnnotations = LoadAnnotations(dataset_split(i).annotations);
        [localWindowTP, localWindowFN, localWindowFP] = PerformanceAccumulationWindow(windowCandidates, windowAnnotations);
        windowTP = windowTP + localWindowTP;
        windowFN = windowFN + localWindowFN;
        windowFP = windowFP + localWindowFP;
        
        % Show progress
        fprintf('Image %s of %s\r', int2str(i), int2str(size(dataset_split,2)));

        if plot_results 
            hAx  = axes;
            imshow(pixelCandidates,'Parent', hAx);
             for zz = 1:size(windowCandidates,1)
                 r=imrect(hAx, [windowCandidates(zz,1).x, windowCandidates(zz,1).y, windowCandidates(zz,1).w, windowCandidates(zz,1).h]);
                 setColor(r,'r');
             end
        end
 
    end

    % Performance evaluation
    [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity] = PerformanceEvaluationPixel(pixelTP, pixelFP, pixelFN, pixelTN);
    Fmeasure = (2*pixelPrecision*pixelSensitivity)/(pixelPrecision+pixelSensitivity);
    fprintf('PIXEL-BASED EVALUATION\n')
    fprintf('-----------------------\n')
    fprintf('Precision: %f\n', pixelPrecision)
    fprintf('Recall: %f\n', pixelSensitivity)
    fprintf('Accuracy: %f\n', pixelAccuracy)
    fprintf('Specificity: %f\n', pixelSpecificity)
    fprintf('F measure: %f\n\n', Fmeasure)

    [windowPrecision, windowRecall, windowAccuracy] = PerformanceEvaluationWindow(windowTP, windowFN, windowFP);

    fprintf('REGION-BASED EVALUATION\n')
    fprintf('-----------------------\n')
    fprintf('Precision: %f\n', windowPrecision)
    fprintf('Recall: %f\n', windowRecall)
    fprintf('Accuracy: %f\n', windowAccuracy)

    
    %profile report
    %profile off
    toc
end
