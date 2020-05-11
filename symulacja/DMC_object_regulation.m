% note - almost everything in this code is pretty much self-explanatory thus no comments are needed

clear all;

%addpath('F:\SerialCommunication'); % add a path to the functions
initSerialControl COM3 % initialise com port

load('odp_est.mat')

nu=2;
ny=2;

Yzad = zeros(500,2);
Yzad(1:100,1) = 100;
Yzad(101:200,1) = 110;
Yzad(201:300,1) = 90;
Yzad(301:400,1) = 70;
Yzad(401:500,1) = 120;

Yzad(1:100,2) = 90;
Yzad(101:200,2) = 120;
Yzad(201:300,2) = 70;
Yzad(301:400,2) = 80;
Yzad(401:500,2) = 100;

sim_time = length(Yzad);

% work point
controls = [21,26];

dmc = DMC(300,300,300,1,S1_G1_est,S3_G1_est, S1_G2_est, S3_G2_est);

disp_Y = [];
disp_U = [];
disp_Yzad = [];
err = zeros(ny,1);


for k = 1:sim_time
    
    mrm = readMeasurements([1,3]);
    
    [controls, err] = dmc.eval_controls(mrm,  controls, Yzad(k,:));
    
    sendControls([5,6] , controls);  
    
    disp_Yzad = [disp_Yzad; Yzad(k,:)];                   
    disp_Y = [disp_Y; mrm];
    disp_U = [disp_U; controls];
    
    subplot(2,1,1); plot(disp_Y); hold on; plot(disp_Yzad); hold off;  drawnow
    subplot(2,1,2); stairs(disp_U); ylim([-5,105]); drawnow
    
    waitForNewIteration(); 
end


