function [ A,B,C,D,E,F ] = signal_grouping( train_dataset )
%SIGNAL_GROUPING grouping signals into each type
%   Detailed explanation goes here

A=[];
B=[];
C=[];
D=[];
E=[];
F=[];
for i=1:length(train_dataset)
    [bound_box, type, num_elems] = parse_annotations(train_dataset(i).annotations);
    for ind=1:num_elems
        if type(num_elems)==1
            A=strvcat(A, train_dataset(i).name);
        elseif type(num_elems)==2
            B=strvcat(B, train_dataset(i).name);
        elseif type(num_elems)==3
            C=strvcat(C, train_dataset(i).name);   
        elseif type(num_elems)==4
            D=strvcat(D,train_dataset(i).name);
        elseif type(num_elems)==5
            E=strvcat(E ,train_dataset(i).name);
        elseif type(num_elems)==6
            F=strvcat(F, train_dataset(i).name);
        end
    end
end            
end


