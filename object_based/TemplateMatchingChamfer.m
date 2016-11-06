function [windowCandidates] = TemplateMatchingChamfer(im, pixelCandidates, pixel_method, histogram)

distance_threshold=90000;
color_thresh=2000;
%gray=rgb2gray(im);
%TODO: Smoothing filter
gray=rgb2gray(im);
gray(~pixelCandidates)=0;
%edges=edge(gray, 'canny');
%edges2=imcontour(pixelCandidates,1);
edges2=edge(gray, 'Roberts');
D2=bwdist(edges2);
%D1=bwdist(edges);
box=[];
xmin = 16000;
ymin = 16000;
xmax = 0;
ymax = 0;
[y,x]=size(pixelCandidates);
%%Circle template for the minimum size
tempsize=60;
circ=ones(tempsize, round(tempsize*0.95));
nseg=1000;
a=round(tempsize/2)-1;
b=round(round(tempsize*0.95)/2)-1;
yc=b+1;
xc=a+1;
for theta = 0 : (2 * pi / nseg) : (2 * pi)
    pline_y = abs(b * sin(theta) + yc);
    pline_x = abs(a * cos(theta) + xc);
    circ(round(pline_x),round(pline_y))=0;
end
%%Rectangle template for the minimum size:
rect=ones(tempsize, round(tempsize*0.83));
rect(1:2,:)=0;
rect(tempsize-1:tempsize,:)=0;
rect(:,1:2)=0;

%%triangle template for the minimum size:

h1=tempsize;
h2=round(tempsize*1.01);
triangle=ones(h1, h2);
for i = 1:h1
    for j = 1:h2
        if (j <= h2/2 && (i/2+j==h2/2-1)) || (j > h2/2 && (-i/2+j==h2/2-1)) || (i==h1-1)
            triangle(i,j)=0;
        end
    end
end

for id=1:4
    if id==1
        x_range=1:ceil(x/2);
        y_range=1:ceil(y/2);
    elseif id==2
        x_range=ceil(x/2)+1:x;
        y_range=1:ceil(y/2);
    elseif id==3
        x_range=1:ceil(x/2);
        y_range=ceil(y/2)+1:y;
    else
        x_range=ceil(x/2)+1:x;
        y_range=ceil(y/2)+1:y;
    end
    %total_operations = 0;
    
    %Discarting 'black-blocks' of the image 
    if nnz(pixelCandidates(y_range, x_range))
        %Finding the minimum and maximum position of "whites" in the image
        %to slide the window inside this part, instead of slide the window 
        %through the entire image.
        for a=x_range
            for b=y_range
                if gray(b,a)~=0
                    %num_pos_pixels = num_pos_pixels + 1;
                    if xmin>a
                        xmin=a;
                    elseif xmax<a
                        xmax=a;
                    end
                    if ymin>b
                        ymin=b;
                    elseif ymax<b
                        ymax=b;
                    end
                end
            end
        end
        for tempsize=40:10:240
            distance_thresh=distance_threshold*tempsize/240;
            %interpolate templates
            TC=imresize(circ,tempsize/60);
            TR=imresize(rect, tempsize/60);
            TT1=imresize(triangle, tempsize/60);
            TT2=ones(size(TT1));
            for i=1:size(TT1,1)
                TT2(i,:)=TT1(size(TT1,1)-i+1,:);
            end
            
            maxsize=max([size(TC,1), size(TT1,2), size(TT2,2), size(TR,1)]);
            ymaxx=ymax;
            xmaxx=xmax;
            if xmax>size(pixelCandidates,2)-maxsize
                xmaxx=size(pixelCandidates,2)-maxsize;
            end
            if ymax>size(pixelCandidates,1)-maxsize
                ymaxx=size(pixelCandidates,1)-maxsize;
            end
            for j=xmin:10:xmaxx
                for i=ymin:10:ymaxx
                    distanceC=sum(sum(D2(i:(i+size(TC,1)-1), j:(j+size(TC,2)-1)).*TC));
                    distanceT1=sum(sum(D2(i:(i+size(TT1,1)-1), j:(j+size(TT1,2)-1)).*TT1));
                    distanceT2=sum(sum(D2(i:(i+size(TT2,1)-1), j:(j+size(TT2,2)-1)).*TT2));
                    distanceR=sum(sum(D2(i:(i+size(TR,1)-1), j:(j+size(TR,2)-1)).*TR));
                    if min([distanceC, distanceT1, distanceR, distanceT2])<distance_thresh
                    
                        w=0;
                        h=0;
                        thresh=0;
                        if distanceC < distance_thresh*0.9
                            w=size(TC,2)-1;
                            h=size(TC,1)-1;
                            thresh=sum(sum(CandidateGenerationPixel(im(i:(i+size(TC,1)-1), j:(j+size(TC,2)-1),:), pixel_method, histogram)));
                        elseif distanceR < distance_thresh*0.8
                             w=size(TR,2)-1;
                             h=size(TR,1)-1;
                             thresh=sum(sum(CandidateGenerationPixel(im(i:(i+size(TR,1)-1), j:(j+size(TR,2)-1),:), pixel_method, histogram)));
                        elseif distanceT1 < distance_thresh 
                            w=size(TT1,2)-1;
                            h=size(TT1,1)-1;
                            thresh=sum(sum(CandidateGenerationPixel(im(i:(i+size(TT1,1)-1), j:(j+size(TT1,2)-1),:), pixel_method, histogram)));
                        elseif distanceT2 < distance_thresh
                            w=size(TT2,2)-1;
                            h=size(TT2,1)-1;
                            thresh=sum(sum(CandidateGenerationPixel(im(i:(i+size(TT2,1)-1), j:(j+size(TT2,2)-1),:), pixel_method, histogram)));
                        end
                        if thresh>color_thresh && w~=0 && h~=0
                        %if  w~=0 && h~=0
                            box=[box; [j, i, w, h]];
                        end
                    end
                end
           end    

        end
    end
end

windowCandidates=box;
end