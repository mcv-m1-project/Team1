function [output_args] = loadHistograms(type, colorspace, modified)
%Returns one or 3 histograms (joint histogram or one histogram for red
%signals, one for blue signals and one for red&blue signals)
%Type: joint or anything else ('' for example)
%colorspace: 'hsv', 'lab'...
%modified: '_mod' for modified version, '' for original version

if strcmp(type,'joint')
    var=load(['DataSetDelivered/histogram_',colorspace,'.mat']);
    output_args=var.histAll;
else
    var=load(['DataSetDelivered/HistABC_',colorspace,modified,'.mat']);
    output_args{1}=var.histoABC;
    var=load(['DataSetDelivered/HistDF_',colorspace,modified,'.mat']);
    output_args{2}=var.histoDF;
    var=load(['DataSetDelivered/HistE_',colorspace,modified,'.mat']);
    output_args{3}=var.histoE;
end

end