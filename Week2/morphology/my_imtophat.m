function img_th=my_imtophat(img, se)

img_th=abs(img-my_imopen(img,se));
size(img)
size(my_imopen(img,se))

end

