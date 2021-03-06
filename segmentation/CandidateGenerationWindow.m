function [windowCandidatesFinal] = CandidateGenerationWindow(im, pixelCandidates, window_method, templates, histogram)
%CANDIDATEGENERATIONWINDOW Window candidates from pixel candidates

pixel_method='hsv';
switch(window_method)
    case 'ccl'
        windowCandidates = CCLWindow(im, pixelCandidates);
        windowCandidates = candidatesArbitration(windowCandidates,window_method, histogram, im);
        windowCandidates = candidatesPostFiltering(windowCandidates);
    case {'naive_window', 'integral_window' }
        windowCandidates = SlidingWindow(im, pixelCandidates, window_method);
        windowCandidates = candidatesArbitration(windowCandidates,window_method, histogram, im);
    case 'template_matching'
        windowCandidates = TemplateMatchingChamfer(im, pixelCandidates, pixel_method, histogram);
        windowCandidates = candidatesArbitration(windowCandidates,window_method, histogram, im);
    case 'correlation'
        [mask,split] = splitMask(pixelCandidates);
        if split == 0
            %Image is empty
            windowCandidates = candidatesArbitration([],window_method, histogram, im);
        else
            [r,c] = size(pixelCandidates);

            %Look for triangles
            windowCandidatesT = ConvSlidingWindow(mask,split,r,c,'tri');
            windowCandidates = candidatesArbitration(windowCandidatesT,window_method, histogram, im);
    
            %Look for circles
            windowCandidatesC = ConvSlidingWindow(mask,split,r,c,'circ');
            windowCandidates = [windowCandidates; candidatesArbitration(windowCandidatesC,window_method, histogram,im)];
   
            %Look for inverted triangles
            windowCandidatesIT = ConvSlidingWindow(mask,split,r,c,'invtri');
            windowCandidates = [windowCandidates; candidatesArbitration(windowCandidatesIT,window_method, histogram, im)];

            %Look for rectangles/squares
            windowCandidatesR = ConvSlidingWindow(mask,split,r,c,'rect');
            windowCandidates = [windowCandidates; candidatesArbitration(windowCandidatesR,window_method, histogram, im)];
        end
    case 'template_corr'
        windowCandidates=TemplateMatchingCorrelation (im, pixelCandidates, templates);
        windowCandidates = candidatesArbitration(windowCandidates, window_method, histogram, im);
    case 'hough'
        windowCandidates=HoughTransform(im, pixelCandidates);
        windowCandidates = candidatesArbitration(windowCandidates, window_method, histogram, im);

    otherwise
        error ('No valid method selected. Use one of these instead: ccl, naive_window, integral_window, correlation, template_matching, template_corr, hough');
end

% Window candidates transformation to struct
windowCandidatesFinal=[];
N = size(windowCandidates, 1);
[im_height, im_width] = size(pixelCandidates);
for i=1:N
    box_struct = struct(...
        'x', max(windowCandidates(i,1), 1), ...
        'y', max(windowCandidates(i,2), 1), ...
        'w', min(windowCandidates(i,3), im_width - windowCandidates(i,1)), ...
        'h', min(windowCandidates(i,4), im_height - windowCandidates(i,2)));
    windowCandidatesFinal=[windowCandidatesFinal; box_struct];
end

end

%% CANDIDATES ARBITRATION
function windCandidates = candidatesArbitration(windowCandidates, window_method, histogram, im)
% Window candidates arbitration
del=[];
for i=1:size(windowCandidates,1)
    if nnz(del==i)==0
        for j=i+1:size(windowCandidates,1)
            if nnz(del==j)==0
                switch(window_method)
                    case {'correlation', 'template_matching', 'hough'}
                        if abs(windowCandidates(i,2) - windowCandidates(j,2))<=max([windowCandidates(i,3),windowCandidates(j,3)])/2
                            windowCandidates(i,1)=min(windowCandidates(i,1),windowCandidates(j,1));
                            windowCandidates(i,2)=min(windowCandidates(i,2),windowCandidates(j,2));
                            windowCandidates(i,3)=max(windowCandidates(i,3),windowCandidates(j,3));
                            windowCandidates(i,4)=max(windowCandidates(i,4),windowCandidates(j,4));
                            del=[del j];
                        end
                        
                    otherwise
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
end
windowCandidates(del,:)=[];  
del=[];

% Filter window candidates by color (only Chamfer template matching)
if strcmp(window_method, 'template_matching')
    for i=1:size(windowCandidates,1)
        if sum(sum(CandidateGenerationPixel(im(windowCandidates(i,2):windowCandidates(i,2)+windowCandidates(i,4), windowCandidates(i,1):windowCandidates(i,1)+windowCandidates(i,3),:), 'hsv', histogram)))<600
            del = [del, i];
        end
    end
end

windowCandidates(del,:)=[];  
windCandidates = windowCandidates;
end

%% CANDIDATES POST-FILTERING
function winCandidates = candidatesPostFiltering(windowCandidates)
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
winCandidates = windowCandidates(keep, :);
end
