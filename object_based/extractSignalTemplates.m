function templates = extractSignalTemplates()
%extract gray level templates using test images and averaging the gray
%level inside the ground truth masks
DATASET_PATH = 'DataSetDelivered';
TRAIN_DATASET_PATH = fullfile(DATASET_PATH, 'train');
[train_split, val_split] = read_train_val_split(DATASET_PATH);
train_dataset = read_train_dataset(TRAIN_DATASET_PATH, train_split);

 image = imread(train_dataset(1).image);
a_signal=zeros(250,250);
a_signal_count=0;
b_signal=zeros(250,250);
b_signal_count=0;
c_signal=zeros(250,250);
c_signal_count=0;
d_signal=zeros(250,250);
d_signal_count=0;
e_signal=zeros(250,250);
e_signal_count=0;
f_sq_signal=zeros(250,250);
f_sq_signal_count=0;
f_rec_signal=zeros(250,200);
f_rec_signal_count=0;

for i=1:length(train_dataset) %iterate over train DB split
    
 [bound_box, type, num_elems] = parse_annotations(train_dataset(i).annotations);
  %Read image
    image_ = imread(train_dataset(i).image);
    image=rgb2gray(image_);
  %  image_=rgb2hsv(image_);
  %   image=image_(:,:,1);
 %Read mask
    mask = imread(train_dataset(i).mask);

    for j=1:length(num_elems)
   % find grayscale values inside the mask for each signal
   bb_image=image(bound_box(j,1):bound_box(j,3),bound_box(j,2):bound_box(j,4));
   bb_mask=mask(bound_box(j,1):bound_box(j,3),bound_box(j,2):bound_box(j,4));
   bb_signal=bb_image.*bb_mask;
 
   if type{j}==1 %&& form_factor(bound_box(j,:))
      a_signal_count=a_signal_count+1;
   bb_signal_reshaped=imresize(bb_signal,size(a_signal));
     a_signal= a_signal + im2double(bb_signal_reshaped);
   elseif type{j}==2
    b_signal_count=b_signal_count+1;
   bb_signal_reshaped=imresize(bb_signal,size(b_signal));
     b_signal= b_signal + im2double(bb_signal_reshaped);
 elseif type{j}==3
   c_signal_count=c_signal_count+1;
   bb_signal_reshaped=imresize(bb_signal,size(c_signal));
     c_signal= c_signal + im2double(bb_signal_reshaped);
 elseif type{j}==4
   d_signal_count=d_signal_count+1;
   bb_signal_reshaped=imresize(bb_signal,size(d_signal));
     d_signal= d_signal + im2double(bb_signal_reshaped);
 elseif type{j}==5
   e_signal_count=e_signal_count+1;
   bb_signal_reshaped=imresize(bb_signal,size(e_signal));
     e_signal= e_signal + im2double(bb_signal_reshaped);
 elseif type{j}==6 && (0.9<=form_factor(bound_box)) && form_factor(bound_box)<1.2
%ar_vec=[ar_vec form_factor(bound_box)];
   f_sq_signal_count=f_sq_signal_count+1;
   bb_signal_reshaped=imresize(bb_signal,size(f_sq_signal));
     f_sq_signal= f_sq_signal + im2double(bb_signal_reshaped);
elseif type{j}==6 && ((0.9>form_factor(bound_box)) || form_factor(bound_box)>1.2)
%ar_vec=[ar_vec form_factor(bound_box)];
   f_rec_signal_count=f_rec_signal_count+1;
   bb_signal_reshaped=imresize(bb_signal,size(f_rec_signal));
     f_rec_signal= f_rec_signal + im2double(bb_signal_reshaped);

    
    
    end
 end
 
        fprintf('Image %s of %s\r', int2str(i), int2str(length(train_dataset)));  
end
a_signal=a_signal/a_signal_count;
b_signal=b_signal/b_signal_count;
c_signal=c_signal/c_signal_count;
d_signal=d_signal/d_signal_count;
e_signal=e_signal/e_signal_count;
f_sq_signal=f_sq_signal/f_sq_signal_count;
f_rec_signal=f_rec_signal/f_rec_signal_count;
figure;
subplot(3,3,1)
imshow(a_signal)
title('signal A')
subplot (3,3,2)
imshow(b_signal)
title('signal B')
subplot (3,3,3)
imshow(c_signal)
title('signal C')
subplot (3,3,4)
imshow(d_signal)
title('signal D')
subplot (3,3,5)
imshow(e_signal)
title('signal E')
subplot (3,3,6)
imshow(f_sq_signal)
title('signal F (squares)')
subplot (3,3,7)
imshow(f_rec_signal)
title('signal F(rectangles)')
%title ('signal templates (gray level mean)')
templates={a_signal, b_signal, c_signal, d_signal, e_signal, f_sq_signal, f_rec_signal};
end

