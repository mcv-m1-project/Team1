function [Ims] = MeanShiftSegmentation(Im, window_shape, bandwidth)
%function [Ims, Ims2, Ims3] = MeanShiftSegmentation(Im, window_shape, bandwidth)
tic
if nargin < 3
    bandwidth = 0.1;
end
if nargin < 2
    window_shape = 'flat';
end

% Transform images to grayscale and HSV and resize them (1/4)
Im = im2double(Im);
Im = rgb2hsv(Im);
sc=1/4;
I=imresize(Im, sc);
I1D=rgb2gray(I);
X = reshape(I,size(I,1)*size(I,2),3); 
X1 = reshape(I1D,size(I1D,1)*size(I1D,2),1); 
labeled_X = zeros(size(X1));

% Mean Shift Clustering
[clustCent,point2cluster,clustMembsCell] = MeanShiftCluster(X', bandwidth, window_shape);

% Centers must have maximum value = 1
[x,y]=find(clustCent(1:2,:)>=1);
for i=1:size(x)
    clustCent(x,y)=1;
end

for i = 1:length(clustMembsCell)   
    % Classify a whole region depending on the color of the center
    if (mean_shift_classification(clustCent(:, i), X(clustMembsCell{i}, :)))
        X1(clustMembsCell{i}) = 255;
    else
        X1(clustMembsCell{i}) = 0;
    end
    
    % Assign cluster center color to the whole region
    X(clustMembsCell{i},:) = repmat(clustCent(:,i)', size(clustMembsCell{i},2),1);  
    
    % Label each cluster
    labeled_X(clustMembsCell{i}) = i*255/length(clustMembsCell);
end

% Reshape images to original size and shape
Ims = reshape(X1(:), size(I,1), size(I,2));
%Ims2 = reshape(X(:,1:3), size(I,1), size(I,2), 3); 
%Ims3 = reshape(labeled_X(:), size(I,1), size(I,2));

% Segmented Image
%Ims2=hsv2rgb(Ims2);
Ims=imresize(Ims, 1/sc);
%Ims2=imresize(Ims2, 1/sc);
%Ims3=uint8(imresize(Ims3, 1/sc));
toc
end

function [is_sign] = mean_shift_classification(cluster_center, hsv_pixel_values)
    method = 2;
    
    switch(method)
        case 1
            % Simple approach: classify with hard thresholds the value of the
            % center pixel in the cluster
            is_sign = ((cluster_center(1)>= 0.9 || cluster_center(1)<= 0.1  || ...
                (cluster_center(1)>= 0.4 && cluster_center(1)<= 0.8)) && ...
                (cluster_center(2)>= 0.2 && cluster_center(3)>= 0.1));
        case 2
            % Only classify the region if at least some percentage of the
            % pixels pass the color thresholding step
            PROPORTION = 0.85;
            %color_filter = (...
            %    (...
            %        (hsv_pixel_values(:, 1) >= 0.9) + (hsv_pixel_values(:, 1) <= 0.1)  + ( (hsv_pixel_values(:, 1) >= 0.4) .* (hsv_pixel_values(:, 1) <= 0.8) ) ...
            %    ) .* ( (hsv_pixel_values(:, 2) >= 0.2) + (hsv_pixel_values(:, 3)>= 0.1) ) ...
            %);
            color_filter = (...
                (...
                    (hsv_pixel_values(:, 1) >= 0.925) + (hsv_pixel_values(:, 1) <= 0.1)  + ( (hsv_pixel_values(:, 1) >= 0.5) .* (hsv_pixel_values(:, 1) <= 0.78) ) ...
                ) .* ( (hsv_pixel_values(:, 2) >= 0.35) + (hsv_pixel_values(:, 3)>= 0.15) ) ...
            );
            proportion = sum(sum(logical(color_filter))) / numel(color_filter);
            is_sign = proportion >= PROPORTION;
    end

end