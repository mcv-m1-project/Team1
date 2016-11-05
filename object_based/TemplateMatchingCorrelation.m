function [windowCandidates] = TemplateMatchingCorrelation(im,pixelCandidates, templates)
%TemplateMatchingCorrelation( im, templates)
%TEMPLATECORRELATION Summary of this function goes here
%   Detailed explanation goes here

 %f=figure;
 %g=figure;
 tic
 debug=0;
xmin = 16000;
ymin = 16000;
xmax = 0;
ymax = 0;
[y,x]=size(pixelCandidates);
windowCandidates = [];
 %image = imread(train_dataset(i).image);
 im=rgb2gray(im);
%figure;
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
c_im=im(ymin:ymax,xmin:xmax);
 for temp=1:length(templates)
 for j=30:10:250
    re_template=imresize(templates{temp},j/250);
%    figure(g)
%     imshow(re_template);
%     pause(2)
if (size(re_template)<size(c_im))
  C = normxcorr2( re_template,c_im);
  [ind_i,ind_j]=find(C==max(max(C))>0.6);
     
  if debug==1
  subplot(1,4,1)
  imshow(im)
  title('original image')
  subplot(1,4,2);
  imshow(c_im)
  title('partition we take to compute matching')
  end
  %surf(C)
  %imshow(C)
  %pause(2);
  %max(max(C))
 % C(pixelCandidates)=0;
               
  marked_C=C;
          if max(max(C)) > 0.5
            [~, peaks] = FastPeakFind(C);
            [ypeak,xpeak] = find(peaks);
            
            for n = 1:size(ypeak,1)
                if C(ypeak(n),xpeak(n))>0.6
                    yoffSet = ypeak(n)-size( re_template,1);
                    xoffSet = xpeak(n)-size( re_template,2);
                    if yoffSet < 0 || xoffSet < 0
                        break
                    end
                    windowCandidates=[windowCandidates; [xoffSet+1,yoffSet+1,size(re_template,2), size(re_template,1)]];
                    marked_C=insertMarker(C,[yoffSet+1+size(re_template,1)/2,xoffSet+1+size(re_template,2)/2]);
                end
            end
            
          else

          end

          
  if debug==1
  subplot(1,4,3)
  imshow(marked_C)
  title('correlation with marker on the peaks >0.6')
  subplot(1,4,4)
  imshow(re_template)
  title('template')
  pause(0.5);
  end
end % end - if size template < size im
 %figure(f)
  % imshow (C);
  % pause(2);
 end % end - resizing of templates
 end %end - list of templates
    end % end - partition not 0 
end % end - image partitions
plot_results=0;
   if plot_results
       windowCandidatesFinal=[];
N = size(windowCandidates, 1);
for i=1:N
    box_struct = struct('x', windowCandidates(i,1), 'y', windowCandidates(i,2), 'w', windowCandidates(i,3), 'h', windowCandidates(i,4));
    windowCandidatesFinal=[windowCandidatesFinal; box_struct];
   
end
 windowCandidates=windowCandidatesFinal;
        hAx  = axes;
        imshow(im,'Parent', hAx);
        for zz = 1:size(windowCandidates,1)
            r=imrect(hAx, [windowCandidates(zz,1).x, windowCandidates(zz,1).y, windowCandidates(zz,1).w, windowCandidates(zz,1).h]);
            setColor(r,'r');
        end
        pause(2)
        % out_file = strcat(output_dir,'/m',files(i).name,'.png');
        % print(out_file,'-dpng')
   end
toc
end

