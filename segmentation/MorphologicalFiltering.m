function [ pixelCandidates ] = MorphologicalFiltering( pixelCandidates, method, small_obj_thr, strel_R)
%MORPHOLOGICALFILTERING Morphological filtering of candidate pixels
% Applies mathematical morphological techniques to the pixel candidates
% obtained in the color segmentation step in order to improve the
% segmentation performance

% DEFAULT DIAMOND RADIUS
DEFAULT_DIAM_R = 5;
% DEFAULT AREA OPENING OBJECT SIZE (METHOD 1)
DEFAULT_AO_SIZE_1 = 400;
% DEFAULT AREA OPENING OBJECT SIZE (METHOD 2)
DEFAULT_AO_SIZE_2 = 4000;
% DEFAULT METHOD
DEFAULT_METHOD = 1;

if nargin < 4
    strel_R = DEFAULT_DIAM_R;
end
if nargin < 3
   small_obj_thr_1 = DEFAULT_AO_SIZE_1;
   small_obj_thr_2 = DEFAULT_AO_SIZE_2;
else
    small_obj_thr_1 = small_obj_thr;
    small_obj_thr_2 = small_obj_thr;
end
if nargin < 2
    method = DEFAULT_METHOD;
end

switch(method)
    case 1
        % Area opening
        pixelCandidates = bwareaopen(pixelCandidates, small_obj_thr_1);

        % Dilation to connect disconnected components that survived the area
        % opening
        SE = strel('diamond', strel_R);
        pixelCandidates = imdilate(pixelCandidates, SE);
    case 2
        % Dilation to connect disconnected components that survived the area
        % opening
        SE = strel('diamond', strel_R);
        pixelCandidates = imdilate(pixelCandidates, SE);
        
        % Area opening
        pixelCandidates = bwareaopen(pixelCandidates, small_obj_thr_2);
    otherwise
        error('You must specify one of the two following methods: 1, 2');
end

% Fill holes
pixelCandidates = imfill(pixelCandidates, 'holes');

end

