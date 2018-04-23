clear all
clc
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
    while k<=length(data)
        if data(j,k) == "st"
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
        k=k+1;
    end
    % Create Naive Model - Assumes that every chorale ends on the tonic of
    % its starting key
    chorale=str2double(chorale);
    train = chorale(1:size(chorale,1)-1, :);
    val = chorale(size(chorale,1), :);
    switch(train(1,4))
        case 0 % C Major
            prediction=60;
        case 1 % G Major
            prediction=67;
        case 2 % D Major
            prediction=62;
        case 3 % A Major
            prediction=69;
        case 4 % E Major
            prediction=64;
        case -1 % F Major
            prediction=65;
        case -2 % Bb Major
            prediction=70;
        case -3 % Eb Major
            prediction=63;
        case -4 % Ab Major
            prediction=68;
    end
    N_results(j,:) = [prediction, val(2)];
    if N_results(j,1)-N_results(j,2)>0
        results(j,1)=1;
    elseif N_results(j,1)-N_results(j,2)==0
        results(j,1)=0;
    else
        results(j,1)=-1;
    end
    clear prediction
    % Create smarter model: Uses interval between the last two notes and
    % goes to the nearest note in the triad
    S_results(j,:) = [train(size(train,1)-1,2), train(size(train,1)-1,4), train(size(train,1),2), train(size(train,1),4)];
    switch(S_results(j,2))
        case 0 % C Major
            n1 = mod(S_results(j,1), 12);
            n2 = mod(S_results(j,3), 12);
        case 1 % G Major
            n1 = mod(S_results(j,1)-7, 12);
            n2 = mod(S_results(j,3)-7, 12);
        case 2 % D Major
            n1 = mod(S_results(j,1)-2, 12);
            n2 = mod(S_results(j,3)-2, 12);
        case 3 % A Major
            n1 = mod(S_results(j,1)-9, 12);
            n2 = mod(S_results(j,3)-9, 12);
        case 4 % E Major
            n1 = mod(S_results(j,1)-4, 12);
            n2 = mod(S_results(j,3)-4, 12);
        case -1 % F Major
            n1 = mod(S_results(j,1)-5, 12);
            n2 = mod(S_results(j,3)-5, 12);
        case -2 % Bb Major
            n1 = mod(S_results(j,1)-10, 12);
            n2 = mod(S_results(j,3)-10, 12);
        case -3 % Eb Major
            n1 = mod(S_results(j,1)-3, 12);
            n2 = mod(S_results(j,3)-3, 12);
        case -4 % Ab Major
            n1 = mod(S_results(j,1)-8, 12);
            n2 = mod(S_results(j,3)-8, 12);
    end
    if n1==0 && n2==2 || n1==7 && n2==9 || n1==7 && n2==7 || n1==5 && n2==4
        tmp(j,1) = S_results(j,1);
        tmp(j,2) = n1;
    end
    if n1==5 && n2==2 || n1==8 && n2==9 || n1==8 && n2==8 || n1==5 && n2==5
        tmp(j,1) = S_results(j,1)-1;
        tmp(j,2) = n1-1;
    end
    if n1==2 && n2==7 || n1==2 && n2==0
        tmp(j,1) = S_results(j,3);
        tmp(j,2) = n2;
    end
    if n2==11
        tmp(j,1) = S_results(j,3)+1;
        tmp(j,2) = n2+1;
    end
    if n1==7 && n2==5 || n1==9 && n2==8 || n1==2 && n2==1
        tmp(j,1) = S_results(j,3)-1;
        tmp(j,2) = n2-1;
    end
    if n1==4 && n2==2 ||  n1==2 && n2==2 || n1==3 && n2==2 || n1==11 && n2==9 || n1==9 && n2==9
        tmp(j,1) = S_results(j,3)-2;
        tmp(j,2) = n2-2;
    end
    
    if tmp(j,1)-val(2)>0
        results(j,2)=1;
    elseif tmp(j,1)-val(2)==0
        results(j,2)=0;
    else
        results(j,2)=-1;
    end
    if tmp(j,2)==12
        tmp(j,2)=0;
    end
    
    % Add the actual note position in the key to results matrix
    switch(val(1,4))
        case 0 % C Major
            results(j,3)=mod(val(1,2), 12);
        case 1 % G Major
            results(j,3)=mod(val(1,2)-7, 12);
        case 2 % D Major
            results(j,3)=mod(val(1,2)-2, 12);
        case 3 % A Major
            results(j,3)=mod(val(1,2)-9, 12);
        case 4 % E Major
            results(j,3)=mod(val(1,2)-4, 12);
        case -1 % F Major
            results(j,3)=mod(val(1,2)-5, 12);
        case -2 % Bb Major
            results(j,3)=mod(val(1,2)-10, 12);
        case -3 % Eb Major
            results(j,3)=mod(val(1,2)-3, 12);
        case -4 % Ab Major
            results(j,3)=mod(val(1,2)-8, 12);
    end
    
    validation(j,:)=val(2);
    clear chorale val train n1 n2
end
z=zeros(100,1);
%confusionmat(z, results(:,1))
%confusionmat(z, results(:,2))
    % Confusion Matrix based on the relative position in the key
%confusionmat(results(:,3), tmp(:,2))
clear z n ans i j k

%% Build computer model: For each note in the chorale, calculate the probability of that note being the ending pitch
for j=1:100
    k=2;
    i=1;
    while k<=length(data)
        if data(j,k) == "st"
            k=k+1;
            chorale(j,i) = data(j,k);
            k=k+2;
            i=i+1;
            chorale(j,i) = data(j,k);
            k=k+2;
            i=i+1;
            chorale(j,i) = data(j,k);
            k=k+2;
            i=i+1;
            chorale(j,i) = data(j,k);
            k=k+2;
            i=i+1;
            chorale(j,i) = data(j,k);
            k=k+2;
            i=i+1;
            chorale(j,i) = data(j,k);
            i=i+1;
        elseif j==1
            chorale=str2double(chorale);
            break;
        else
            break;
        end
        k=k+1;
    end
end
clear i j k
train=chorale(21:100, :);
val=validation(21:100, :);
T=fitctree(train, val);
P=predict(T, chorale(1:20, :));
finalResults=P;

train=chorale([1:20 41:100], :);
val=validation([1:20 41:100], :);
T=fitctree(train, val);
P=predict(T, chorale(21:40, :));
finalResults(21:40, :)=P;

train=chorale([1:40 61:100], :);
val=validation([1:40 61:100], :);
T=fitctree(train, val);
P=predict(T, chorale(41:60, :));
finalResults(41:60, :)=P;

train=chorale([1:60 81:100], :);
val=validation([1:60 81:100], :);
T=fitctree(train, val);
P=predict(T, chorale(61:80, :));
finalResults(61:80, :)=P;

train=chorale(1:80, :);
val=validation(1:80, :);
T=fitctree(train, val);
P=predict(T, chorale(81:100, :));
finalResults(81:100, :)=P;

confusionmat(finalResults, validation)
clear k val train
j=0;
over=0;
under=0;
for i=1:100
    if finalResults(i)-validation(i)==0
        j=j+1;
    elseif finalResults(i)-validation(i)>0
        over=over+1;
    else
        under=under+1;
    end
end
view(T,'Mode', 'Graph')
computer_model=[over;j;under]
clear i j under over P data ans train val computer_model