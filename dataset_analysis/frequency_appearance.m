function [ freqApp_v ] = frequency_appearance( train_dataset )
%FREQUENCY_APPEARANCE Calculates the frequency of appearance (0 to 1) of
%all 6 types of signal

freqApp_A=0;
freqApp_B=0;
freqApp_C=0;
freqApp_D=0;
freqApp_E=0;
freqApp_F=0;
freqApp_v=[0,0,0,0,0,0];
total_signals=0;

for i=1:length(train_dataset)
    [bound_box, type, num_elems] = parse_annotations(train_dataset(i).annotations);

    %store appearances to each signal index
    for i=1:num_elems
        freqApp_v(type{i})=  freqApp_v(type{i})+1;
     
    end   
%count total signals
total_signals=total_signals+num_elems;

end
%divide by total_signals to obtain values between 0 and 1
freqApp_v=freqApp_v/total_signals;
end
