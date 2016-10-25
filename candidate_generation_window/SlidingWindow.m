function [ windowCandidates ] = SlidingWindow( im, pixelCandidates )
%SLIDINGWINDOW Summary of this function goes here
%   Detailed explanation goes here

[x,y]=size(pixelCandidates);
sub_pixelCandidates(:,:,1)=pixelCandidates(1:ceil(x/2),1:ceil(y/2));
sub_pixelCandidates(:,:,2)=pixelCandidates(ceil(x/2)+1:x,1:ceil(y/2));
sub_pixelCandidates(:,:,3)=pixelCandidates(1:ceil(x/2),ceil(y/2)+1:y);
sub_pixelCandidates(:,:,4)=pixelCandidates(ceil(x/2)+1:x,ceil(y/2)+1:y);
window_maxsize=100;
window_minsize=10;
windowCandidates=[];
xmin=16000;
ymin=16000;
xmax=0;
ymax=0;
% for xindex=1:size(pixelCandidates,1)-window_maxsize
%     for yindex=1:size(pixelCandidates,2)-window_maxsize
%         if pixelCandidates(xindex, yindex)==1
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
% xmin, xmax
% ymin, ymax
% for winx=window_maxsize:-3:window_minsize
%     tic
%     winy=winx-8;
%     for i=xmin:1:xmax-winx
%         for j=ymin:1:ymax-winy
%             bbox=[i, j, i+winx, j+winy];
%             fr=filling_ratio(bbox, pixelCandidates);
%             if ((fr>0.47 && fr<0.53) || (fr>0.77 && fr<0.83) || (fr>0.97 && fr<1.05))
%                 windowCandidates=[windowCandidates; bbox];
%             end
%         end
%     end
%     toc
% end
for id=1:4
    tic
    if sum(sum(sub_pixelCandidates(:,:,id)))>50
        for winx=window_maxsize:-3:window_minsize
            winy=winx+4;
            for i=1:4:size(sub_pixelCandidates(:,:,id),1)-winx
                for j=1:4:size(sub_pixelCandidates(:,:,id),2)-winy
                    bbox=[i, j, i+winx, j+winy];
                    %%img_win=sub_pixelCandidates(bbox(1):bbox(3),bbox(2):bbox(4))>1;
                    %%if (filling_ratio(bbox, img_win)>0.49 && filling_ratio(bbox, img_win)<0.51) ||(filling_ratio(bbox, img_win)>0.79 && filling_ratio(bbox, img_win)<0.81) || (filling_ratio(bbox, img_win)>0.98 && filling_ratio(bbox, img_win)<1.05)
                    fr=filling_ratio(bbox, sub_pixelCandidates(:,:,id));
                    %%if ((filling_ratio(bbox, sub_pixelCandidates(:,:,id))>0.49 && filling_ratio(bbox, sub_pixelCandidates(:,:,id))<0.51) ||(filling_ratio(bbox, sub_pixelCandidates(:,:,id))>0.79 && filling_ratio(bbox, sub_pixelCandidates(:,:,id))<0.81) || (filling_ratio(bbox, sub_pixelCandidates(:,:,id))>0.98 && filling_ratio(bbox, sub_pixelCandidates(:,:,id))<1.05))&&(calculate==1)
                    if ((fr>0.47 && fr<0.53) || (fr>0.77 && fr<0.83) || (fr>0.97 && fr<1.05))
                        windowCandidates=[windowCandidates; bbox];
                        
                    end

                end
            end
        end
    end
    toc
end

end

