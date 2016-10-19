function [ pixelCandidates ] = MorphologicalFiltering( im, small_obj_thr, strel_R)
%MORPHOLOGICALFILTERING Morphological filtering of candidate pixels
% Applies mathematical morphological techniques to the pixel candidates
% obtained in the color segmentation step in order to improve the
% segmentation performance

if nargin < 3
    strel_R = 5;
end
if nargin < 2
   small_obj_thr = 100;
end 

% Area opening
pixelCandidates = bwareaopen(im, small_obj_thr);

% Dilation to connect disconnected components that survived the area
% opening
SE = strel('diamond', strel_R);
pixelCandidates = imdilate(pixelCandidates, SE);

% Fill holes
pixelCandidates = imfill(pixelCandidates, 'holes');

end

