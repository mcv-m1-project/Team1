function img_dil=my_imdilate(img, se)

padx=ceil(size(se,1)/2);
pady=ceil(size(se,2)/2);
img=padarray(img,[padx pady]);
img_dil=img;
for x=1+padx:size(img,1)-padx
    for y=1+pady:size(img,2)-pady
        max_se=0;
        for a=1:size(se,1)
            i=padx-a;
            for b=1:size(se,2)
                j=pady-b;
<<<<<<< HEAD
                if(se(a,b)>0)&&(img(x+i,y+j)>max_se)
=======
               if(se(a,b)==1)&&(img(x+i,y+j)>max_se)
>>>>>>> origin/week2
                    max_se=img(x+i,y+j);
                end
            end
        end
        if img(x,y)<max_se
            img_dil(x,y)=max_se;

        end
    end
end
img_dil=img_dil(1+padx:size(img_dil,1)-padx, 1+pady:size(img_dil,2)-pady);
            
end