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

    windowTP=0; windowFN=0; windowFP=0; % (Needed after Week 3)
    pixelTP=0; pixelFN=0; pixelFP=0; pixelTN=0;
    pixelTP_post=0; pixelFN_post=0; pixelFP_post=0; pixelTN_post=0;

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
    
    % Load templates for correlation method
    if(strcmp(window_method,'template_corr'))
        templates = fullfile(directory, 'templates_hue.mat');
    end
        
    for i=1:size(dataset_split,2)
        % fprintf('Image %s of %s\r', int2str(i), int2str( size(dataset_split,2)));
        % Read image
        im = imread(dataset_split(i).image);

        % Candidate Generation (pixel) 
        pixelCandidates1 = CandidateGenerationPixel(im, pixel_method, histogram);
        
        % Morphological filtering of candidate pixels
        pixelCandidates = MorphologicalFiltering(pixelCandidates1);

        % Candidate Generation (window)
        windowCandidates = CandidateGenerationWindow(im, pixelCandidates, window_method, templates); 

        % Filter candidate pixels with candidate windows 
        pixelCandidatesFinal=zeros(size(pixelCandidates));
        for ind=1:size(windowCandidates,1)
            pixelCandidatesFinal(windowCandidates(ind).y:windowCandidates(ind).y+windowCandidates(ind).h - 1, ...
            windowCandidates(ind).x:windowCandidates(ind).x+windowCandidates(ind).w - 1) = ...
            pixelCandidates(windowCandidates(ind).y:windowCandidates(ind).y+windowCandidates(ind).h - 1, ...
            windowCandidates(ind).x:windowCandidates(ind).x+windowCandidates(ind).w - 1);
        end
        
        % Accumulate pixel performance of the current image 
        pixelAnnotation = imread(dataset_split(i).mask)>0;
        
        % Original pixel candidates
        [localPixelTP, localPixelFP, localPixelFN, localPixelTN] = ...
            PerformanceAccumulationPixel(pixelCandidates, pixelAnnotation);
        pixelTP = pixelTP + localPixelTP;
        pixelFP = pixelFP + localPixelFP;
        pixelFN = pixelFN + localPixelFN;
        pixelTN = pixelTN + localPixelTN;
        
        % Post-filtered pixel candidates
        [localPixelTP_post, localPixelFP_post, localPixelFN_post, localPixelTN_post] = ...
            PerformanceAccumulationPixel(pixelCandidatesFinal, pixelAnnotation);
        pixelTP_post = pixelTP_post + localPixelTP_post;
        pixelFP_post = pixelFP_post + localPixelFP_post;
        pixelFN_post = pixelFN_post + localPixelFN_post;
        pixelTN_post = pixelTN_post + localPixelTN_post;

        % Accumulate object performance of the current image %%%%%%%%%%%%%%%%  (Needed after Week 3)
        windowAnnotations = LoadAnnotations(dataset_split(i).annotations);
        [localWindowTP, localWindowFN, localWindowFP] = PerformanceAccumulationWindow(windowCandidates, windowAnnotations);
        windowTP = windowTP + localWindowTP;
        windowFN = windowFN + localWindowFN;
        windowFP = windowFP + localWindowFP;
        
        % Show progress
        fprintf('Image %s of %s\r', int2str(i), int2str(size(dataset_split,2)));

        if plot_results 
            hAx_color = subplot(2, 2, 1);
            imshow(pixelCandidates1, 'Parent', hAx_color);
            title('Color segmentation');
            hAx_morph = subplot(2, 2, 2);
            imshow(pixelCandidates, 'Parent', hAx_morph);
            title('Morphological filtering');
            hAx_post = subplot(2, 2, 3);
            imshow(pixelCandidatesFinal, 'Parent', hAx_post);
            title('Pixel filtering with window candidates');
            hAx_window  =  subplot(2, 2, 4);
            imshow(im,'Parent', hAx_window);
            title('Window candidates over original image');
            for zz = 1:size(windowCandidates,1)
                r=imrect(hAx_window, [windowCandidates(zz,1).x, windowCandidates(zz,1).y, windowCandidates(zz,1).w, windowCandidates(zz,1).h]);
                setColor(r,'r');
            end
            pause(2);
        end
    end

    % Performance evaluation
    [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity] = ...
        PerformanceEvaluationPixel(pixelTP, pixelFP, pixelFN, pixelTN);
    Fmeasure = (2*pixelPrecision*pixelSensitivity)/(pixelPrecision+pixelSensitivity);
    fprintf('PIXEL-BASED EVALUATION\n')
    fprintf('-----------------------\n')
    fprintf('Precision: %f\n', pixelPrecision)
    fprintf('Recall: %f\n', pixelSensitivity)
    fprintf('Accuracy: %f\n', pixelAccuracy)
    fprintf('Specificity: %f\n', pixelSpecificity)
    fprintf('F measure: %f\n\n', Fmeasure)
    
    [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity] = ...
        PerformanceEvaluationPixel(pixelTP_post, pixelFP_post, pixelFN_post, pixelTN_post);
    Fmeasure = (2*pixelPrecision*pixelSensitivity)/(pixelPrecision+pixelSensitivity);
    fprintf('PIXEL-BASED EVALUATION (filtered with window candidates)\n')
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
