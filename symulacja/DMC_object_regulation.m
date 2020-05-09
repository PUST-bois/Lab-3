%% SETUP
load('s.mat', 's');

% Wydluz s jesli N jest dluzsze
if N+Nu > length(s)
    temp = s;
    s = ones(N+Nu, 1);
    s(1:length(temp)) = temp;
    s(length(temp)+1:end) = s(length(temp));
end

% Obliczanie parametrow offline
% Macierz M
M = zeros(N,Nu);
for i = 1:size(M,1)
    for j = 1:size(M,2)
        if i>=j
            M(i,j) = s(i-j+1);
        end
    end
end
% Macierz Mp
Mp = zeros(N,D-1);
for i = 1:size(Mp,1)
    for j = 1:size(Mp,2)
        if i+j<D
            Mp(i,j) = s(i+j) - s(j);
        else
            Mp(i,j) = s(D) - s(j);
        end
    end
end
% Macierz K
K = ((M'*M + lambda*eye(Nu))^-1)*M';
ke = sum(K(1,:));
ku = zeros(D-1,1);
for i = 1:D-1
    ku(i) = K(1,:) * Mp(:,i);
end



y = zeros(sim_len, 2);
u = zeros(sim_len, 2);

e = zeros(sim_len, 1);
du = zeros(sim_len, 1);
dmc_error = 0;


%% STEROWANIE
while(1)
    measurements = readMeasurements([1,3]);
    disp(measurements);
    
end

