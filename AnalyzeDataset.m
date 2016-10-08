%% OPTIONS
DATASET_PATH = 'DataSetDelivered';
TRAIN_DATASET_PATH = fullfile(DATASET_PATH, 'train');
if ~exist('FULL_TRAIN_VAL_OPTION', 'var')
    FULL_TRAIN_VAL_OPTION = 'train'; % Full (train + validation) dataset, train dataset or validation dataset
end
do_maxmin=1;
do_formfactor=1;
do_fillingratio=1;
do_freqappearance=1;
do_signalgrouping=0;

%% READ DATASET
disp('---------------------------');
if strcmp(FULL_TRAIN_VAL_OPTION, 'val')
    % Get the validation dataset
    [train_split, val_split] = read_train_val_split(DATASET_PATH);
    train_dataset = read_train_dataset(TRAIN_DATASET_PATH, val_split);
    % Display validation split
    disp('----- VALIDATION SPLIT ----');
elseif strcmp(FULL_TRAIN_VAL_OPTION, 'train')
    % Get the train dataset
    [train_split, val_split] = read_train_val_split(DATASET_PATH);
    train_dataset = read_train_dataset(TRAIN_DATASET_PATH, train_split);
    % Display train split
    disp('------- TRAIN SPLIT -------');
else
   % Get the whole dataset
   train_dataset = read_train_dataset(TRAIN_DATASET_PATH);
   disp('------ FULL DATASET -------');
end
disp('---------------------------');


clear DATASET_PATH TRAIN_DATASET_PATH;

%% VARIABLES INITIALIZATION
%Counters for the total number of signals in the database and the number of
%signals of each type
type_count=zeros(1,6);
signal_count=0;
%Initial maximum and minimum area, height and width
max_area=zeros(1,6);
max_width=zeros(1,6);
max_height=zeros(1,6);
min_area=ones(1,6)*1000;
min_width=ones(1,6)*1000;
min_height=ones(1,6)*1000;
%Vector that will contain the total filling ratio for each type of signal
fillratio_vec=zeros(1,6);
%Vector that will contain the total form factor for each type of signal
formFact_vec=zeros(1,6);

%% LOOP FOR EVERY ELEMENT IN THE DATASET
%Set the length of the dataset in a variable so it is saved in the
%workspace, it may be useful
disp('Processing the dataset...');
disp('');
dataset_length = length(train_dataset);
for i=1:dataset_length
    %Get the information from the ground truth
    [bound_box, type, num_elems] = parse_annotations(train_dataset(i).annotations);
    %For every signal in an image, compute the desired characteristics
    for m=1:num_elems
        %%Counters update
        signal_count=signal_count+1;
        type_count(type{m}) = type_count(type{m}) + 1;
        %% MAXIMUM AND MINIMUM SIZE
        if do_maxmin
            %Compute the area height and width of the bounding box
            [area, height, width] = bbParam(bound_box(m,:));
            %Update the max and min values if necessary
            if area > max_area(type{m})        
                max_area(type{m})=area;
            elseif area < min_area(type{m})
                min_area(type{m})=area;
            end
            if width > max_width(type{m})
                max_width(type{m})=width;
            elseif width < min_width(type{m})
                min_width(type{m})=width;
            end
            if height > max_height(type{m})
                max_height(type{m})=height;
            elseif height < min_height(type{m})
                min_height(type{m})=height;
            end
        end
        %% FORM FACTOR
        if do_formfactor
            %Compute the form factor of the signal and add it to the
            %total form factor of the corresponding type
            formFact_vec(type{m}) = formFact_vec(type{m}) +  form_factor(bound_box(m,:));
        end
        %% FILLING RATIO
        if do_fillingratio
            %Read mask
            mask = imread(train_dataset(i).mask);
            %Compute the filling ratio of the signal and add it to the
            %total filling ratio of the corresponding type
            fillratio_vec(type{m}) = fillratio_vec(type{m}) + filling_ratio(bound_box(m,:), mask);
        end

        %% SIGNALS GROUPING BY SHAPE AND COLOR
        if do_signalgrouping
            %TODO
            disp('Grouping the signals by shape and color...');
            group_sign = signal_grouping(train_dataset);
        end
    end
    
end


%% FREQUENCY OF APPEARANCE
if do_freqappearance
    %Divide the number of signals of a type by the total number of signals 
    %to obtain values between 0 and 1
    freqApp_v=type_count./signal_count;
    disp('The frequency of appearance of each type of signal is: ');
    disp(freqApp_v);
end

%% MAXIMUM AND MINIMUM SIZE
if do_maxmin
    disp('The maximum area for each type of signal is: ');
    disp(max_area);
    disp('The minimum area for each type of signal is: ');
    disp(min_area);
    disp('The maximum height for each type of signal is: ');
    disp(max_height);
    disp('The minimum height for each type of signal is: ');
    disp(min_height);
    disp('The maximum width for each type of signal is: ');
    disp(max_width);
    disp('The minimum width for each type of signal is: ');
    disp(min_width);
end

%% FORM FACTOR MEAN
if do_formfactor
    formFactor_means = double(formFact_vec)./double(type_count);
    disp('The mean form factor for each type of signal is: ');
    disp(formFactor_means);
end
        
%% FILLING RATIO MEAN
if do_fillingratio
    fillingRatio_means = double(fillratio_vec)./double(type_count);
    disp('The mean filling ratio for each type of signal is: '); 
    disp(fillingRatio_means);
end

%Clear useless variables:
clear area bound_box do_fillingratio do_formfactor do_freqappearance ...
    do_maxmin do_signalgrouping fillratio_vec formFact_vec height i m ...
    mask num_elems type width
    

disp('Analysis of training dataset finished.');
