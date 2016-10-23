function [pixelCandidates] = CandidateGenerationPixel(im, space, histogram, threshold)

% NORMALIZATION METHOD
normmethod = 'a'; %'paper' for the normalization of Swain Ballard's paper
% anything else for a simple hist/max(hist) normalization

% DEFAULT RGB THRESHOLD
DEFAULT_RGB_THRESHOLD = 100;

% DEFAULT HSV THRESHOLD
DEFAULT_HSV_THRESHOLD = 0.092;

if nargin < 4
    % Default thresholds
    normrgb_threshold = DEFAULT_RGB_THRESHOLD;
    if strcmp(normmethod, 'paper')
        hsv_threshold = 0.23;
    else 
        hsv_threshold = 0.092;
    end
    
else
    normrgb_threshold = threshold;
    hsv_threshold = threshold;
end

im=double(im);
switch space
    case 'normrgb'
        pixelCandidates = im(:,:,1) > normrgb_threshold;
    case 'hsv'
        
        %Initialize result mask
        pixelCandidates=zeros(size(im,1),size(im,2));
        
        %Transform the image to HSV
        im_cs=rgb2hsv(im);
        %Take the Hue and Saturation components
        H=im_cs(:,:,1);
        S=im_cs(:,:,2);
        
        %Eliminate non-red (8%-85%)or non-blue(0-55%,65%-100) values from
        %the model histogram
        percR1 = 10; percR2 = 55; percB1 = 35; percB2 = 50;
        histogram(percR1:percB1,:)=0;
        histogram(percB2:percR2,:)=0;
        
        if strcmp(normmethod, 'paper')
            %Eliminate low saturated values from the model histogram
            grays = 30;
            histogram(:,1:grays)=0;
            
            %Reshape H & S into vectors
            h = reshape(H,numel(H),1);
            s = reshape(S,numel(S),1);
            
            %Create edges of the histogram
            n1=0:1/63:1;
            n2=0:1/63:1;
            edges = {n1; n2};
            
            %Compute the histogram of the test image
            histI = hist3([h,s],'Edges', edges);
            
            %In order to avoid divisions by 0, put all the 0 in the image
            %histogram to -1
            histI(histI==0) = -1;
            %Normalize the model histogram with the test image histogram
            histogram = histogram./histI;
            %Put back to 0 the values that were changed to -1
            histogram(histogram < 0) = 0;
        else
            %Eliminate low saturated values
            grays = 20;
            histogram(:,1:grays)=0;
            histogram = histogram / max(max(histogram));
        end
        
        %For each pixel in the test image, check its probability of
        %belonging to a signal (if its color is represented in the signal
        %histograms)
        for s1=1:size(im,1)
            for s2=1:size(im,2)
                if histogram(round(H(s1,s2)*63)+1,round(S(s1,s2)*63)+1) >= hsv_threshold
                    pixelCandidates(s1,s2)= 1;
                end
            end
        end
        
    otherwise
        error('Incorrect color space defined');
end
end

