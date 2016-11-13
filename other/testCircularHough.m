% Positive example
im_true = imread('DataSetDelivered/train/01.000936.jpg');
% Negative example
im_false = imread('DataSetDelivered/train/01.002315.jpg');

% Grayscale
im_true_g = rgb2gray(im_true);
im_false_g = rgb2gray(im_false);

%% POSITIVE EXAMPLE

% Hough transform from radius 15 to 120
disp('Positive example');
tic;
[circen_t_1, cirrad_t_1] = imfindcircles(im_true_g, [15, 40], 'Sensitivity', 0.8, 'EdgeThreshold', 0.25);
[circen_t_2, cirrad_t_2] = imfindcircles(im_true_g, [40, 120], 'Sensitivity', 0.8, 'EdgeThreshold', 0.25);
toc;

% Plot positive example
figure(1); 
imagesc(im_true_g); 
colormap('gray'); 
axis image;
hold on;
if numel(circen_t_1) > 0
    plot(circen_t_1(:,1), circen_t_1(:,2), 'b+');
end
if numel(circen_t_2) > 0
    plot(circen_t_2(:,1), circen_t_2(:,2), 'r+');
end

circ = viscircles(circen_t_1, cirrad_t_1, 'Color', 'b', 'LineWidth', 2, 'LineStyle', '-');
circ = viscircles(circen_t_2, cirrad_t_2, 'Color', 'r', 'LineWidth', 2, 'LineStyle', '-');
title(['Raw Image with Circles Detected ', ...
 '(center positions and radii marked) - Positive example']);

%% NEGATIVE EXAMPLE

% Hough transform from radius 15 to 120
disp('Negative example');
tic;
[circen_f_1, cirrad_f_1] = imfindcircles(im_false_g, [15, 40], 'Sensitivity', 0.9, 'EdgeThreshold', 0.25);
[circen_f_2, cirrad_f_2] = imfindcircles(im_false_g, [40, 120], 'Sensitivity', 0.9, 'EdgeThreshold', 0.25);
toc;

% Plot negative example
figure(2); 
imagesc(im_false_g); 
colormap('gray'); 
axis image;
hold on;
if numel(circen_f_1) > 0
    plot(circen_f_1(:,1), circen_f_1(:,2), 'b+');
end
if numel(circen_f_2) > 0
    plot(circen_f_2(:,1), circen_f_2(:,2), 'r+');
end

for k=1:size(circen_f_1, 1)
    circ = viscircles(circen_f_1, cirrad_f_1, 'Color', 'b', 'LineWidth', 2, 'LineStyle', '-');
end
for k=1:size(circen_f_1, 1)
    circ = viscircles(circen_f_2, cirrad_f_2, 'Color', 'r', 'LineWidth', 2, 'LineStyle', '-');
end
hold off;
title(['Raw Image with Circles Detected ', ...
 '(center positions and radii marked) - Negative example']);
