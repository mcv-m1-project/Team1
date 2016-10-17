function [ bounding_boxes, types_num, num_elems ] = parse_annotations( annotations_file )
%PARSEANNOTATIONS Parses the content of the annotations file

% Open the annotations file and scan it
f_id = fopen(annotations_file);
text = textscan(f_id, '%d %d %d %d %s');

x1 = text{1};
y1 = text{2};
x2 = text{3};
y2 = text{4};
types = text{5};

%number of signals in the image
num_elems = length(x1);

for i=1:num_elems
    if types{i}=='A'
    types_num{i} = 1;
    elseif types{i}=='B'
    types_num{i}= 2;
    elseif types{i}=='C'
    types_num{i} = 3;
    elseif types{i}=='D'
    types_num{i} = 4;
    elseif types{i}=='E'
    types_num{i} = 5;
    elseif types{i}=='F'
    types_num{i} = 6;
    end
end

% Preallocate bounding box
bounding_boxes = zeros(num_elems, 4);

for ind=1:num_elems
   bounding_boxes(ind, :) = [x1(ind) y1(ind) x2(ind) y2(ind)]; 
end

fclose(f_id);

end

