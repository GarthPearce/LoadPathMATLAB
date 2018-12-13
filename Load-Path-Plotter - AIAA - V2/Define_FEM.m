classdef Define_FEM  < handle
    
    properties
        E = 210e9;
        nu = 0.3;
        disp;
    end
    
    methods
        function obj = Define_FEM(E, nu)
            if nargin >0
                obj.E = E;
                obj.nu = nu;
                E1 = E/(1-nu^2);
                E2 = E1*nu;
                %obj.D = E/(1-nu^2)*[1 nu 0 ; nu 1 0; 0 0 (1-nu)/2];
            end
%             function ret = get.D(obj)
%                 ret = obj.D;
%             end
                
        end
    end
end