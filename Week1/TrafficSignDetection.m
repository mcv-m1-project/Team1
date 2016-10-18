%
% Template example for using on the validation set.
%

function TrafficSignDetection(directory, pixel_method, window_method, decision_method)

    % TrafficSignDetection
    % Perform detection of Traffic signs on images. Detection is performed first at the pixel level
    % using a color segmentation. Then, using the color segmentation as a basis, the most likely window 
    % candidates to contain a traffic sign are selected using basic features (form factor, filling factor). 
    % Finally, a decision is taken on these windows using geometric heuristics (Hough) or template matching.
    %
    %    Parameter name      Value
    %    --------------      -----
    %    'directory'         directory where the test images to analize  (.jpg) reside
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
    
    files = ListFiles(directory);
    histo_total=load('DataSetDelivered/HistALL_hsv.mat');
    histo_total = (histo_total.pdf./ max(max(histo_total.pdf)));% pdf normalization
            
    size(histo_total)
   
    tic
   % for i=1:size(files,1)
    
    [train_split, val_split] = read_train_val_split(directory);
    val_dataset = read_train_dataset([directory '/train/'], val_split);
    size(val_dataset,2)
    
    for i=1:size(val_dataset,2)
        disp(i/size(val_dataset,2)*100);
        % Read file
        % im = imread(strcat(directory,'/',files(i).name));
        im = imread(val_dataset(i).image);
        
        % Candidate Generation (pixel) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pixelCandidates = CandidateGenerationPixel_Color(im, pixel_method,histo_total);
        
        
        % Candidate Generation (window)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % windowCandidates = CandidateGenerationWindow_Example(im, pixelCandidates, window_method); %%'SegmentationCCL' or 'SlidingWindow'  (Needed after Week 3)
        
        % Accumulate pixel performance of the current image %%%%%%%%%%%%%%%%%
        % pixelAnnotation = imread(strcat(directory, '/mask/mask.', files(i).name(1:size(files(i).name,2)-3), 'png'))>0;
        pixelAnnotation = imread(val_dataset(i).mask)>0;
        
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
    [pixelTP, pixelFP, pixelFN, pixelTN]
    % Plot performance evaluation
    [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity] = PerformanceEvaluationPixel(pixelTP, pixelFP, pixelFN, pixelTN);
    % [windowPrecision, windowAccuracy] = PerformanceEvaluationWindow(windowTP, windowFN, windowFP); % (Needed after Week 3)
    
    [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity]
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

function [pixelCandidates] = CandidateGenerationPixel_Color(im, space,histo_total)

    im=double(im);
    switch space
        case 'normrgb'
            pixelCandidates = im(:,:,1)>100;
        case 'hsv'
        space='hsv';
            %%canviar el colorspace a HSV im_hsv=rgb2hsv(im)
          hist_individual = loadHistograms('', space,'_mod');
        histoABC = hist_individual{1};
        histoDF = hist_individual{2};
        histoE = hist_individual{3};
        histoABC=histoABC./max(max(histoABC));
        histoDF=histoDF/max(max(histoDF));
        histoE=histoE/max(max(histoE));
        
        %Initialize result mask
        pixelCandidates=zeros(size(im,1),size(im,2));
        
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
                if histoABC(round(H(s1,s2)*63)+1,round(S(s1,s2)*63)+1) > 0.1 || histoDF(round(H(s1,s2)*63)+1,round(S(s1,s2)*63)+1) > 0.1 || histoE(round(H(s1,s2)*63)+1,round(S(s1,s2)*63)+1) > 0.1
                    pixelCandidates(s1,s2)= 1;
                end
            end
        end
        case 'lab'
             
         %   I=colorspace('Lab-<',im);
         colorTransform = makecform('srgb2lab');
        I = applycform(im, colorTransform);
       
           a=I(:,:,2);
          b=I(:,:,3);
          for s1=1:size(im,1)
            for s2=1:size(im,2)
         %       disp(' a value')
          %      a(s1,s2)
           %     disp ('histogram value a')
            % round((a(s1,s2)+1001)/19.99)+1
            %  disp(' b value')
            %  b(s1,s2)
            %  disp('histogram value b')
           %  round((b(s1,s2)+1001)/19.99)+1
          pixelCandidates(s1,s2)= (histo_total(round((a(s1,s2)+201)/1.99)+1,round((b(s1,s2)+201)/1.99)+1) > 0.3);
       %  pixelCandidates= (histo_total(round(I(:,:,1)*63)+1,round(I(:,:,2)*63)+1) > 0.5);
            end
        end
    otherwise
        error('Incorrect color space defined');
        return
end
end


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
for t=thresholdRange,
    TP=0;
    FP=0;
    for i=1:size(scores,1),
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

