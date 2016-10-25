function [ windowCandidates ] = SlidingWindow( im, pixelCandidates )
%SLIDINGWINDOW Summary of this function goes here
%   Detailed explanation goes here

window_maxsize = 100;
window_minsize = 10;
windowCandidates = [];
xmin = 16000;
ymin = 16000;
xmax = 0;
ymax = 0;
num_pos_pixels = 0;
for yindex=1:size(pixelCandidates,1)-window_maxsize
    for xindex=1:size(pixelCandidates,2)-window_maxsize
        if pixelCandidates(yindex, xindex)==1
            num_pos_pixels = num_pos_pixels + 1;
            if xmin>xindex
                xmin=xindex;
            elseif xmax<xindex
                xmax=xindex;
            end
            if ymin>yindex
                ymin=yindex;
            elseif ymax<yindex
                ymax=yindex;
            end
        end
    end
end

% tic

if num_pos_pixels > 0
    total_operations = 0;
    for winx=window_maxsize:-3:window_minsize
        winy=winx-8;
        for i=xmin:5:xmax-winx
            for j=ymin:5:ymax-winy
                bbox=[j, i, j+winy, i+winx];
                fr=filling_ratio(bbox, pixelCandidates);
                if ((fr>0.47 && fr<0.53) || (fr>0.77 && fr<0.83) || (fr>0.97 && fr<1.05))
                    box_struct = struct('x', i, 'y', j, 'w', winx, 'h', winy);
                    windowCandidates=[windowCandidates; box_struct];
                    % FIXME: Debug only
                    % imshow(pixelCandidates);
                    % hold on;
                    % rectangle('Position', [i, j, winx, winy], 'EdgeColor', 'r');
                end
                total_operations = total_operations + 1;
            end
        end 
    end
else
    disp('No pixel candidates available. Skipping this image...');
end
    
% toc
% fprintf('Total number of sliding windows per image: %s\n', int2str(total_operations));


% [x,y]=size(pixelCandidates);
% sub_pixelCandidates(:,:,1)=pixelCandidates(1:ceil(x/2),1:ceil(y/2));
% sub_pixelCandidates(:,:,2)=pixelCandidates(ceil(x/2)+1:x,1:ceil(y/2));
% sub_pixelCandidates(:,:,3)=pixelCandidates(1:ceil(x/2),ceil(y/2)+1:y);
% sub_pixelCandidates(:,:,4)=pixelCandidates(ceil(x/2)+1:x,ceil(y/2)+1:y);
% for id=1:4
%     tic
%     if sum(sum(sub_pixelCandidates(:,:,id)))>50
%         for winx=window_maxsize:-3:window_minsize
%             winy=winx+4;
%             for i=1:4:size(sub_pixelCandidates(:,:,id),1)-winx
%                 for j=1:4:size(sub_pixelCandidates(:,:,id),2)-winy
%                     bbox=[i, j, i+winx, j+winy];
%                     %%img_win=sub_pixelCandidates(bbox(1):bbox(3),bbox(2):bbox(4))>1;
%                     %%if (filling_ratio(bbox, img_win)>0.49 && filling_ratio(bbox, img_win)<0.51) ||(filling_ratio(bbox, img_win)>0.79 && filling_ratio(bbox, img_win)<0.81) || (filling_ratio(bbox, img_win)>0.98 && filling_ratio(bbox, img_win)<1.05)
%                     fr=filling_ratio(bbox, sub_pixelCandidates(:,:,id));
%                     %%if ((filling_ratio(bbox, sub_pixelCandidates(:,:,id))>0.49 && filling_ratio(bbox, sub_pixelCandidates(:,:,id))<0.51) ||(filling_ratio(bbox, sub_pixelCandidates(:,:,id))>0.79 && filling_ratio(bbox, sub_pixelCandidates(:,:,id))<0.81) || (filling_ratio(bbox, sub_pixelCandidates(:,:,id))>0.98 && filling_ratio(bbox, sub_pixelCandidates(:,:,id))<1.05))&&(calculate==1)
%                     if ((fr>0.47 && fr<0.53) || (fr>0.77 && fr<0.83) || (fr>0.97 && fr<1.05))
%                         windowCandidates=[windowCandidates; bbox];
%                         
%                     end
% 
%                 end
%             end
%         end
%     end
%     toc
% end

end

