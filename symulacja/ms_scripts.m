
%addpath('F:\SerialCommunication'); % add a path to the functions
initSerialControl COM3 % initialise com port
Y = [];
U = [];
k = 0;

work_point = [21,26];
stab_time = 100;
step = 10;

while(1)
    %% obtaining measurements
    measurements = readMeasurements([1,3]); % read measurements 1 and 3
    
    %         %% processing of the measurements and new control values calculation
    disp(measurements); % process measurements
    %
    %         %% sending new values of control signals
    if k < stab_time
        controls = work_point;
    else
        controls = work_point + step;
    end
    
    sendControls([5,6]    ,... send for these elements
        controls);  % new corresponding control values
    k = k+1;
    
    Y = [Y; measurements]; subplot(2,1,1); plot(Y);                   drawnow
    U = [U; controls];     subplot(2,1,2); stairs(U); ylim([-5,105]); drawnow
    
    %% synchronising with the control process
    waitForNewIteration(); % wait for new batch of measurements to be ready
end

