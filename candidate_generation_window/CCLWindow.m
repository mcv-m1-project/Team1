function [ windowCandidates ] = CCLWindow( im, pixelCandidates )
%CCL_WINDOW Summary of this function goes here
%   Detailed explanation goes here

CC = bwconncomp(pixelCandidates);
stats = regionprops(CC, 'BoundingBox');
N = length(stats);
windowCandidates = zeros(N, 4);
for m=1:N
    bbox = ceil(stats(m).BoundingBox);
    % Check size is within the established limits
    if bbox(3) > 30 && bbox(3) < 250 && bbox(4) > 30 && bbox(4) < 250
        windowCandidates(m, :) = bbox;
    end
end

end

