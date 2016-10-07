%% CONSTANTS
TRAIN_DATASET_PATH = './DataSetDelivered/train';
do_readDataset=1;
do_maxmin=1;
do_formfactor=1;
do_fillingratio=0;
do_freqappearance=0;
do_signalgrouping=0;
%% READ DATASET
if do_readDataset
    train_dataset = read_train_dataset(TRAIN_DATASET_PATH);
    clear TRAIN_DATASET_PATH;
end
%% MAXIMUM AND MINIMUM SIZE
if do_maxmin
    disp('Computing maximum and minimum size...');
    [max_size, min_size, ...
    max_A, max_B, max_C, max_D, max_E, max_F, ...
    min_A, min_B, min_C, min_D, min_E, min_F] = max_min_size(train_dataset);
end
%% FORM FACTOR
if do_formfactor
    disp('Computing form factor...');
    [form_factor_list, ...
    form_factor_A, form_factor_B, form_factor_C, ...
    form_factor_D, form_factor_E, form_factor_F] = form_factor(train_dataset);
end
%% FILLING RATIO
if do_fillingratio
    disp('Computing filling ratio...');
    fill_rat = filling_ratio(train_dataset);
end
%% FREQUENCY OF APPEARANCE
if do_freqappearance
    disp('Computing frequency of appearance...');
    freq_app = frequency_appearance(train_dataset);
end
%% SIGNALS GROUPING BY SHAPE AND COLOR
if do_signalgrouping
    disp('Grouping the signals by shape and color...');
    group_sign = signal_grouping(train_dataset);
end

disp('Analysis of training dataset finished.');
