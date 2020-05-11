
A = [1,2;3,4];

C = {};
for i = 1:10
    for j = 1:10
        C{i,j} = A;
    end
end

cell2mat(C)