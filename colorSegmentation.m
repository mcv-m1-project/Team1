function [ output_args ] = colorSegmentation( fullDataset )
%COLORSEGMENTATION Summary of this function goes here
%   Detailed explanation goes here

histograms=true;
%calculate a general histogram for all signal pixels
together=true;
%calculate a separate histogram for 6 different signal pixels
OneByOne=true;
%calculate masks for some images to see results
calculate_masks=true;
%colorspace to transform (hsv, lab...)
colorsp = 'hsv';

%do we have histograms saved?
saved=false;
colorspace = 'hsv';
%histAll = loadHistograms('joint', colorspace,'_mod');

hist_individual = loadHistograms('', colorspace,'_mod');
histoABC = hist_individual{1};
histoDF = hist_individual{2};
histoE = hist_individual{3};

    if calculate_masks
        roc = [];
        
        %Normalitzar el histograma (histo es l'histograma dels senyals de tipus A,
        %s'haura de fer per a cadascun en el lloc que toqui)
        histoABC=histoABC./max(max(histoABC));
        histoDF=histoDF/max(max(histoDF));
        histoE=histoE/max(max(histoE));
        

        TP=zeros(1,10);
        FP=zeros(1,10);
        FN=zeros(1,10);
        TN=zeros(1,10);
        %calculate mask for each image in the dataset
        for i=1:size(fullDataset,2)
            
            im=imread(fullDataset(i).image);
            [bound_box, type, num_elems] = parse_annotations(fullDataset(i).annotations);
            mask=imread(fullDataset(i).mask);
            
            for it=1:num_elems
                %show original image
                %figure;
                %imshow(im);
                
                %initialize mask with zeros
                created_mask=zeros(size(im,1),size(im,2));
                if colorsp == 'hsv'
                    im_cs=rgb2hsv(im);
                elseif colorsp == 'lab'
                    im_cs=colorspace('Lab-<',im);
                end
                
                %im_cs=im;
                a=im_cs(:,:,1);
                b=im_cs(:,:,2);
                
                for s1=1:size(im,1)
                    for s2=1:size(im,2)
                        %  round(a(s1,s2)*255)
                        %  round(255*b(s1,s2))
                        %if pixel value is
                        %if(pdf_normalize(round(a(s1,s2)*254)+1,round(254*b(s1,s2))+1)>0.5) %paint pixel=1 in created_mask if according to thresholds
                        
                        %Mirar el valor del histograma a la posicio
                        %(current_hue,current_saturation). Si es >0.5 (CANVIAR VALOR), es
                        %que el color pertany a un senyal
                        %Poso +1 perque a matlab la posicio 0 no existeix
                        %if pdf_normalize(round(a(s1,s2)*63)+1,round(b(s1,s2)*63)+1) > 0.2
                        
                        
                        if histoABC(round(a(s1,s2)*63)+1,round(b(s1,s2)*63)+1) > 0.01 || histoDF(round(a(s1,s2)*63)+1,round(b(s1,s2)*63)+1) > 0.01 || histoE(round(a(s1,s2)*63)+1,round(b(s1,s2)*63)+1) > 0.01
                            created_mask(s1,s2)= 1;
                        end
                        
                        sc1 = histoABC(round(a(s1,s2)*63)+1,round(b(s1,s2)*63)+1);
                        sc2 = histoDF(round(a(s1,s2)*63)+1,round(b(s1,s2)*63)+1);
                        sc3 = histoE(round(a(s1,s2)*63)+1,round(b(s1,s2)*63)+1);
                        
                        score = max(max(sc1,sc2),sc3);
                        
                        for t=0:0.1:1
                            if score > t    % scored positive
                                if mask(s1,s2)==1 % labeled positive
                                    TP(1,round(t*9)+1)=TP(1,round(t*9)+1)+1;
                                else            % labeled negative
                                    FP(1,round(t*9)+1)=FP(1,round(t*9)+1)+1;
                                end
                            else                % scored negative
                                if mask(s1,s2)==1 % labeled positive
                                    FN(1,round(t*9)+1) = FN(1,round(t*9)+1)+1;
                                else            % labeled negative
                                    TN(1,round(t*9)+1) = TN(1,round(t*9)+1)+1;
                                end
                            end
                            
                  
                        end
     
                        
                    end
                end
                
            end
            %figure;
            
            %show created mask
            %imshow(created_mask)
            
            %store created mask
            %imwrite(created_mask,[fullDataset(i).mask(1:end-4), '-created.png'])
            
        end
        roc = [];
        TP
        FP
        TN
        FN
        precision=zeros(1,10);
        accuracy=zeros(1,10);
        for k = 1:10
            precision(1,k) = TP(1,k) / (TP(1,k)+FP(1,k)+FN(1,k)+TN(1,k));
            accuracy(1,k) = TP(1,k) / (TP(1,k)+FN(1,k)+FP(1,k));
            
        end
        precision
        accuracy
      
        figure()
        plot(precision, accuracy);
        
    end
end