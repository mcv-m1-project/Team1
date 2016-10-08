function [ train_split, val_split ] = read_train_val_split( dataset_path )
%READ_TRAIN_VAL_SPLIT Reads train and validation splits from txt files

train_file = fullfile(dataset_path, 'train_split.txt');
val_file = fullfile(dataset_path, 'val_split.txt');
train_fid = fopen(train_file, 'r');
val_fid = fopen(val_file, 'r');
train_split = textscan(train_fid, '%d\n');
train_split = train_split{1};
val_split = textscan(val_fid, '%d\n');
val_split = val_split{1};
fclose(train_fid);
fclose(val_fid);

end

