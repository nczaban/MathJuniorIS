%% Read a lisp file containing data on Bach chorales
fid = fopen("chorales.lisp", 'rt');
tmp = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
clear fid

%% Split the read file into individual data sets
tmp = tmp{1};
result = regexp(tmp, ' ', 'split');
for i=2:(length(result)/2)+1
    result(i,:) = [];
end
clear tmp

pattern = "))((";
for j=1:length(result)
    for i=1:length(result{j})
        str=result{j}{i};
        if strfind(str, pattern)>1
            for k=length(result{j}):i+1:-1
                result{j}{i+1} = result{j}{i};
            end
            
        end
        result{j}{i} = strrep(result{j}{i}, '(', '');
        result{j}{i} = strrep(result{j}{i}, ')', '');
    end
end

clear i j k pattern str