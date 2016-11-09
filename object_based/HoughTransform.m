function [ windowCandidates ] = HoughTransform(im, pixelCandidates)
%HOUGHTRANSFORM Summary of this function goes here
%   Detailed explanation goes here
close all
tic
pc_edges =  bwperim(pixelCandidates,8);
%subplot(1,3,1)
%imshow(pixelCandidates)
%subplot(1,3,2)
imshow(pc_edges)
[H, theta,rho]=hough(pc_edges);
pause(5)

% peaks=houghpeaks(H,100);
% lines = houghlines(H,theta,rho,peaks,'FillGap',5,'MinLength',7);
% %figure,
% subplot(1,3,1)
% imshow(pixelCandidates)
% subplot(1,3,2)
% imshow(pc_edges)
% max_len = 0;
% subplot(1,3,3) 
% imshow(pc_edges), hold on
% for k = 1:length(lines)
%    xy = [lines(k).point1; lines(k).point2];
%    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
% 
%    % Plot beginnings and ends of lines
%    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
% 
%    % Determine the endpoints of the longest line segment
%    len = norm(lines(k).point1 - lines(k).point2);
%    if ( len > max_len)
%       max_len = len;
%       xy_long = xy;
%    end
% end
% hold off
drawnow
toc
windowCandidates=[];
end

