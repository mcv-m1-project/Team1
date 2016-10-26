function [ windowCandidates ] = SlidingWindow( im, pixelCandidates )
%SLIDINGWINDOW Summary of this function goes here
%   Detailed explanation goes here

window_maxsize = 240;
window_minsize = 25;
windowCandidates = [];
xmin = 16000;
ymin = 16000;
xmax = 0;
ymax = 0;
[y,x]=size(pixelCandidates);
%num_pos_pixels = 0;
% for yindex=1:size(pixelCandidates,1)-window_maxsize
%     for xindex=1:size(pixelCandidates,2)-window_maxsize
%         if pixelCandidates(yindex, xindex)==1
%             num_pos_pixels = num_pos_pixels + 1;
%             if xmin>xindex
%                 xmin=xindex;
%             elseif xmax<xindex
%                 xmax=xindex;
%             end
%             if ymin>yindex
%                 ymin=yindex;
%             elseif ymax<yindex
%                 ymax=yindex;
%             end
%         end
%     end
% end

% tic

%if num_pos_pixels > 0
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
    total_operations = 0;
    if nnz(pixelCandidates(y_range, x_range))
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
        for winx=window_maxsize:-3:window_minsize
            winy=winx-8;
            ymaxx=ymax;
            xmaxx=xmax;
            if xmax>size(pixelCandidates,2)-winx
                xmaxx=size(pixelCandidates,2)-winx;
            end
            if ymax>size(pixelCandidates,1)-winy
                ymaxx=size(pixelCandidates,1)-winy;
            end
            for i=xmin:xmaxx
                for j=ymin:ymaxx
                    bbox=[j, i, j+winy, i+winx];
                    fr=filling_ratio(bbox, pixelCandidates);
                    row_up=pixelCandidates(j,i:i+winx);
                    col_left=pixelCandidates(j:j+winy,i);
                    row_down=pixelCandidates(j+winy, i:i+winy);
                    if nnz(row_up) && nnz(col_left) && nnz(row_down)
                        if ((fr>0.47 && fr<0.53) || (fr>0.77 && fr<0.83) || (fr>0.97 && fr<1.05))
                            box_struct = struct('x', i, 'y', j, 'w', winx, 'h', winy);
                            winx;
                            winy;
                            windowCandidates=[windowCandidates; box_struct];
                            % FIXME: Debug only
                            % imshow(pixelCandidates);
                            % hold on;
                            % rectangle('Position', [i, j, winx, winy], 'EdgeColor', 'r');
                        end
                    end
                    total_operations = total_operations + 1;
                end
            end
        end
    end
end
%else
%    disp('No pixel candidates available. Skipping this image...');
%end
    
% toc
% fprintf('Total number of sliding windows per image: %s\n', int2str(total_operations));


 
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

