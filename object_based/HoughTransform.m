function [ windowCandidates ] = HoughTransform(im, pixelCandidates,f)
%HOUGHTRANSFORM Summary of this function goes here
%   Detailed explanation goes here
figure(f);
tic
%extract contours
pc_edges =  bwperim(pixelCandidates,8);
%dilate contour
se=strel('disk',3);
pc_edges=imdilate(pc_edges,se);
%thin contour
pc_edges=bwmorph(pc_edges,'thin');

subplot(2,3,1)
imshow(pixelCandidates)
subplot(2,3,2)
imshow(pc_edges)
%hough transform
[H, theta,rho]=hough(pc_edges);
subplot(2,3,3)
%show hough transform
imshow(H,[],'XData',theta,'YData',rho,...
            'InitialMagnification','fit');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
%calculate peaks in HT
P  = houghpeaks(H,10,'threshold',ceil(0.3*max(H(:))));
%plot peaks in HT
x = theta(P(:,2)); y = rho(P(:,1));
plot(x,y,'s','color','white');
hold off;
%exract lines from HT and its peaks
 lines = houghlines(H,theta,rho,P,'FillGap',5,'MinLength',2);
%show lines in contour image
subplot(2,3,4) 
 imshow(pc_edges), hold on
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2]
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
end
hold off
drawnow
toc
windowCandidates=[];
end

