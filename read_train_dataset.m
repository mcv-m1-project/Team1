function [ train_dataset_struct ] = read_train_dataset( dataset_path, filter_elements )
%READTRAINDATASET Reads the train dataset into a structured list

% List all the images in the path
list_images = dir(dataset_path);
num_images = size(list_images);

struct_counter = 1;
for ind=1:num_images
   if ~list_images(ind).isdir && ( strcmp(list_images(ind).name(end-2:end),'ppm')==1 || strcmp(list_images(ind).name(end-2:end),'jpg')==1 || strcmp(list_images(ind).name(end-2:end),'png') )
       % Name 
       name = strrep(list_images(ind).name, '.jpg', '');
       % Image
       image = fullfile(list_images(ind).folder, list_images(ind).name);
       % Annotations
       annotations_file = sprintf('%s.%s.txt', 'gt', name);
       annotations = fullfile(list_images(ind).folder, 'gt', annotations_file);
       % Mask
       mask_file = sprintf('%s.%s.png', 'mask', name);
       mask = fullfile(list_images(ind).folder, 'mask', mask_file);
       % Assign to structure
       train_dataset_struct(struct_counter).name = name;
       train_dataset_struct(struct_counter).image = image;
       train_dataset_struct(struct_counter).annotations = annotations;
       train_dataset_struct(struct_counter).mask = mask;
       
       struct_counter = struct_counter + 1;
   end
end

% Filter elements
if nargin > 1
    train_dataset_struct = train_dataset_struct(filter_elements);
end

end

