function [train_txt_path, val_txt_path] = store_train_val_split( dataset_path, train_split, val_split )
%STORE_TRAIN_VAL_SPLIT Stores the splits in a txt file

train_txt_path = fullfile(dataset_path, 'train_split.txt');
val_txt_path = fullfile(dataset_path, 'val_split.txt');
train_fid = fopen(train_txt_path, 'w');
val_fid = fopen(val_txt_path, 'w');
fprintf(train_fid, '%d\n', train_split);
fprintf(val_fid, '%d\n', val_split);
fclose(train_fid);
fclose(val_fid);

end

