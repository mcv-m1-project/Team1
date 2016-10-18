
close all;
im=imread('DataSetDelivered/train/00.001461.jpg');

%define SE
se=strel('disk',10,4);
tic;
%our method
my_im_dil=my_imbothat(im(:,:,1),se.Neighborhood);
toc;
tic;
%matlab method
im_dil=imbothat(im(:,:,1),se);
toc;

figure;
imshow(im(:,:,1));
figure;
imshow(my_im_dil);
figure;
imshow(im_dil)
figure;
imshow (imabsdiff(my_im_dil,im_dil));

%display difference 
%sum(sum(imabsdiff(my_im_dil,im_dil)))
sum(sum(abs(my_im_dil-im_dil)))

