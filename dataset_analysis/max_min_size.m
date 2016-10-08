function [max_global_size, min_global_size]=max_min_size(train_dataset)
%MAX_MIN_SIZE Computes the maximum and minimum size of all signals
% max_global_size (and min_global_size) is a 6x3 matrix: each row
% represents tha maximmum (and minimmum) values of each type of signal. 
% Each column represents area, width and height.

% MAX AND MIN ABSOLUTE ON THE TRAIN DB
max_size=[0, 0, 0];         %%max_size= area, width and height
min_size=[1000, 0, 0];      %%min_size= area, width and height

max_area=[0,0,0,0,0,0];
min_area=[10000,10000,10000,10000,10000,10000];
max_width=[0,0,0,0,0,0];
min_width=[10000,10000,10000,10000,10000,10000];
max_height=[0,0,0,0,0,0];
min_height=[10000,10000,10000,10000,10000,10000];

% Iterate over all the dataset
for i=1:length(train_dataset)
    [bound_box, type, num_elems] = parse_annotations(train_dataset(i).annotations);
    for m=1:num_elems
        c1=bound_box(m, 1);
        c2=bound_box(m, 2);
        c3=bound_box(m, 3);
        c4=bound_box(m, 4);
        area=(c3-c1)*(c4-c2);
        if(max_size(1)<area)        %%if the area of max_size is smaller than the actual area
            max_size=[area, (c4-c2), (c3-c1)];
           
        elseif(min_size(1)>area)
            min_size=[area, (c4-c2), (c3-c1)];
        end
            if( max_area(type{m})<area)        %%if the area of max_size is smaller than the actual area
                %max_A=[area, (c4-c2), (c3-c1)];
                max_area(type{m})=area;
                max_width(type{m})=c4-c2;
                max_height(type{m})=c3-c1;
            elseif( min_area(type{m})>area)
               % min_A=[area, (c4-c2), (c3-c1)];
                min_area(type{m})=area;
                min_width(type{m})=c4-c2;
                min_height(type{m})=c3-c1;
            end
        
    end    
end

max_global_size=[max_area' max_width' max_height'];
min_global_size=[min_area' min_width' min_height'];
end