%
% Template example for using on the test set (no annotations).
%

function TrafficSignDetection_test(input_dir, output_dir, pixel_method, window_method, decision_method)
% TrafficSignDetection
% Perform detection of Traffic signs on images. Detection is performed first at the pixel level
% using a color segmentation. Then, using the color segmentation as a basis, the most likely window
% candidates to contain a traffic sign are selected using basic features (form factor, filling factor).
% Finally, a decision is taken on these windows using geometric heuristics (Hough) or template matching.
%
%    Parameter name      Value
%    --------------      -----
%    'input_dir'         Directory where the test images to analize  (.jpg) reside
%    'output_dir'        Directory where the results are stored
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

files = ListFiles(input_dir);

%Load histogram
histogram = loadHistograms('joint', pixel_method,'');
%Normalize histogram
histogram = histogram/max(max(histogram));

for i=1:size(files,1)
    
    % Read file
    im = imread(strcat(input_dir,'/',files(i).name));
    
    % Candidate Generation (pixel) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pixelCandidates = CandidateGenerationPixel_Color(im, pixel_method, histogram);
    
    
    % Candidate Generation (window)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % windowCandidates = CandidateGenerationWindow_Example(im, pixelCandidates, window_method); %%'SegmentationCCL' or 'SlidingWindow'  (Needed after Week 3)
    
    
    %out_file1 = sprintf ('%s/test/pixelCandidates.mat',  output_dir);
    %out_file1 = sprintf ('%s/test/windowCandidates.mat', output_dir);
    out_file1 = strcat(output_dir,'/m',files(i).name);
    imwrite (pixelCandidates,out_file1);
    %save (out_file2, 'windowCandidates');
end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CandidateGeneration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [pixelCandidates] = CandidateGenerationPixel_Color(im, space, histogram)

im=double(im);

switch space
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
                if histogram(round(H(s1,s2)*63)+1,round(S(s1,s2)*63)+1) > 0.1
                    pixelCandidates(s1,s2)= 1;
                end
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
