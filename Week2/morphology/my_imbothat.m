function img_bh=my_imbothat(img, se)

img_bh=abs(my_imclose(img,se)-img);

size(img)
size(my_imclose(img,se))

end

