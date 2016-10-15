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

%do we have histograms saved?
saved=false;

if histograms
    %create vectors where all pixels in the desired component (example: im(:,:,1), im(:,:,2) or  im(:,:,3)) marked by the masks will be stored
masked_comp_A=[];
masked_comp_B=[];
masked_comp_C=[];
masked_comp_D=[];
masked_comp_E=[];
masked_comp_F=[];
masked_comp_total=[];
masked_comp2_A=[];
masked_comp2_B=[];
masked_comp2_C=[];
masked_comp2_D=[];
masked_comp2_E=[];
masked_comp2_F=[];
masked_comp2_total=[];

if (saved)
    hists_comp=load('LAB_comp1.mat')
    masked_comp_A=hists_comp.masked_comp_A;
    masked_comp_B=hists_comp.masked_comp_B;
    masked_comp_C=hists_comp.masked_comp_C;
    masked_comp_D=hists_comp.masked_comp_D;
    masked_comp_E=hists_comp.masked_comp_E;
    masked_comp_F=hists_comp.masked_comp_F;
    
    hists_comp=load('LAB_comp2.mat')
    masked_comp2_A=hists_comp.masked_comp2_A;
    masked_comp2_B=hists_comp.masked_comp2_B;
    masked_comp2_C=hists_comp.masked_comp2_C;
    masked_comp2_D=hists_comp.masked_comp2_D;
    masked_comp2_E=hists_comp.masked_comp2_E;
    masked_comp2_F=hists_comp.masked_comp2_F;
else

for i=1: size(fullDataset,2)
i/size(fullDataset,2)*100
%read image and mask
im=imread(fullDataset(i).image);
mask=imread(fullDataset(i).mask);
%convert to desired color space
%im_cs=rgb2hsv(im);
%im_cs=im;
im_cs=colorspace('Lab-<',im);
%take a component of the image in the new color space
comp=im_cs(:,:,1);
comp2=im_cs(:,:,2);
comp3=im_cs(:,:,3);
%parse annotations to get signal type
 [bound_box, type, num_elems] = parse_annotations(fullDataset(i).annotations);
 
 if (OneByOne)
 
 for it=1:num_elems
     
     if type{it}==1
for v=1:size(mask,1)
    for h=1:size(mask,2)
        %per a que un pixel es tingui en compte al calcular l'histograma,
        %ha de tenir mascara 1, Value entre 0.2 i 0.6 (traiem negres i
        %blancs), Saturation > 0.3 (traiem grisos) i Hue < 0.3 (en el cas
        %dels tipus A, per a trobar els vermells)
        %threshold for HSV
       % if(mask(v,h)==1 && (0.2>comp3(v,h)<0.6 && comp2(v,h)>0.3) )%&& comp(v,h)<0.3) %if pixel is marked by the mask, store it in the vector with the rest of signal pixels
        %threshold for LAB
        if(mask(v,h)==1 && 10>comp(v,h)<90 && (comp2(v,h)>10 || comp2(v,h)<-10) && (comp3(v,h)>10 || comp3(v,h)<-10))
            masked_comp_A=[masked_comp_A, comp(v,h)];   
            masked_comp2_A=[masked_comp2_A, comp2(v,h)];   
        end
    end
end
break;
     elseif  type{it}==2
for v=1:size(mask,1)
    for h=1:size(mask,2)
        %threshold for HSV
       % if(mask(v,h)==1 && (0.2>comp3(v,h)<0.6 && comp2(v,h)>0.3) )%&& comp(v,h)<0.3) %if pixel is marked by the mask, store it in the vector with the rest of signal pixels
        %threshold for LAB
        if(mask(v,h)==1 && 10>comp(v,h)<90 && (comp2(v,h)>10 || comp2(v,h)<-10) && (comp3(v,h)>10 || comp3(v,h)<-10))
        masked_comp_B=[masked_comp_B, comp(v,h)];   
        masked_comp2_B=[masked_comp2_B, comp2(v,h)];   
        end
    end
end
break;
         elseif  type{it}==3
for v=1:size(mask,1)
    for h=1:size(mask,2)
        %threshold for HSV
       % if(mask(v,h)==1 && (0.2>comp3(v,h)<0.6 && comp2(v,h)>0.3) )%&& comp(v,h)<0.3) %if pixel is marked by the mask, store it in the vector with the rest of signal pixels
        %threshold for LAB
        if(mask(v,h)==1 && 10>comp(v,h)<90 && (comp2(v,h)>10 || comp2(v,h)<-10) && (comp3(v,h)>10 || comp3(v,h)<-10))
        masked_comp_C=[masked_comp_C, comp(v,h)];   
        masked_comp2_C=[masked_comp2_C, comp2(v,h)];   
        end
    end
end
break;
    elseif  type{it}==4
for v=1:size(mask,1)
    for h=1:size(mask,2)
        %threshold for HSV
       % if(mask(v,h)==1 && (0.2>comp3(v,h)<0.6 && comp2(v,h)>0.3) )%&& comp(v,h)<0.3) %if pixel is marked by the mask, store it in the vector with the rest of signal pixels
        %threshold for LAB
        if(mask(v,h)==1 && 10>comp(v,h)<90 && (comp2(v,h)>10 || comp2(v,h)<-10) && (comp3(v,h)>10 || comp3(v,h)<-10))
        masked_comp_D=[masked_comp_D, comp(v,h)];
        masked_comp2_D=[masked_comp2_D, comp2(v,h)];
        end
    end
end
break;
    elseif  type{it}==5
for v=1:size(mask,1)
    for h=1:size(mask,2)
        %threshold for HSV
       % if(mask(v,h)==1 && (0.2>comp3(v,h)<0.6 && comp2(v,h)>0.3) )%&& comp(v,h)<0.3) %if pixel is marked by the mask, store it in the vector with the rest of signal pixels
        %threshold for LAB
        if(mask(v,h)==1 && 10>comp(v,h)<90 && (comp2(v,h)>10 || comp2(v,h)<-10) && (comp3(v,h)>10 || comp3(v,h)<-10))
        masked_comp_E=[masked_comp_E, comp(v,h)];   
        masked_comp2_E=[masked_comp2_E, comp2(v,h)];   
        end
    end
end
break;
    elseif  type{it}==6
for v=1:size(mask,1)
    for h=1:size(mask,2)
        %threshold for HSV
       % if(mask(v,h)==1 && (0.2>comp3(v,h)<0.6 && comp2(v,h)>0.3) )%&& comp(v,h)<0.3) %if pixel is marked by the mask, store it in the vector with the rest of signal pixels
        %threshold for LAB
        if(mask(v,h)==1 && 10>comp(v,h)<90 && (comp2(v,h)>10 || comp2(v,h)<-10) && (comp3(v,h)>10 || comp3(v,h)<-10))
        masked_comp_F=[masked_comp_F, comp(v,h)];  
        masked_comp2_F=[masked_comp2_F, comp2(v,h)];  
        end
    end
end
break;
    end

 end
 end
 
 if (together)
     for v=1:size(mask,1)
    for h=1:size(mask,2)
       %threshold for HSV
       % if(mask(v,h)==1 && (0.2>comp3(v,h)<0.6 && comp2(v,h)>0.3) )%&& comp(v,h)<0.3) %if pixel is marked by the mask, store it in the vector with the rest of signal pixels
        %threshold for LAB
        if(mask(v,h)==1 && 10>comp(v,h)<90 && (comp2(v,h)>10 || comp2(v,h)<-10) && (comp3(v,h)>10 || comp3(v,h)<-10))
         masked_comp_total=[masked_comp_total, comp(v,h)];  
        masked_comp2_total=[masked_comp2_total, comp2(v,h)];  
          end
        end
    end
 end
end
%perform histograms and visualization

save ('LAB_comp1.mat','masked_comp_A','masked_comp_B','masked_comp_C','masked_comp_D','masked_comp_E','masked_comp_F')
save ('LAB_comp2.mat','masked_comp2_A','masked_comp2_B','masked_comp2_C','masked_comp2_D','masked_comp2_E','masked_comp2_F')

end
if (OneByOne)
figure('name', 'signal type A');
%n representa els limits dels bins.
%Aquest valor tambe es pot canviar (si es canvia, s'ha de canviar tambe el
%round de quan es mira el valor de l'histograma per a imatges noves)
% n for HSV
%n=0:1/63:1;
%n for LAB
n1=-127:2:127;
n2=-127:2:127;
edges = {n1; n2};
%calcular histograma hue-saturation
histoA= hist3([masked_comp_A',masked_comp2_A'],'Edges', edges);
%torno a calcular l'histograma per a que es mostri el grafic pero es
%totalment innecesari XD
hist3([masked_comp_A',masked_comp2_A'],'Edges', edges)
xlabel('1st comp'); ylabel('2nd comp');
set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');

figure('name', 'signal type B');
histoB= hist3([masked_comp_B',masked_comp2_B'],'Edges', edges);
hist3([masked_comp_B',masked_comp2_B'],'Edges',edges)
xlabel('1st comp'); ylabel('2nd comp');
set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    
figure('name', 'signal type C');
histoC= hist3([masked_comp_C',masked_comp2_C'],'Edges', edges);
hist3([masked_comp_C',masked_comp2_C'],'Edges',edges)
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

figure('name', 'signal type F');
histoF= hist3([masked_comp_F',masked_comp2_F'],'Edges', edges);
hist3([masked_comp_F',masked_comp2_F'],'Edges',edges)
xlabel('1st comp'); ylabel('2nd comp');
set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');

%masked_comp_total=[masked_comp_A,masked_comp_B,masked_comp_C,masked_comp_D,masked_comp_E,masked_comp_F];
%masked_comp2_total=[masked_comp2_A,masked_comp2_B,masked_comp2_C,masked_comp2_D,masked_comp2_E,masked_comp2_F];
end
if (together)
% n for HSV
%n=0:1/63:1;
%n for LAB
n1=-127:2:127;
n2=-127:2:127;
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
%calculate mask for each image in the dataset
for i=1: 10%size(fullDataset,2)
    
im=imread(fullDataset(i).image);
[bound_box, type, num_elems] = parse_annotations(fullDataset(i).annotations);

for it=1:num_elems
 %show original image
figure;
imshow(im);

%initialize mask with zeros
created_mask=zeros(size(im,1),size(im,2));
%im_cs=colorspace('Lab-<',im);
im_cs=rgb2hsv(im);
%im_cs=im;
a=im_cs(:,:,1);
b=im_cs(:,:,2);


%Normalitzar el histograma (histo es l'histograma dels senyals de tipus A,
%s'haura de fer per a cadascun en el lloc que toqui)
   
% histoA=histoA/max(max(histoA));
% histoB=histoB/max(max(histoB));
% histoC=histoC/max(max(histoC));
% histoD=histoD/max(max(histoD));
% histoE=histoE/max(max(histoE));
% histoF=histoF/max(max(histoF));

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
            if pdf_normalize(round(a(s1,s2)*63)+1,round(b(s1,s2)*63)+1) > 0.2
            % if(pdf_normalize(a(s1,s2),b(s1,s2))>0.05)
                created_mask(s1,s2)= 1;
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
end
end