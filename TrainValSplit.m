%% OPTIONS
TRAIN_PERCENTAGE = 70;
DATASET_PATH = 'DataSetDelivered';
PLOT_CLUSTERS = 0;

%% READ DATASET
TRAIN_DATASET_PATH = fullfile(DATASET_PATH, 'train');
full_dataset = read_train_dataset(TRAIN_DATASET_PATH);

%% COMPUTE TRAIN-VAL SPLIT
disp('Splitting the dataset in train and validation sets...');
[train_split, val_split] = compute_train_val_split(full_dataset, TRAIN_PERCENTAGE, PLOT_CLUSTERS);

%% ASSERT THE PERCENTAGE OF ELEMENTS IN EACH SPLIT
l_train = length(train_split);
l_val = length(val_split);
l_total = l_train + l_val;
assert(l_total == length(full_dataset));
p_train = (l_train / l_total);
p_val = (l_val / l_total);
fprintf('\nSPLIT SUMMARY\n');
fprintf('COMPUTED --> \t TRAIN: %f \t VALIDATION: %f \n', p_train, p_val);
fprintf('EXPECTED --> \t TRAIN: %f \t VALIDATION: %f \n', ...
    TRAIN_PERCENTAGE / 100, 1 - TRAIN_PERCENTAGE / 100);

%% STORE THE SPLIT IN TXT FILES
fprintf('\nSaving train and validation splits in txt files...\n');
[train_txt, val_txt] = store_train_val_split(DATASET_PATH, train_split, val_split);
fprintf('TRAIN FILE: %s\n', train_txt);
fprintf('VALIDATION FILE: %s\n', val_txt);

clear TRAIN_PERCENTAGE DATASET_PATH TRAIN_DATASET_PATH full_dataset ...
      train_split val_split l_train l_val l_total p_train p_val ...
      train_txt val_txt;

disp('Done.');

