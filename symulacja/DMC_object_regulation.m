% note - almost everything in this code is pretty much self-explanatory thus no comments are needed
clear all;

load('odp_est.mat')

Yzad = zeros(400,2);
Yzad(1:100,1) = 100;
Yzad(101:200,1) = 60;
Yzad(201:300,1) = 90;
Yzad(301:400,1) = 120;

Yzad(1:100,2) = 50;
Yzad(101:200,2) = 120;
Yzad(201:300,2) = 70;
Yzad(301:400,2) = 100;

sim_time = length(Yzad);
% sim_time = 10;
           %N %Nu %lambda
presets = [[300,300,1];
           [50,50,1];
           [10,10,1];
           [50,50,5]];
for i = 1:length(presets)
    clearvars -except sim_time Yzad S1_G1_est S3_G1_est S1_G2_est S3_G2_est presets i
    
    %addpath('F:\SerialCommunication'); % add a path to the functions
    initSerialControl COM3 % initialise com port
    
    nu=2;
    ny=2;
    controls = [0,0];
    
    N = presets(i,1);
    Nu = presets(i,2);
    lambda = presets(i,3);
    
    dmc = DMC(300,N,Nu,lambda,S1_G1_est,S3_G1_est, S1_G2_est, S3_G2_est);
    
    Y = [];
    U = [];
    disp_Yzad = [];
    err = zeros(ny,1);
    
    
    for k = 1:sim_time
        
        mrm = readMeasurements([1,3]);
        
        [controls, e] = dmc.eval_controls(mrm,  controls, Yzad(k,:));
        err = err + e;
        
        sendControls([5,6] , controls);
        
        disp_Yzad = [disp_Yzad; Yzad(k,:)];
        Y = [Y; mrm];
        U = [U; controls];
        
        subplot(2,1,1); plot(Y); hold on; plot(disp_Yzad); hold off;  drawnow
        subplot(2,1,2); stairs(U); ylim([-5,105]); drawnow
        title(sprintf('N = %d, Nu = %d, lmd = %d :',N,Nu, lambda))
        
        waitForNewIteration();
    end
    str = sprintf('N = %d, Nu = %d, lmd = %d :',N,Nu, lambda);
    disp(str)
    disp(err/k)
    
    
    x = 1:sim_time;
    xy1 = [x(:) Y(:,1)];
    xy2 = [x(:) Y(:,2)];
    xu1 = [x(:) U(:,1)];
    xu2 = [x(:) U(:,2)];
    xy_zad1 = [x(:) Yzad(:,1)];
    xy_zad2 = [x(:) Yzad(:,2)];
    
    dlmwrite(sprintf('OUT1 N = %d, Nu = %d, lmd = %d.txt',N,Nu, lambda), xy1, 'delimiter', ' ');
    dlmwrite(sprintf('OUT2 N = %d, Nu = %d, lmd = %d.txt',N,Nu, lambda), xy2, 'delimiter', ' ');
    dlmwrite(sprintf('IN1 N = %d, Nu = %d, lmd = %d.txt',N,Nu, lambda), xu1, 'delimiter', ' ');
    dlmwrite(sprintf('IN2 N = %d, Nu = %d, lmd = %d.txt',N,Nu, lambda), xu2, 'delimiter', ' ');
    dlmwrite(sprintf('SET1 N = %d, Nu = %d, lmd = %d.txt',N,Nu, lambda), xy_zad1, 'delimiter', ' ');
    dlmwrite(sprintf('SET2 N = %d, Nu = %d, lmd = %d.txt',N,Nu, lambda), xy_zad2, 'delimiter', ' ');
 
end


