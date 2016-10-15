function [ output_args ] = colorSegmentation( fullDataset )
%COLORSEGMENTATION Summary of this function goes here
%   Detailed explanation goes here

histograms=true;
%calculate a general histogram for all signal pixels
together=true;
%calculate a separate histogram for 6 different signal pixels
OneByOne=true;
%calculate masks for some images to see results
calculate_masks=false;
%colorspace to transform (hsv, lab...)
colorsp = 'hsv';

%do we have histograms saved?
saved=false;

if histograms
    %create vectors where all pixels in the desired component (example: im(:,:,1), im(:,:,2) or  im(:,:,3)) marked by the masks will be stored
    masked_comp_A=[];
    masked_comp_D=[];
    masked_comp_E=[];
    masked_comp_total=[];
    masked_comp2_A=[];
    masked_comp2_D=[];
    masked_comp2_E=[];
    masked_comp2_total=[];
    
    if (saved)
        hists_comp=load(colorsp+'_comp1.mat');
        
        masked_comp_A=hists_comp.masked_comp_A;
        masked_comp_B=hists_comp.masked_comp_B;
        masked_comp_C=hists_comp.masked_comp_C;
        masked_comp_D=hists_comp.masked_comp_D;
        masked_comp_E=hists_comp.masked_comp_E;
        masked_comp_F=hists_comp.masked_comp_F;
        
        hists_comp=load(colorsp+'_comp2.mat')
        masked_comp2_A=hists_comp.masked_comp2_A;
        masked_comp2_B=hists_comp.masked_comp2_B;
        masked_comp2_C=hists_comp.masked_comp2_C;
        masked_comp2_D=hists_comp.masked_comp2_D;
        masked_comp2_E=hists_comp.masked_comp2_E;
        masked_comp2_F=hists_comp.masked_comp2_F;
    else
        for i=1: size(fullDataset,2)
            %i/size(fullDataset,2)*100
            %read image and mask
            im=imread(fullDataset(i).image);
            mask=imread(fullDataset(i).mask);
            
            %convert to desired color space
            if colorsp == 'hsv'
                im_cs=rgb2hsv(im);
                %hue for red is near 0 and near 1, as it is a circular
                %component
                min_redc1 = 1;
                max_redc1 = 0;
                min_bluec1 = 0;
                max_bluec1 = 1;
                min_c2 = 0;
                min_c3 = 0;
            elseif colorsp == 'lab'
                im_cs=colorspace('Lab-<',im);
                min_c2 = 0.1;
                min_c3 = 0.1;
            end
            %take a component of the image in the new color space
            comp=im_cs(:,:,1);
            comp2=im_cs(:,:,2);
            comp3=im_cs(:,:,3);
            %parse annotations to get signal type
            [bound_box, type, num_elems] = parse_annotations(fullDataset(i).annotations);
            
            if (OneByOne)
                for it=1:num_elems
                    
                    if type{it}==1 || type{it}==2 || type{it}==3
                        % .* ((comp>min_redc1) + (comp<max_redc1)) .* (comp3 > min_c3) .* (comp2>min_c2);
                        m = (mask==1);
                        if nnz(m) ~= 0
                            masked_comp_A=[masked_comp_A, comp(logical(m))'];
                            masked_comp2_A=[masked_comp2_A, comp2(logical(m))'];
                        end
                        
                    elseif  type{it}==4 || type{it}==6
                        %.* ((comp>min_bluec1) .* (comp<max_bluec1)) .* (comp3 > min_c3) .* (comp2>min_c2)
                        m = (mask==1) ;
                        if nnz(m) ~= 0
                            masked_comp_D=[masked_comp_D, comp(logical(m))'];
                            masked_comp2_D=[masked_comp2_D, comp2(logical(m))'];
                        end
                    elseif  type{it}==5
                        %.* (comp3 > min_c3) .* (comp2>min_c2) .* ( (comp>min_redc1) + (comp<max_redc1) + ((comp>min_bluec1) .* (comp<max_bluec1)) )
                        m = (mask==1) ;
                        if nnz(m) ~= 0
                            masked_comp_E=[masked_comp_E, comp(logical(m))'];
                            masked_comp2_E=[masked_comp2_E, comp2(logical(m))'];
                        end
                    end
                end
                
                if (together)
                    m = (mask==1) .* (comp3 > min_c3) .* (comp2>min_c2);
                    if nnz(m) ~= 0
                        masked_comp_total=[masked_comp_total, comp(logical(m))'];
                        masked_comp2_total=[masked_comp2_total, comp2(logical(m))'];
                    end
                end
            end
            %perform histograms and visualization
            %save (colorsp+'_comp1.mat','masked_comp_A','masked_comp_D','masked_comp_E')
            %save (colorsp+'_comp2.mat','masked_comp2_A','masked_comp2_D','masked_comp2_E')
            
        end
        
        if (OneByOne)
            figure('name', 'signal type A');
            %n representa els limits dels bins.
            %Aquest valor tambe es pot canviar (si es canvia, s'ha de canviar tambe el
            %round de quan es mira el valor de l'histograma per a imatges noves)
            if colorsp == 'hsv'
                %n for HSV
                n1=0:1/63:1;
                n2=0:1/63:1;
            elseif colorsp == 'lab'
                %n for LAB
                n1=-127:2:127;
                n2=-127:2:127;
            end
            
            
            edges = {n1; n2};
            %calcular histograma hue-saturation
            histoA= hist3([masked_comp_A',masked_comp2_A'],'Edges', edges);
            %torno a calcular l'histograma per a que es mostri el grafic pero es
            %totalment innecesari XD
            hist3([masked_comp_A',masked_comp2_A'],'Edges', edges)
            xlabel('1st comp'); ylabel('2nd comp');
            set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
            
            figure('name', 'signal type D');
            histoD= hist3([masked_comp_D',masked_comp2_D'],'Edges', edges);
            hist3([masked_comp_D',masked_comp2_D'],'Edges',edges)
            xlabel('1st comp'); ylabel('2nd comp');
            set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
            
            figure('name', 'signal type E');
            histoE= hist3([masked_comp_E',masked_comp2_E'],'Edges', edges);
            hist3([masked_comp_E',masked_comp2_E'],'Edges',edges)
            xlabel('1st comp'); ylabel('2nd comp');
            set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
            
            %masked_comp_total=[masked_comp_A,masked_comp_B,masked_comp_C,masked_comp_D,masked_comp_E,masked_comp_F];
            %masked_comp2_total=[masked_comp2_A,masked_comp2_B,masked_comp2_C,masked_comp2_D,masked_comp2_E,masked_comp2_F];
        end
        
        if (together)
            if colorsp == 'hsv'
                %n for HSV
                n1=0:1/63:1;
                n2=0:1/63:1;
            elseif colorsp == 'lab'
                %n for LAB
                n1=-127:2:127;
                n2=-127:2:127;
            end
            edges = {n1; n2};
            figure('name', 'All signs histogram');
            hist3([masked_comp_total' , masked_comp2_total'],'Edges',edges);
            pdf=hist3([masked_comp_total' , masked_comp2_total'],'Edges',edges);
            xlabel('1st comp'); ylabel('2nd comp');
            set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
            
            figure('name', 'All signs histogram normalized');
            pdf_normalize = (pdf./ max(max(pdf)));% pdf normalization
            stem3(pdf_normalize);
            %store normalized histogram (pdf) for all signals
            save('DataSetDelivered/pdf_hsv.mat','pdf_normalize');
        end
        
    end
    
    if calculate_masks
        roc = [];
        
        %Normalitzar el histograma (histo es l'histograma dels senyals de tipus A,
        %s'haura de fer per a cadascun en el lloc que toqui)
        histoA=histoA/max(max(histoA));
        histoD=histoD/max(max(histoD));
        histoE=histoE/max(max(histoE));
        

        TP=zeros(1,10);
        FP=zeros(1,10);
        FN=zeros(1,10);
        TN=zeros(1,10);
        %calculate mask for each image in the dataset
        for i=1:10 %size(fullDataset,2)
            
            im=imread(fullDataset(i).image);
            [bound_box, type, num_elems] = parse_annotations(fullDataset(i).annotations);
            mask=imread(fullDataset(i).mask);
            
            for it=1:num_elems
                %show original image
                figure;
                imshow(im);
                
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
                        
                        
                        if histoA(round(a(s1,s2)*63)+1,round(b(s1,s2)*63)+1) > 0.5 || histoD(round(a(s1,s2)*63)+1,round(b(s1,s2)*63)+1) > 0.5 || histoE(round(a(s1,s2)*63)+1,round(b(s1,s2)*63)+1) > 0.5
                            created_mask(s1,s2)= 1;
                        end
                        
                        
                        for t=0:0.1:1
                            
                            sc1 = histoA(round(a(s1,s2)*63)+1,round(b(s1,s2)*63)+1);
                            sc2 = histoD(round(a(s1,s2)*63)+1,round(b(s1,s2)*63)+1);
                            s3 = histoE(round(a(s1,s2)*63)+1,round(b(s1,s2)*63)+1);
                            score = max(max(s1,s2),s3);
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
            figure;
            
            %show created mask
            imshow(created_mask, [0,1])
            
            %store created mask
            %imwrite(created_mask,[fullDataset(i).mask(1:end-4), '-created.png'])
            
        end
        roc = [];
        
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