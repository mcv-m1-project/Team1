function [ windowCandidates ] = CCLWindow( im, pixelCandidates )
%CCL_WINDOW Summary of this function goes here
%   Detailed explanation goes here

CC = bwconncomp(pixelCandidates);
stats = regionprops(CC, 'BoundingBox');
N = length(stats);
windowCandidates = zeros(N, 4);
for m=1:N
    windowCandidates(m, :) = ceil(stats(m).BoundingBox);
end

end

