function [windowCandidatesFinal] = CandidateGenerationWindow(im, pixelCandidates, window_method)
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
del=[];
for i=1:size(windowCandidates,1)
    if nnz(del==i)==0
        for j=i+1:size(windowCandidates,1)
           if nnz(del==j)==0
               dist=norm(windowCandidates(i)-windowCandidates(j));
               if dist<200
                   windowCandidates(i,1)=min(windowCandidates(i,1),windowCandidates(j,1));
                   windowCandidates(i,2)=min(windowCandidates(i,2),windowCandidates(j,2));
                   windowCandidates(i,3)=max(windowCandidates(i,3),windowCandidates(j,3));
                   windowCandidates(i,4)=max(windowCandidates(i,4),windowCandidates(j,4));
                   del=[del j];
               end
           end
        end
    end
end
windowCandidates(del,:)=[];
windowCandidatesFinal=[];
for i=1:size(windowCandidates,1)
    box_struct = struct('x', windowCandidates(i,1), 'y', windowCandidates(i,2), 'w', windowCandidates(i,3), 'h', windowCandidates(i,4));
    windowCandidatesFinal=[windowCandidatesFinal; box_struct];
    
end
% TODO: mean, union, intersection, etc.

end