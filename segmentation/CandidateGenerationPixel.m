function [pixelCandidates] = CandidateGenerationPixel(im, space, histogram, threshold)

    if nargin < 4
        % Default thresholds
        normrgb_threshold = 100;
        hsv_threshold = 0.092;
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
            
            %For each pixel in the test image, check its probability of
            %belonging to a signal (if its color is represented in the signal
            %histograms)
            for s1=1:size(im,1)
                for s2=1:size(im,2)
                    if histogram(round(H(s1,s2)*63)+1,round(S(s1,s2)*63)+1) > hsv_threshold
                        pixelCandidates(s1,s2)= 1;
                    end
                end
            end
            
        otherwise
            error('Incorrect color space defined');
    end
end

