function [output_args] = loadHistograms(type, colorspace, modified)
%Returns one or 3 histograms (joint histogram or one histogram for red
%signals, one for blue signals and one for red&blue signals)
%Type: joint or anything else ('' for example)
%colorspace: 'hsv', 'lab'...
%modified: 'mod' for modified version, '' for original version

if strcmp(type,'joint')
    name = strcat('DataSetDelivered/HistALL_',colorspace,modified,'.mat');
    var=load(name);
    output_args=var.pdf;
else
    name = strcat('DataSetDelivered/HistABC_',colorspace,modified,'.mat');
    var=load(name);
    output_args{1}=var.histoABC;
    name = strcat('DataSetDelivered/HistDF_',colorspace,modified,'.mat');
    var=load(name);
    output_args{1}=var.histoDF;
    name = strcat('DataSetDelivered/HistE_',colorspace,modified,'.mat');
    var=load(name);
    output_args{1}=var.histoE;
end

end