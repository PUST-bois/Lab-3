classdef DMC
    
    properties
        M  % dim (N*ny)x(Nu*nu)
        Mp  % dim (N*ny)x((D-1)*nu)
        K  % dim (Nu*nu)x(N*ny)
        K1 % dim nu x(N*ny)
        
        D %scalar
        N %scalar
        Nu %scalar
    end
    
    methods
        function obj = DMC(D, N, Nu, lambda, S_y1u1, S_y2u1, S_y1u2, S_y2u2)
            % constructing the S components
            S_arr = {};
            for i =1:D
                S_arr{end+1} = [S_y1u1(i),S_y1u2(i); 
                            S_y2u1(i),S_y2u2(i)];
            end
            
            % constructing the dynamic matrix
            obj.M = cell(N,Nu);
            zero_cell = {zeros(2)};
            for i = 1:size(obj.M,1)
                for j = 1:size(obj.M,2)
                    obj.M(i,j) = zero_cell;
                end
            end
            
            for i = 1:size(obj.M,1)
                for j = 1:size(obj.M,2)
                    if i>=j
                        obj.M(i,j) = S_arr(i-j+1);
                    end
                end
            end
            obj.M = cell2mat(obj.M);
            
            % constructing the Mp matrix        
            obj.Mp = cell(N,D-1);
            for i = 1:size(obj.Mp,1)
                for j = 1:size(obj.Mp,2)
                    obj.Mp(i,j) = zero_cell;
                end
            end
            
            for i = 1:size(obj.Mp,1)
                for j = 1:size(obj.Mp,2)
                    if i+j<D
                        obj.Mp(i,j) = {cell2mat(S_arr(i+j)) - cell2mat(S_arr(j))};
                    else
                        obj.Mp(i,j) = {cell2mat(S_arr(D)) - cell2mat(S_arr(j))};
                    end
                end
            end
            obj.Mp = cell2mat(obj.Mp);
            
            obj.K = ((obj.M'*obj.M + lambda*eye(Nu*2))^-1)*obj.M';
            obj.K1 = obj.K(1:2, :);
            
            obj.D = D;
            obj.N = N;
            obj.Nu = Nu;
        end
        
        
        
        function err = regulate(obj, sim_time, Yzad, init_controls) %Yzad = sim_time vector x ny
            nu = 2;
            ny = 2;
            
            err = zeros(ny,1);
            
            dUp = zeros((obj.D - 1)*nu);
            controls = init_controls;
            
            for k = 1:sim_time
                % reading input
                mrm = readMeasurements([1,3]);
                
                e = mrm' - Yzad(k,:)';
                err = err + e.^2;
                
                % creating Y(k) and Yzad(k)
                Y = repmat(mrm', obj.N, 1);
                Yzad_k = repmat(Yzad(k,:)', obj.N, 1);
                
                % evaluating delta u
                du = obj.K1*(Yzad_k - Y - obj.Mp * dUp);
                
                % sending controls
                controls = controls + du';
                sendControls([5,6]    ,... send for these elements
                             controls);  % new corresponding control values
                         
                temp = [du; dUp];
                dUp = temp(1:(obj.D - 1)*nu);
                
                
            end
        end
    end
end

