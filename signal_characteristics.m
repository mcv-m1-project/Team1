function signal_characteristics(input_dir)

%call frequency of Appearance function
freqApp(input_dir)
%put other functions below

end

function freqApp (input_dir)

list= dir([input_dir '/train/gt'])
arr_types=[];
for i=3: size(list,1)
     list(i).name
 [c1,c2,c3,c4,type]=   textread([input_dir '/train/gt/' list(i).name], '%s %s %s %s %s');
 if(~ismember(type,arr_types))
     if (isempty(arr_types))
         arr_types=[type];
     else
         arr_types=[arr_types type];
     end
 end
 end

arr_types

end


