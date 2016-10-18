function img=my_imerode(img, se)

padx=ceil(size(se,1)/2);
pady=ceil(size(se,2)/2);
img=padarray(img,[padx pady], 'replicate');
for x=1+padx:size(img,1)-padx
    for y=1+pady:size(img,2)-pady
        min_se=255;
        for a=1:size(se,1)
            i=a-padx;
            for b=1:size(se,2)
                j=b-pady;
                if(se(a,b)==1)&&(img(x+i,y+j)<min_se)
                    min_se=img(x+i,y+j);
                end
            end
        end
        if img(x,y)>=min_se
            img(x,y)=min_se;
        end
    end
end
img=img(1+padx:size(img,1)-padx, 1+pady:size(img,2)-pady);
            
end