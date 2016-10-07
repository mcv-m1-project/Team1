function [max_size, min_size, ...
          max_A, max_B, max_C, max_D, max_E, max_F, ...
          min_A, min_B, min_C, min_D, min_E, min_F] = max_min_size(train_dataset)
%MAXIMUM_MINIMUM_SIZE Computes the maximum and minimum size of all signals

% MAX AND MIN ABSOLUTE ON THE TRAIN DB
max_size=[0, 0, 0];         %%max_size= area, width and height
min_size=[1000, 0, 0];      %%min_size= area, width and height

% MAX AND MIN OF EACH TYPE OF SIGNALS
max_A= [0,0,0];             
max_B= [0,0,0];
max_C= [0,0,0];
max_D= [0,0,0];
max_E= [0,0,0];
max_F= [0,0,0];
min_A= [10000,0,0];
min_B= [10000,0,0];
min_C= [10000,0,0];
min_D= [10000,0,0];
min_E= [10000,0,0];
min_F= [10000,0,0];

% Iterate over all the dataset
for i=1:length(train_dataset)
    [bound_box, type, num_elems] = parse_annotations(train_dataset(i).annotations);
    for m=1:num_elems
        c1=bound_box(m, 1);
        c2=bound_box(m, 2);
        c3=bound_box(m, 3);
        c4=bound_box(m, 4);
        types=type{m};
        area=(c3-c1)*(c4-c2);
        if(max_size(1)<area)        %%if the area of max_size is smaller than the actual area
            max_size=[area, (c4-c2), (c3-c1)];
        elseif(min_size(1)>area)
            min_size=[area, (c4-c2), (c3-c1)];
        end
        if(types=='A')
            if(max_A(1)<area)        %%if the area of max_size is smaller than the actual area
                max_A=[area, (c4-c2), (c3-c1)];
            elseif(min_A(1)>area)
                min_A=[area, (c4-c2), (c3-c1)];
            end
        end
        if(types=='B')
            if(max_B(1)<area)        %%if the area of max_size is smaller than the actual area
                max_B=[area, (c4-c2), (c3-c1)];
            elseif(min_B(1)>area)
                min_B=[area, (c4-c2), (c3-c1)];
            end
        end
        if(types=='C')
            if(max_C(1)<area)        %%if the area of max_size is smaller than the actual area
                max_C=[area, (c4-c2), (c3-c1)];
            elseif(min_C(1)>area)
                min_C=[area, (c4-c2), (c3-c1)];
            end
        end
        if(types=='D')
            if(max_D(1)<area)        %%if the area of max_size is smaller than the actual area
                max_D=[area, (c4-c2), (c3-c1)];
            elseif(min_D(1)>area)
                min_D=[area, (c4-c2), (c3-c1)];
            end
        end
        if(types=='E')
            if(max_E(1)<area)        %%if the area of max_size is smaller than the actual area
                max_E=[area, (c4-c2), (c3-c1)];
            elseif(min_E(1)>area)
                min_E=[area, (c4-c2), (c3-c1)];
            end
        end
        if(types=='F')
            if(max_F(1)<area)        %%if the area of max_size is smaller than the actual area
                max_F=[area, (c4-c2), (c3-c1)];
            elseif(min_F(1)>area)
                min_F=[area, (c4-c2), (c3-c1)];
            end
        end  
    end    
end


end