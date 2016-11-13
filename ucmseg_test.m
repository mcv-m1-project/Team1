windowTP=0; windowFN=0; windowFP=0; % (Needed after Week 3)
pixelTP=0; pixelFN=0; pixelFP=0; pixelTN=0;
pixelTP_post=0; pixelFN_post=0; pixelFP_post=0; pixelTN_post=0;
files = ListFiles('ucmSeg04');
templates = fullfile('DataSetDelivered/', 'templates.mat');
PROPORTION = 0.85;
for i = 1:length(files)
    
    im = imread(strcat('DataSetDelivered/train/',files(i).name(4:end-3),'jpg'));
    mask = imread(strcat('DataSetDelivered/train/mask/mask.',files(i).name(4:end)));
    eg = imread(strcat(files(i).folder,'/',files(i).name));
    output = zeros(size(mask));
    
    hsv = rgb2hsv(im);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    
    labels = unique(eg);
    for j=1:size(labels,1)
        region = eg == labels(j);
        
        if nnz(region) < 100 || nnz(region) > 30000
            continue
        end
        
        color_filter = (...
            (...
            (h(region) >= 0.9) + (h(region) <= 0.1)  + ( (h(region) >= 0.45) .* (h(region) <= 0.7) ) ...
            ) .* ( (s(region) >= 0.5) + (v(region) >= 0.2) ) ...
            );
        proportion = nnz(color_filter) / numel(color_filter);
        
        if proportion >= PROPORTION
            output(region) = 1;
        end
        
    end
    
    output=imfill(output,'holes');
    
%     subplot(1,2,1)
%     imshow(255*mask)
%     subplot(1,2,2)
%     imshow(255*output)
%     drawnow()   
    
    
    [localPixelTP, localPixelFP, localPixelFN, localPixelTN] = ...
        PerformanceAccumulationPixel(output, mask);
    pixelTP = pixelTP + localPixelTP;
    pixelFP = pixelFP + localPixelFP;
    pixelFN = pixelFN + localPixelFN;
    pixelTN = pixelTN + localPixelTN;
    
    
    
     windowCandidates = CandidateGenerationWindow(im, output, 'hough', templates, []);
    
    % Filter candidate pixels with candidate windows 
    pixelCandidates = output;
    pixelAnnotation = mask;
    pixelCandidatesFinal=zeros(size(output));
    for ind=1:size(windowCandidates,1)
        pixelCandidatesFinal(windowCandidates(ind).y:windowCandidates(ind).y+windowCandidates(ind).h - 1, ...
        windowCandidates(ind).x:windowCandidates(ind).x+windowCandidates(ind).w - 1) = ...
        pixelCandidates(windowCandidates(ind).y:windowCandidates(ind).y+windowCandidates(ind).h - 1, ...
        windowCandidates(ind).x:windowCandidates(ind).x+windowCandidates(ind).w - 1);
    end
    
    % Post-filtered pixel candidates
    [localPixelTP_post, localPixelFP_post, localPixelFN_post, localPixelTN_post] = ...
        PerformanceAccumulationPixel(pixelCandidatesFinal, mask);
    pixelTP_post = pixelTP_post + localPixelTP_post;
    pixelFP_post = pixelFP_post + localPixelFP_post;
    pixelFN_post = pixelFN_post + localPixelFN_post;
    pixelTN_post = pixelTN_post + localPixelTN_post;

    % Accumulate object performance of the current image 
    windowAnnotations = LoadAnnotations(strcat('DataSetDelivered/train/gt/gt.',files(i).name(4:end-3),'txt'));
    
    [localWindowTP, localWindowFN, localWindowFP] = PerformanceAccumulationWindow(windowCandidates, windowAnnotations);
    windowTP = windowTP + localWindowTP;
    windowFN = windowFN + localWindowFN;
    windowFP = windowFP + localWindowFP; 
    
    
    %imwrite(pixelCandidatesFinal, strcat('ucm04MaskTemp/m', files(i).name));
    fprintf('Image %s of %s\r', int2str(i), int2str(size(files,1)));
end

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
Fmeasure = (2*windowPrecision*windowRecall)/(windowPrecision+windowRecall);
fprintf('REGION-BASED EVALUATION\n')
fprintf('-----------------------\n')
fprintf('Precision: %f\n', windowPrecision)
fprintf('Recall: %f\n', windowRecall)
fprintf('Accuracy: %f\n', windowAccuracy)
fprintf('F measure: %f\n\n', Fmeasure)