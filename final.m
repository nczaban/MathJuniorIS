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

for j=1:length(result)
    for i=1:length(result{j})
        if contains(result{j(1:i)}, '))((')
           for k=length(result{j}):-1:i+1
               result{j(1:k+1)} = result{j(1:k)};
           end
        end
%         result{j(1:i)} = strrep(result{j(1:i)}, '(', '');
%         result{j(1:i)} = strrep(result{j(1:i)}, ')', '');
    end
end