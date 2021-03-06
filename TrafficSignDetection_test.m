%
% Template example for using on the test set (no annotations).
%

function TrafficSignDetection_test(input_dir, output_dir, segm_method, pixel_method, window_method, plot_results)
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
%    'segm_method'       'mean_shift', 'ucm'
%    'pixel_method'      Name of the color space: 'normrgb', 'hsv'
%    'window_method'     'ccl', 'naive_window', 'integral_window', 'convolution'
%    'plot_results'      0 or 1


global CANONICAL_W;        CANONICAL_W = 64;
global CANONICAL_H;        CANONICAL_H = 64;
global SW_STRIDEX;         SW_STRIDEX = 8;
global SW_STRIDEY;         SW_STRIDEY = 8;
global SW_CANONICALW;      SW_CANONICALW = 32;
global SW_ASPECTRATIO;     SW_ASPECTRATIO = 1;
global SW_MINS;            SW_MINS = 1;
global SW_MAXS;            SW_MAXS = 2.5;
global SW_STRIDES;         SW_STRIDES = 1.2;

files = ListFiles(input_dir);

% Check pixel method
if strcmp(pixel_method, '')
    % Use default: HSV
    pixel_method = 'hsv';
end

%Load histogram
histogram = loadHistograms('joint', pixel_method,'');

% Load templates for correlation method
if(strcmp(window_method,'template_corr'))
    templates = fullfile('DataSetDelivered', 'templates.mat');
else
    templates='';
end

% Measure time
tic
for i=1:size(files,1)
    
    % Read file
    im = imread(strcat(input_dir,'/',files(i).name));
    
    % Image segmentation / Pixel candidate generation
    if ~strcmp(segm_method, '')
        pixelCandidates1 = ImageSegmentation(im, segm_method);
        segm_im=pixelCandidates1;
    else
        segm_im = im;
        pixelCandidates1 = CandidateGenerationPixel(segm_im, pixel_method, histogram);
    end
    
    % Morphological filtering of candidate pixels
    if strcmp(segm_method, 'ucm')
        pixelCandidates = MorphologicalFiltering(pixelCandidates1, 5);
    else
        pixelCandidates = MorphologicalFiltering(pixelCandidates1);
    end
    
    % Candidate Generation Window
    windowCandidates = CandidateGenerationWindow(segm_im, pixelCandidates, window_method, templates, histogram);  
    
    % Filter candidate pixels with candidate windows
    pixelCandidatesFinal=zeros(size(pixelCandidates));
    for ind=1:size(windowCandidates,1)
        pixelCandidatesFinal(windowCandidates(ind).y:windowCandidates(ind).y+windowCandidates(ind).h - 1, ...
            windowCandidates(ind).x:windowCandidates(ind).x+windowCandidates(ind).w - 1) = ...
            pixelCandidates(windowCandidates(ind).y:windowCandidates(ind).y+windowCandidates(ind).h - 1, ...
            windowCandidates(ind).x:windowCandidates(ind).x+windowCandidates(ind).w - 1);
    end
    pixelCandidates = pixelCandidatesFinal;
    
    out_file = strcat(output_dir,'/m',files(i).name);
    out_file1 = strrep(out_file, 'jpg', 'png');
    out_file2 = strrep(out_file, 'jpg', 'mat');
    imwrite (pixelCandidates,out_file1);
    save(out_file2, 'windowCandidates');
    
    % Show progress
    fprintf('Image %s of %s\r', int2str(i), int2str(size(files,1)));
    
    if plot_results
        hAx  = axes;
        imshow(pixelCandidates,'Parent', hAx);
        for zz = 1:size(windowCandidates,1)
            r=imrect(hAx, [windowCandidates(zz,1).x, windowCandidates(zz,1).y, windowCandidates(zz,1).w, windowCandidates(zz,1).h]);
            setColor(r,'r');
        end
    end
    
end

elapsed_time = toc;
fprintf('Total time: %s\n', num2str(elapsed_time));
fprintf('Number of images: %s\n', int2str(size(files, 1)));
fprintf('Mean time spend on each image: %s s\n', num2str(elapsed_time / size(files,1)));

end
