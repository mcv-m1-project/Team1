function [windowCandidatesFinal] = CandidateGenerationWindow(im, pixelCandidates, window_method)
%CANDIDATEGENERATIONWINDOW Window candidates from pixel candidates
%   Detailed explanation goes here

switch(window_method)
    case 'ccl'
        windowCandidates = CCLWindow(im, pixelCandidates);
    case {'naive_window', 'integral_window' }
        windowCandidates = SlidingWindow(im, pixelCandidates, window_method);
    case 'convolution'
        windowCandidates = ConvSlidingWindow(im, pixelCandidates);
    otherwise
        % Default method: Connected Components Labeling
        windowCandidates = CCLWindow(im, pixelCandidates);     
end

% Window candidates arbitration
del=[];
N = size(windowCandidates, 1);
for i=1:N
    if nnz(del==i)==0
        for j=i+1:N
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

%Window candidates post-filtering
keep=[];
N = size(windowCandidates, 1);
for ind=1:N
    bbox = [windowCandidates(ind, 2), windowCandidates(ind, 1), ...
            min(windowCandidates(ind, 2) + windowCandidates(ind, 4), size(pixelCandidates, 1)), ...
            min(windowCandidates(ind, 1) + windowCandidates(ind, 3), size(pixelCandidates, 2))];
    f_factor = form_factor(bbox);
    if (f_factor > 0.5 && f_factor < 2)
        keep = [keep ind];
    end
end
windowCandidates = windowCandidates(keep, :);

% Window candidates transformation to struct
windowCandidatesFinal=[];
N = size(windowCandidates, 1);
for i=1:N
    box_struct = struct('x', windowCandidates(i,1), 'y', windowCandidates(i,2), 'w', windowCandidates(i,3), 'h', windowCandidates(i,4));
    windowCandidatesFinal=[windowCandidatesFinal; box_struct];
end

end