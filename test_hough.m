close all
%Get the selected dataset split
directory='DataSetDelivered/';
%    dataset_split = read_train_dataset([directory '/train/'], set_split);

    [train_split, val_split] = read_train_val_split(directory);
    dataset_split = read_train_dataset([directory '/train/'], train_split);
    for i=4:size(dataset_split,2)
      %     for i=6:6
  
        % Read image
        im = imread(dataset_split(i).image);
        
       mask=imread(strcat('provaMS/m',dataset_split(i).name,'.png'));
       HoughTransform(im, mask);
        
    end
        
    