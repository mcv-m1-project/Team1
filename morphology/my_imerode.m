function img_er=my_imerode(img, se)

padx=ceil(size(se,1)/2);
pady=ceil(size(se,2)/2);
img=padarray(img,[padx pady],'symmetric');
img_er=img;
sel=strel(se);
seq=getsequence(sel);
seqsize=size(seq,1);
if seqsize>1
    for sz=1:seqsize
        se=seq(sz,1).Neighborhood;
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
                if img(x,y)>min_se
                    img_er(x,y)=min_se;

                end
            end
        end
        
        
    end
else
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
            if img(x,y)>min_se
                img_er(x,y)=min_se;

            end
        end
    end
end
img_er=img_er(1+padx:size(img_er,1)-padx, 1+pady:size(img_er,2)-pady);
            
end