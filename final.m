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

data(100, 999) = "NaN";
pattern = '))((';
for j=1:length(result)
    k=1;
    for i=1:length(result{j})
        str = result{j}{i};
        if strfind(str, pattern)>1
            tmp = regexp(str, '))((', 'split');
            data(j,k) = tmp{1};
            k=k+1;
            data(j,k) = tmp{2};
        else 
            data(j,k) = str;
        end
        k=k+1;
    end
end

for j=1:100
    for i=1:1033
        data(j,i) = strrep(data(j,i), '(', '');
        data(j,i) = strrep(data(j,i), ')', '');
    end
end

clear i j k pattern str result tmp

%% Separate data by chorale
for j=1:100
    i=0;
    k=1;
    n=true;
    while n==true
        k=k+1;
        if k>length(data)
            n=false;
        elseif data(j,k) == "st"
            i=i+1;
            k=k+1;
            chorale(i,1) = data(j,k);
            k=k+2;
            chorale(i,2) = data(j,k);
            k=k+2;
            chorale(i,3) = data(j,k);
            k=k+2;
            chorale(i,4) = data(j,k);
            k=k+2;
            chorale(i,5) = data(j,k);
            k=k+2;
            chorale(i,6) = data(j,k);
        end
    end
end
clear n ans i j k