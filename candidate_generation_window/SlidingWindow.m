function [ windowCandidates ] = SlidingWindow( im, pixelCandidates, window_method )
%SLIDINGWINDOW Summary of this function goes here
%   Detailed explanation goes here

window_maxsize = 230;
window_minsize = 30;
windowCandidates = [];
xmin = 16000;
ymin = 16000;
xmax = 0;
ymax = 0;
[y,x]=size(pixelCandidates);
pix_step=10;
win_step=-10;

int_im=[];
if strcmp(window_method,'integral_window') % store integral image
    int_im=cumsum(cumsum(double(pixelCandidates),2));	
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
                if pixelCandidates(b,a)==1
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

         for winx=window_maxsize:win_step:window_minsize
            winy=winx-8;
            window_area=winx*winy;
            ymaxx=ymax;
            xmaxx=xmax;
            if xmax>size(pixelCandidates,2)-winx
                xmaxx=size(pixelCandidates,2)-winx;
            end
            if ymax>size(pixelCandidates,1)-winy
                ymaxx=size(pixelCandidates,1)-winy;
            end
            for i=xmin:pix_step:xmaxx
                for j=ymin:pix_step:ymaxx
                    row_up=pixelCandidates(j,i:i+winx);
                    col_left=pixelCandidates(j:j+winy,i);
                    row_down=pixelCandidates(j+winy, i:i+winy);
                    if nnz(row_up) && nnz(col_left) && nnz(row_down) % if we have white pixels in 3 of 4 sides of the BBox, do further calculations. Otherwise, don't.
                    
                        bbox=[j, i, j+winy, i+winx];
                    if strcmp(window_method,'naive_window')
                    fr=filling_ratio(bbox, pixelCandidates);
                    elseif strcmp(window_method,'integral_window')
                        A=int_im(j+winy,i+winx);
                        if i-1<1
                            B=0;
                        else
                        B= int_im (j+winy, i-1);
                        end
                        if j-1<1
                            C=0;
                        else
                            C=int_im(j-1,i+winx);
                        end
                        if j-1>0 && i-1>0 
                          D=int_im (j-1,i-1);
                        else
                           D=0;
                        end
                    fr=(A -B - C + D)/window_area;
                    end
                    %if nnz(col_left) && nnz(row_down)
                        if ((fr>0.47 && fr<0.53) || (fr>0.77 && fr<0.83) || (fr>0.97 && fr<1.05))
                            %box_struct = struct('x', i, 'y', j, 'w', winx, 'h', winy);
                            %windowCandidates=[windowCandidates; box_struct];
                            windowCandidates=[windowCandidates; [i,j,winx, winy]];
                            % FIXME: Debug only0
                            % imshow(pixelCandidates);
                            % hold on;
                            % rectangle('Position', [i, j, winx, winy], 'EdgeColor', 'r');
                        end
                    end
                    
                end
            end
        end
    end
end

end
