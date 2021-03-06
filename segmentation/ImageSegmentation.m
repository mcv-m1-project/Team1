function [ segm_im ] = ImageSegmentation( im, segmentation_method )
%IMAGESEGMENTATION Segmentation of the image

if strcmp(segmentation_method, 'mean_shift')
    segm_mask = MeanShiftSegmentation(im);
    %segm_im = uint8(segm_mask > 0) .* im;
    segm_im = segm_mask;
elseif strcmp(segmentation_method, 'ucm')
    segm_im = UCMSegmentation(im);
else
    error('This segmentation method is not supported. Use "mean_shift" instead');
end


end

