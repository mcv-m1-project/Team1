function [ form_factor_value ] = form_factor( bound_box )
%Compute the FORM FACTOR (width / height) of the given bounding box

%Compute the height, width (and area) of the given bounding box
[~, height, width] = bbParam(bound_box);
%Compute the form factor
form_factor_value = width / height;
       
end

