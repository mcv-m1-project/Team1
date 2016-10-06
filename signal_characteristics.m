function signal_characteristics(input_dir)

%call frequency of Appearance function
freqApp(input_dir)
%put other functions below

end

function freqApp (input_dir)

list= dir([input_dir '/train/gt'])

for i=1: size(list,1)
 %   textread([input_dir '/train/gt/' list(i).name],) 
end

end
