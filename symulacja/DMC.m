classdef DMC
    
    properties
        M  % wymiary (N*ny)x(Nu*nu)
        Mp  % wymiary (N*ny)x((D-1)*nu)
        K  % wymiary (Nu*nu)x(N*ny)
    end
    
    methods
        function obj = setup(D, N, Nu, S_y1u1, S_y2u1, S_y1u2, S_y2u2)
            % constructing the S components
            S_arr = {};
            for i =1:D
                S_arr{i} = [S_y1u1(i),S_y1u2(i); 
                            S_y2u1(i),S_y2u2(i)];
            end
            
            % constructing the dynamic matrix
            obj.M = cell(N,Nu);
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
                    if i+j<D
                        obj.Mp(i,j) = S_arr(i+j) - S_arr(j);
                    else
                        obj.Mp(i,j) = S_arr(D) - S_arr(j);
                    end
                end
            end
            obj.Mp = cell2mat(obj.Mp);
            
            obj.K = ((obj.M'*obj.M + lambda*eye(Nu))^-1)*obj.M';
            
        end
        
        
        %TODO
        function controls = eval_control_vals(obj,inputArg)
            
        end
    end
end

