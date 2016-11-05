function [windowCandidates] = TemplateMatchingChamfer2(im,templates)
tic

%Options:
    %RGB -> blur image (gaussian filter) -> to gray -> compute contours 
    %Not tried -> RGB - blur - gray - contours -> filter by color. Find
    %minimum, if it doesn't have red (or blue) in the box, find next
    %minimum?)
    %RGB -> to hsv -> thresholds, compute mask (reds, TODO blues) -> %compute contours
  
    
%Template gives minima in places with a lot of contours, not
%necessarily with the desired shape... solution?
     
%RGB - blur - to gray - contours
% %Low pass filter 
% blur = imgaussfilt(im,3);
% %RGB to gray
% blurg = rgb2gray(blur);
% %Find contours
% cont = edge(blurg,'Roberts');
% %Dilate contours
% se = strel('disk',5);
% contd = imdilate(cont,se);
% %Thin contours to get only a 1 pixel line
% contd = bwmorph(contd,'thin',Inf);


%RGB to hsv + thresholds. Returns B&W mask (automatically created with a
%Matlab app)
BW = createMask(im);
%Contours on mask 
cont = edge(BW,'Roberts');
%Dilate contours
se = strel('disk',5);
contd = imdilate(cont,se);
%Thin contours to get only a 1 pixel line
contd = bwmorph(contd,'thin',Inf);


%Compute chamfer distance
dist = bwdist(contd);

windowCandidates=[];


%Show image, mask and contours
%  k= figure(2);
%  imshow(im)
%  h=figure(3);
%  imshow(BW)
%  f= figure(4);
%  imshow(contd)
%  uiwait(f)
%  close(h)
%  close(k)

%For every template...
for t =1:7
    
    %Change size (TODO: Change size range)
    for tempsize=60:10:120
        
        %Take the signal template
        sig = templates{t};
        %Resize it
        sig = imresize(sig,tempsize/250);
        %Add a black line in the bottom to get that contour
        sig(tempsize+1,:)=0;
        %Compute contours of signal template
        contA = edge(sigA,'Roberts');
        
        %Multiply "by hand"
        % cor = ones(size(gray))*1000000;
        %     for s = 1:1:(size(im,1)-size(sigA,1))
        %         for t = 1:1:(size(im,2)-size(sigA,2))
        %             cor(s,t)=sum(sum(dist(s:s+size(sigA,2)-1,t:t+size(sigA,1)-1).*contA));
        %         end
        %     end
       
        %Multiplly using a filter function (results are the same, but
        %faster)
        cor = imfilter(dist,double(contA),'same');
        %Compute padding offset (we want to save the corner, not the center
        %of the filter
        pad = round(size(sig,2)/2);
        
        %Find the indices of the minimum value 
        [ypeak,xpeak] = find(cor==min(min(cor)));
        
        m=min(min(cor))
        

        for n = 1:size(ypeak,1)
            %Get the corner of the bounding box, instead of the center
            yoffSet = ypeak(n) - pad;
            xoffSet = xpeak(n) - pad;
            
            %Limit the number of detections? How to chose them?
%             if n == 10
%                 disp('too many 0')
%                 break
%             end

            %Save the window candidate
            windowCandidates=[windowCandidates; [xoffSet+1,yoffSet+1,size(sigA,2), size(sigA,1)]];
        end
    end
end

toc
end