function [windowCandidates] = TemplateMatchingCorrelation(im,pixelCandidates, templates)
%TemplateMatchingCorrelation( im, templates)
%TEMPLATECORRELATION Summary of this function goes here
%   Detailed explanation goes here

 %f=figure;
 %g=figure;
 tic

windowCandidates = [];
 %image = imread(train_dataset(i).image);
 im=rgb2gray(im);
  %  image_=rgb2hsv(im);
  %   im=image_(:,:,1);
 for temp=1:length(templates)
 for j=30:10:250
    re_template=imresize(templates{temp},j/250);
%    figure(g)
%     imshow(re_template);
%     pause(2)
  C = normxcorr2( re_template,im);
  %surf(C)
  %imshow(C)
  %pause(2);
  %max(max(C))
 % C(pixelCandidates)=0;
          if max(max(C)) > 0.5
            [~, peaks] = FastPeakFind(C);
            [ypeak,xpeak] = find(peaks);
            
            for n = 1:size(ypeak,1)
                if C(ypeak(n),xpeak(n))>0.7
                    yoffSet = ypeak(n)-size( re_template,1);
                    xoffSet = xpeak(n)-size( re_template,2);
                    if yoffSet < 0 || xoffSet < 0
                        break
                    end
                    windowCandidates=[windowCandidates; [xoffSet+1,yoffSet+1,size(re_template,2), size(re_template,1)]];
                end
            end
          end

 %figure(f)
  % imshow (C);
  % pause(2);
 end
 end
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

