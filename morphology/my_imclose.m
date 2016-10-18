function img_cl=my_imopen(img, se)

img_cl=my_imerode(my_imdilate(img,se),se);


end

