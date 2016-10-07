function [area, height, width] = bbParam(bound_box)
%Compute the height, width and area of the given bounding box
height = bound_box(3) - bound_box(1);
width = bound_box(4) - bound_box(2);
area = double(width)*double(height);

end