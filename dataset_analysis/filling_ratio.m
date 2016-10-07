function [ output_args ] = filling_ratio( train_dataset )
%FILLING_RATIO computes the ratio between the pixels that belong to a
%signal and the total pixels in its bounding box


%Initialization of variables
frA=0;frB=0;frC=0;frD=0;frE=0;frF=0;
A=0;B=0;C=0;D=0;E=0;F=0;

% Iterate over all the dataset
for i=1:length(train_dataset)
    [bound_box, type, num_elems] = parse_annotations(train_dataset(i).annotations);
    mask = imread(train_dataset(i).mask);
    for m=1:num_elems
        %The numbers on the ground truth represent the coordinates of the
        %upper left corner and lower right corner of the bounding box.
        %Compute the height, weight and area of the bounding box:
        height = bound_box(m,3) - bound_box(m,1);
        width = bound_box(m,4) - bound_box(m,2);
        bbArea = double(width)*double(height);

        %Take the pixels of the mask that are inside the bounding box
        %and count the ones that are not zero in that area, which
        %correspond to the pixels of the signal.
        bbPixels = mask(bound_box(m,1):bound_box(m,1)+height, bound_box(m,2):bound_box(m,2)+width);
        signalPixels = nnz(bbPixels);

        %The filling ratio of a signal will be the number of pixels with
        %value 1 in the mask divided by the area of the bounding box.
        fillingR = signalPixels/bbArea;

        if type{m} == 'A'
            frA = frA + fillingR;
            A=A+1;
        elseif type{m} == 'B'
            frB = frB + fillingR;
            B=B+1;
        elseif type{m} == 'C'
            frC = frC + fillingR;
            C=C+1;
        elseif type{m} == 'D'
            frD = frD + fillingR;
            D=D+1;
        elseif type{m} == 'E'
            frE = frE + fillingR;
            E=E+1;
        elseif type{m} == 'F'
            frF = frF + fillingR;
            F=F+1;
        end

    end
end

%mean of the filling ratios + study of the values for each type - in
%progress
double(frA)/double(A)
double(frB)/double(B)
double(frC)/double(C)
double(frD)/double(D)
double(frE)/double(E)
double(frF)/double(F)

output_args = 'TO BE IMPLEMENTED';

%clear variables

end
