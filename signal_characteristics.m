function signal_characteristics(input_dir)

%call frequency of Appearance function
freqApp(input_dir)
%call max_min_size function
max_min_size(input_dir)
%put other functions below

end

function freqApp (input_dir)

list= dir([input_dir '/train/gt'])

for i=3: size(list,1)
     list(i).name
 [c1,c2,c3,c4,type]=   textread([input_dir '/train/gt/' list(i).name], '%s %s %s %s %s');
 if(ismember(type,arr_types))
     arr_types....
end

function max_min_size(input_dir)
list= dir([input_dir '/train/gt']);
%%MAX AND MIN ABSOLUTE ON THE TRAIN DB
max_size=[0, 0, 0];         %%max_size= area, width and height
min_size=[1000, 0, 0];      %%min_size= area, width and height

%%MAX AND MIN OF EACH TYPE OF SIGNALS
max_A= [0,0,0];             
max_B= [0,0,0];
max_C= [0,0,0];
max_D= [0,0,0];
max_E= [0,0,0];
max_F= [0,0,0];
min_A= [10000,0,0];
min_B= [10000,0,0];
min_C= [10000,0,0];
min_D= [10000,0,0];
min_E= [10000,0,0];
min_F= [10000,0,0];
for i=1:size(list,1)
    if(list(i).isdir)
    else
        fid = fopen([input_dir '/' list(i).name]); %%file ID 
        tline = fgets(fid);  %% get line: returns -1 at the end of the file
        while ischar(tline)
            str=(strread(tline,'%s')');   %% read each word. cell{1,5}
            c1=round(str2double((cell2mat(str(1)))));
            c2=round(str2double((cell2mat(str(2)))));
            c3=round(str2double((cell2mat(str(3)))));
            c4=round(str2double((cell2mat(str(4)))));
            types=(cell2mat(str(5)));
            area=(c3-c1)*(c4-c2);
            if(max_size(1)<area)        %%if the area of max_size is smaller than the actual area
                max_size=[area, (c4-c2), (c3-c1)];
            elseif(min_size(1)>area)
                min_size=[area, (c4-c2), (c3-c1)];
            end
            if(types=='A')
                if(max_A(1)<area)        %%if the area of max_size is smaller than the actual area
                    max_A=[area, (c4-c2), (c3-c1)];
                elseif(min_A(1)>area)
                    min_A=[area, (c4-c2), (c3-c1)];
                end
            end
            if(types=='B')
                if(max_B(1)<area)        %%if the area of max_size is smaller than the actual area
                    max_B=[area, (c4-c2), (c3-c1)];
                elseif(min_B(1)>area)
                    min_B=[area, (c4-c2), (c3-c1)];
                end
            end
            if(types=='C')
                if(max_C(1)<area)        %%if the area of max_size is smaller than the actual area
                    max_C=[area, (c4-c2), (c3-c1)];
                elseif(min_C(1)>area)
                    min_C=[area, (c4-c2), (c3-c1)];
                end
            end
            if(types=='D')
                if(max_D(1)<area)        %%if the area of max_size is smaller than the actual area
                    max_D=[area, (c4-c2), (c3-c1)];
                elseif(min_D(1)>area)
                    min_D=[area, (c4-c2), (c3-c1)];
                end
            end
            if(types=='E')
                if(max_E(1)<area)        %%if the area of max_size is smaller than the actual area
                    max_E=[area, (c4-c2), (c3-c1)];
                elseif(min_E(1)>area)
                    min_E=[area, (c4-c2), (c3-c1)];
                end
            end
            if(types=='F')
                if(max_F(1)<area)        %%if the area of max_size is smaller than the actual area
                    max_F=[area, (c4-c2), (c3-c1)];
                elseif(min_F(1)>area)
                    min_F=[area, (c4-c2), (c3-c1)];
                end
            end
            tline = fgets(fid);
        end

        fclose(fid);
       
    end
    
end
end


end
