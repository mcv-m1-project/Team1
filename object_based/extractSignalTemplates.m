function templates = extractSignalTemplates(mode)
%extract gray level templates using test images and averaging the gray
%level inside the ground truth masks
DATASET_PATH = 'DataSetDelivered';
TRAIN_DATASET_PATH = fullfile(DATASET_PATH, 'train');
[train_split, dummy] = read_train_val_split(DATASET_PATH);
train_dataset = read_train_dataset(TRAIN_DATASET_PATH, train_split);

a_signal=zeros(250, 250, 3);
a_signal_count=0;
b_signal=zeros(250, 250, 3);
b_signal_count=0;
c_signal=zeros(250, 250, 3);
c_signal_count=0;
d_signal=zeros(250, 250, 3);
d_signal_count=0;
e_signal=zeros(250, 250, 3);
e_signal_count=0;
f_sq_signal=zeros(250, 250, 3);
f_sq_signal_count=0;
f_rec_signal=zeros(250, 200, 3);
f_rec_signal_count=0;

for i=1:length(train_dataset) %iterate over train DB split
    [bound_box, type, num_elems] = parse_annotations(train_dataset(i).annotations);
    % Read image
    image = double(imread(train_dataset(i).image));
        
    %Read mask
    mask = imread(train_dataset(i).mask);

    for j=1:length(num_elems)
        
        % find grayscale values inside the mask for each signal
        bb_image=image(bound_box(j,1):bound_box(j,3),bound_box(j,2):bound_box(j,4), :);
        bb_mask=logical(mask(bound_box(j,1):bound_box(j,3),bound_box(j,2):bound_box(j,4)));
        bb_signal = bb_image .* bb_mask;
 
        if type{j}==1 %&& form_factor(bound_box(j,:))
            a_signal_count=a_signal_count+1;
            bb_signal_reshaped=imresize(bb_signal, [size(a_signal, 1), size(a_signal, 2)]);
            a_signal= a_signal + bb_signal_reshaped;
        elseif type{j}==2
            b_signal_count=b_signal_count+1;
            bb_signal_reshaped=imresize(bb_signal, [size(b_signal, 1), size(b_signal, 2)]);
            b_signal= b_signal + bb_signal_reshaped;
        elseif type{j}==3
            c_signal_count=c_signal_count+1;
            bb_signal_reshaped=imresize(bb_signal, [size(c_signal, 1), size(c_signal, 2)]);
            c_signal= c_signal + bb_signal_reshaped;
        elseif type{j}==4
            d_signal_count=d_signal_count+1;
            bb_signal_reshaped=imresize(bb_signal, [size(d_signal, 1), size(d_signal, 2)]);
            d_signal= d_signal + bb_signal_reshaped;
        elseif type{j}==5
            e_signal_count=e_signal_count+1;
            bb_signal_reshaped=imresize(bb_signal, [size(e_signal, 1), size(e_signal, 2)]);
            e_signal= e_signal + bb_signal_reshaped;
        elseif type{j}==6 && (0.9<=form_factor(bound_box)) && form_factor(bound_box)<1.2
        %ar_vec=[ar_vec form_factor(bound_box)];
            f_sq_signal_count=f_sq_signal_count+1;
            bb_signal_reshaped=imresize(bb_signal, [size(f_sq_signal, 1), size(f_sq_signal, 2)]);
            f_sq_signal= f_sq_signal + bb_signal_reshaped;
        elseif type{j}==6 && ((0.9>form_factor(bound_box)) || form_factor(bound_box)>1.2)
            %ar_vec=[ar_vec form_factor(bound_box)];
            f_rec_signal_count=f_rec_signal_count+1;
            bb_signal_reshaped=imresize(bb_signal, [size(f_rec_signal, 1), size(f_rec_signal, 2)]);
            f_rec_signal= f_rec_signal + bb_signal_reshaped;
        end
    end 
    fprintf('Image %s of %s\r', int2str(i), int2str(length(train_dataset)));  
end

% Average and transform to UINT8
a_signal=uint8(a_signal/a_signal_count);
b_signal=uint8(b_signal/b_signal_count);
c_signal=uint8(c_signal/c_signal_count);
d_signal=uint8(d_signal/d_signal_count);
e_signal=uint8(e_signal/e_signal_count);
f_sq_signal=uint8(f_sq_signal/f_sq_signal_count);
f_rec_signal=uint8(f_rec_signal/f_rec_signal_count);

switch(mode)
    case 'gray'
        a_signal = rgb2gray(a_signal);
        b_signal = rgb2gray(b_signal);
        c_signal = rgb2gray(c_signal);
        d_signal = rgb2gray(d_signal);
        e_signal = rgb2gray(e_signal);
        f_sq_signal = rgb2gray(f_sq_signal);
        f_rec_signal = rgb2gray(f_rec_signal);
    case 'hue'
        a_signal = rgb2hsv(a_signal);
        a_signal = a_signal(:, :, 1);
        b_signal = rgb2hsv(b_signal);
        b_signal = b_signal(:, :, 1);
        c_signal = rgb2hsv(c_signal);
        c_signal = c_signal(:, :, 1);
        d_signal = rgb2hsv(d_signal);
        d_signal = d_signal(:, :, 1);
        e_signal = rgb2hsv(e_signal);
        e_signal = e_signal(:, :, 1);
        f_sq_signal = rgb2hsv(f_sq_signal);
        f_sq_signal = f_sq_signal(:, :, 1);
        f_rec_signal = rgb2hsv(f_rec_signal);
        f_rec_signal = f_rec_signal(:, :, 1);
end

% Plot averages
figure;
subplot(3,3,1)
imshow(a_signal);
title('signal A');
subplot (3,3,2);
imshow(b_signal);
title('signal B');
subplot (3,3,3);
imshow(c_signal);
title('signal C');
subplot (3,3,4);
imshow(d_signal);
title('signal D');
subplot (3,3,5);
imshow(e_signal);
title('signal E');
subplot (3,3,6);
imshow(f_sq_signal);
title('signal F (squares)');
subplot (3,3,7);
imshow(f_rec_signal);
title('signal F (rectangles)');

% Assign templates to a cell array
templates={a_signal, b_signal, c_signal, d_signal, e_signal, f_sq_signal, f_rec_signal};

% save templates in mat file
switch(mode)
    case 'gray'
        filename = 'templates';
    case 'hue'
        filename = 'templates_hue';
end
save(fullfile('DataSetDelivered', filename), 'templates');
end

