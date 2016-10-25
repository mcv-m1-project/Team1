function [windowCandidates] = CandidateGenerationWindow(im, pixelCandidates, window_method)
%CANDIDATEGENERATIONWINDOW Window candidates from pixel candidates
%   Detailed explanation goes here

switch(window_method)
    case 'ccl'
        windowCandidates = CCLWindow(im, pixelCandidates);
    case 'naive_window'
        windowCandidates = SlidingWindow(im, pixelCandidates);
    case 'integral_window'
        windowCandidates = IntegralSlidingWindow(im, pixelCandidates);
    case 'convolution'
        windowCandidates = ConvSlidingWindow(im, pixelCandidates);
    otherwise
        % Default method: Connected Components Labeling
        windowCandidates = CCLWindow(im, pixelCandidates);     
end

% Window candidates arbitration

% TODO: mean, union, intersection, etc.

end