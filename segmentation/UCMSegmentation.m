function [output] = UCMSegmentation(im)

PROPORTION = 0.65;

%Segment image with UCM, threshold 0.4
eg = segment_ucm(im, 0.4);


output = zeros(size(mask));

hsv = rgb2hsv(im);
h = hsv(:,:,1);
s = hsv(:,:,2);
v = hsv(:,:,3);

%Take the labels of the segmentation
labels = unique(eg);

for j=1:size(labels,1)
    
    region = eg == labels(j);
    
    %discard too small or too big regions
    if nnz(region) < 100 || nnz(region) > 30000
        continue
    end
    
    %a region has to fulfill some hsv conditions
    color_filter = ( ( (h(region) >= 0.9) | (h(region) <= 0.1) ...
        | ( (h(region) >= 0.45) & (h(region) <= 0.7) ) ) ...
        & ( (s(region) >= 0.4) & (v(region) >= 0.2) ) );
    proportion = nnz(color_filter) / numel(color_filter);
    
    %if a % of the pixels fulfill the condition, the region is kept
    if proportion >= PROPORTION
        output(region) = 1;
    end
    
end

%Fill the holes in the image (morphology)

output=imfill(output,'holes');

%
%     subplot(1,2,1)
%     imshow(255*mask)
%     subplot(1,2,2)
%     imshow(255*output)
%     drawnow()
%

end