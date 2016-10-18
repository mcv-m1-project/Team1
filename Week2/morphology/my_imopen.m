function img_op=my_imopen(img, se)

img_op=my_imdilate(my_imerode(img,se),se);


end

