function MorphEvalCurve(directory, set, pixel_method, window_method, decision_method)
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
    
    % Area opening size and morphological filtering method (1 or 2)
    ao_size = 10:10:250;
    morph_method = 2;
    
    % Variables to store the evaluation scores
    N = length(ao_size);
    scores = zeros(N, 5);
    
    % Dataset loading
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
    
    for ao_ind=1:length(ao_size)
        % windowTP=0; windowFN=0; windowFP=0; % (Needed after Week 3)
        pixelTP=0; pixelFN=0; pixelFP=0; pixelTN=0;
        for i=1:size(dataset_split,2)
            % Read image
            im = imread(dataset_split(i).image);

            % Candidate Generation (pixel) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            pixelCandidates = CandidateGenerationPixel(im, pixel_method, histogram);
            
            % Morphological filtering of candidate pixels
            ao_object_size = ao_size(ao_ind);
            pixelCandidates = MorphologicalFiltering(pixelCandidates, morph_method, ao_object_size);

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

        % Plot performance evaluation
        [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity] = PerformanceEvaluationPixel(pixelTP, pixelFP, pixelFN, pixelTN);
        F_score = (2*pixelPrecision*pixelSensitivity)/(pixelPrecision+pixelSensitivity);
        scores(ao_ind, :) = [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity, F_score];

        % [windowPrecision, windowAccuracy] = PerformanceEvaluationWindow(windowTP, windowFN, windowFP); % (Needed after Week 3)

        % [windowPrecision, windowAccuracy]
        %profile report
        %profile off
        fprintf('Ended iteration %s of %s\n', int2str(ao_ind), int2str(N));
    end
    
    % Plot curves
    plot(ao_size, scores(:, 1), ao_size, scores(:, 2), ...
        ao_size, scores(:, 3), ao_size, scores(:, 4), ...
        ao_size, scores(:, 5)), ...
        legend('Precision', 'Accuracy', 'Specificity', 'Sensitivity', 'F1');
    xlabel('Area opening object size');
    toc;
end

