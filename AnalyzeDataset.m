%% CONSTANTS 
TRAIN_DATASET_PATH = './DataSetDelivered/train';

%% READ DATASET
train_dataset = read_train_dataset(TRAIN_DATASET_PATH);
clear TRAIN_DATASET_PATH;

%% MAXIMUM AND MINIMUM SIZE
disp('Computing maximum and minimum size...');
[max_size, min_size, ...
max_A, max_B, max_C, max_D, max_E, max_F, ...
min_A, min_B, min_C, min_D, min_E, min_F] = max_min_size(train_dataset);

%% FORM FACTOR
disp('Computing form factor...');
form_fac = form_factor(train_dataset);

%% FILLING RATIO
disp('Computing filling ratio...');
fill_rat = filling_ratio(train_dataset);

%% FREQUENCY OF APPEARANCE
disp('Computing frequency of appearance...');
freq_app = frequency_appearance(train_dataset);

%% SIGNALS GROUPING BY SHAPE AND COLOR
disp('Grouping the signals by shape and color...');
group_sign = signal_grouping(train_dataset);

disp('Analysis of training dataset finished.');