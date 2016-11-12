set = 'train';
[train_split, val_split] = read_train_val_split('DataSetDelivered');
if strcmp(set, 'train')
    set_split = train_split;
    clear val_split;
elseif strcmp(set, 'val')
    set_split = val_split;
    clear train_split
else
    clear train_split val_split
    error('The set type indicated in the input parameters is not valid');
end

dataset_split = read_train_dataset('DataSetDelivered/train/', set_split);

for i=1:size(dataset_split,2)
    % Read image
    im = imread(dataset_split(i).image);
    
    eg = segment_ucm(im, 0.2);
    
    imwrite(uint8(eg), strcat('ucmSeg/seg',dataset_split(i).name,'.png'));
    
    fprintf('Image %s of %s - %s.png\r', int2str(i), int2str(size(dataset_split,2)),dataset_split(i).name);
    
    
end