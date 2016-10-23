function img_th=my_imtophat(img, se)

img_th=abs(img-my_imopen(img,se));
end

