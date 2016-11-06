function [windowCandidates] = TemplateMatchingCorrelation(im, pixelCandidates, templates)
%TEMPLATECORRELATION Summary of this function goes here
%   Detailed explanation goes here

debug = 0;
xmin = 16000;
ymin = 16000;
xmax = 0;
ymax = 0;
[y,x]=size(pixelCandidates);
windowCandidates = [];

% Load templates and transform image accordingly
[~, name, ~] = fileparts(templates);
if strcmp(name, 'templates')
    load(templates);
    im=rgb2gray(im);
elseif strcmp(name, 'templates_hue')
    load(templates);
    im = rgb2hsv(im);
    im = im(:, :, 1);
else
    error('The specified template is not supported.');
end

% Split image in 4 sections
for id=1:4
    if id==1
        x_range=1:ceil(x/2);
        y_range=1:ceil(y/2);
    elseif id==2
        x_range=ceil(x/2)+1:x;
        y_range=1:ceil(y/2);
    elseif id==3
        x_range=1:ceil(x/2);
        y_range=ceil(y/2)+1:y;
    else
        x_range=ceil(x/2)+1:x;
        y_range=ceil(y/2)+1:y;
    end
  
    if nnz(pixelCandidates(y_range, x_range))
        % Finding the minimum and maximum position of "whites" in the image
        % to slide the window inside this part, instead of slide the window 
        % through the entire image.
        for a=x_range
            for b=y_range
                if pixelCandidates(b,a)==1
                    %num_pos_pixels = num_pos_pixels + 1;
                    if xmin>a
                        xmin=a;
                    elseif xmax<a
                        xmax=a;
                    end
                    if ymin>b
                        ymin=b;
                    elseif ymax<b
                        ymax=b;
                    end
                end
            end
        end    
        c_im=im(ymin:ymax,xmin:xmax);
        c_im(pixelCandidates(ymin:ymax, xmin:xmax)==0)=-100;
        im_y_offset = ymin;
        im_x_offset = xmin;
                
        % Reset xmin, ymin, xmax and ymax
        xmin = 16000;
        ymin = 16000;
        xmax = 0;
        ymax = 0;
        
        for temp=1:length(templates)
            for j=30:10:250
                re_template=imresize(templates{temp},j/250);
                if (size(re_template)<size(c_im))
                    % Cross correlation
                    C = normxcorr2( re_template,c_im);
                    
                    if debug
                        subplot(1,4,1)
                        imshow(c_im)
                        title('Partitioned image')
                    end
                                
                    % Find peaks of the correlation
                    marked_C=C;
                    if max(max(C)) > 0.65
                        [~, peaks] = FastPeakFind(C);
                        [ypeak,xpeak] = find(peaks);
            
                        for n = 1:size(ypeak,1)
                            if C(ypeak(n),xpeak(n)) > 0.65
                                yoffSet = ypeak(n)-round(size(re_template, 1));
                                xoffSet = xpeak(n)-round(size(re_template, 2));
                                if yoffSet < 0 || xoffSet < 0
                                    break
                                end
                                % Candidate window
                                bbox = [im_x_offset + xoffSet + 1, im_y_offset + yoffSet + 1, ...
                                size(re_template,2), size(re_template,1)];
                                windowCandidates=[windowCandidates; bbox];
                                % Mark peak and draw candidate window
                                c_bbox = [xoffSet, yoffSet, size(re_template, 2), size(re_template, 1)];
                                marked_C=insertMarker(C, [xoffSet+1+size(re_template, 2),yoffSet+1+size(re_template,1)]);
                                if debug
                                    rectangle('Position', c_bbox, 'EdgeColor', 'r', 'LineWidth', 1.5);
                                end
                            end
                        end
                    end
                    
                    % Plot peaks of correlation if debug is on
                    if debug==1
                        subplot(1,4,2);
                        imshow(marked_C)
                        title('Correlation with marker on the peaks')
                        subplot(1,4,3)
                        surf(C);
                        title('3D surface of the correlation');
                        subplot(1,4,4)
                        imshow(re_template)
                        title('Template')
                        pause(0.5);
                    end
                end
            end
        end
    end
end
end

