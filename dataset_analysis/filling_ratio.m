function [ fillingR ] = filling_ratio( bound_box , mask )
%Compute the FILLING_RATIO (ratio between pixels that belong to a
%signal and the total pixels in its bounding box)

%Compute the height, width and area of the given bounding box
[area, height, width] = bbParam(bound_box);

%Take the pixels of the mask that are inside the bounding box
%and count the ones that are not zero in that area, which
%correspond to the pixels of the signal.
bbPixels = mask(bound_box(1):bound_box(1)+height, bound_box(2):bound_box(2)+width);
signalPixels = nnz(bbPixels);

%The filling ratio of a signal will be the number of pixels with
%value 1 in the mask divided by the area of the bounding box.
fillingR = signalPixels/area;

end
