function [ bounding_boxes, types, num_elems ] = parse_annotations( annotations_file )
%PARSEANNOTATIONS Parses the content of the annotations file

% Open the annotations file and scan it
f_id = fopen(annotations_file);
text = textscan(f_id, '%f %f %f %f %s');

x1 = text{1};
y1 = text{2};
x2 = text{3};
y2 = text{4};
types = text{5};

% Preallocate bounding box
num_elems = length(x1);
bounding_boxes = zeros(num_elems, 4);

for ind=1:num_elems
   bounding_boxes(ind, :) = [x1(ind) y1(ind) x2(ind) y2(ind)]; 
end

fclose(f_id);

end

