function dmc_error = DMC(D, N, Nu, lambda, y_zad, wykres)
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



% Symulacja
u_max = 1;
u_min = -1;

sim_len = length(y_zad);
y = zeros(sim_len, 1);
u = zeros(sim_len, 1);
e = zeros(sim_len, 1);
du = zeros(sim_len, 1);
dmc_error = 0;

% Petla symulacji
for k=7:sim_len
    y(k) = symulacja_obiektu6y(u(k-5), u(k-6), y(k-1), y(k-2)); 
    e(k) = y_zad(k) - y(k);
    dmc_error = dmc_error + e(k)^2;
    sum_ku = 0;
    for i = 1:D-1
        if k-i > 1
            sum_ku = sum_ku + ku(i) * du(k-1);
        end
    end
    du(k) = ke*e(k) - sum_ku;
    
    u(k) = u(k-1) + du(k);
    if u(k) >= u_max
        u(k) = u_max;
    elseif u(k) <= u_min
        u(k) = u_min;
    end
end

if wykres > 0
    t = (0:sim_len-1)';
    figure;
    title("DMC");
    subplot(2,1,1);
    plot(t, y, 'b');
    hold on;
    plot(t, y_zad, '--r');
    xlabel('k');
    ylabel('y');
    hold off;
    subplot(2,1,2);
    plot(t, u, 'g');
    xlabel('k');
    ylabel('u');

    figure;
    plot(t, e);
    title("error");

    figure;
    plot(t, du);
    title("du");
end

