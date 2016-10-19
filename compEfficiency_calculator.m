
close all;
im=imread('cameraman.jpg');

%define SE
se=strel('disk',10,4);

%% DILATION
disp ('Calculating performance test on dilation...')
tic;
for i=1:1000
%our method
my_im_dil=my_imdilate(im(:,:,1),se.Neighborhood);
end
my_et_dilation=toc;
tic;
%matlab method
for i=1:1000
im_dil=imdilate(im(:,:,1),se);
end
et_dilation=toc;

disp (['Elapsed time for dilation using our method: ',my_et_dilation])
disp (['Elapsed time for dilation using MATLAB method: ',et_dilation])
%% EROSION
disp ('Calculating performance test on erosion...')
tic;
for i=1:1000
%our method
my_im_dil=my_imerode(im(:,:,1),se.Neighborhood);
end
my_et_erosion=toc;
tic;
%matlab method
for i=1:1000
im_dil=imerode(im(:,:,1),se);
end
et_erosion=toc;

disp (['Elapsed time for erosion using our method: ',my_et_erosion])
disp (['Elapsed time for erosion using MATLAB method:  ',et_erosion])
%%  CLOSING 
disp ('Calculating performance test on closing...')
tic;
for i=1:1000
%our method
my_im_dil=my_imclose(im(:,:,1),se.Neighborhood);
end
my_et_closing=toc;
tic;
%matlab method
for i=1:1000
im_dil=imclose(im(:,:,1),se);
end
et_closing=toc;

disp (['Elapsed time for closing using our method: ',my_et_closing])
disp (['Elapsed time for closing using MATLAB method:',et_closing])
%% OPENING 
disp ('Calculating performance test on opening...')
tic;
for i=1:1000
%our method
my_im_dil=my_imopen(im(:,:,1),se.Neighborhood);
end
my_et_opening=toc;
tic;
%matlab method
for i=1:1000
im_dil=imopen(im(:,:,1),se);
end
et_opening=toc;

disp (['Elapsed time for opening  using our method:',my_et_opening])
disp (['Elapsed time for opening using MATLAB method: ',et_opening])
%% TOP-HAT
disp ('Calculating performance test on top-hat...')
tic;
for i=1:1000
%our method
my_im_dil=my_imtophat(im(:,:,1),se.Neighborhood);
end
my_et_tophat=toc;
tic;
%matlab method
for i=1:1000
im_dil=imtophat(im(:,:,1),se);
end
et_tophat=toc;

disp (['Elapsed time for top-hat using our method: ',my_et_tophat])
disp (['Elapsed time for top-hat using MATLAB method: ',et_tophat])
%% BOTTOM-HAT
  disp ('Calculating performance test on bot-hat...')
  tic;
for i=1:1000
%our method
my_im_dil=my_imbothat(im(:,:,1),se.Neighborhood);
end
my_et_bothat=toc;
tic;
%matlab method
for i=1:1000
im_dil=imbothat(im(:,:,1),se);
end
et_bothat=toc;

disp (['Elapsed time for bot-hat using our method:',my_et_bothat])
disp (['Elapsed time for bot-hat using MATLAB method: ',et_bothat])
%%

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
sum(sum(imabsdiff(my_im_dil-im_dil)))

