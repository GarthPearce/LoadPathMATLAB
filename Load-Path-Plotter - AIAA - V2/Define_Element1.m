classdef Define_Element1 < Define_FEM 
    
    properties (SetAccess = public, GetAccess = public)
        ElementNo = 0;
        nodes;
        importeddata = 0;
        nodenums;
        Faces;
        sphere_radius;
        part_num;
        part_idx;
        verticies;
        

    end

    methods
        %%Initialise Element%%
        function obj = Define_Element1(ElementNumber, xNodes, Import)

            if ~exist('ElementNumber', 'var')
                ElementNumber = NaN;
            end
            if ~exist('xNodes', 'var')
%                 xNodes = Node();
            end
            if ~exist('Import', 'var')
                obj.importeddata = 0;
            else
                obj.importeddata = 1;                
            end
            obj.ElementNo = ElementNumber;
            
            if exist('Import', 'var')
                                                              
                obj.nodes = xNodes;
                obj.nodenums = [xNodes(:).NodeNum];
                obj.verticies = [xNodes(:).Coordinates]';
                
                obj.sphere_radius = max(pdist([[xNodes(:).xCoordinate];...
                           [xNodes(:).yCoordinate];...
                           [xNodes(:).zCoordinate]]'))/2;
            end
        end
        
        function obj = set.ElementNo(obj, num)
            obj.ElementNo = num;
        end
        function obj = set.nodes(obj, Nodes)
            obj.nodes = Nodes;
            for k=1:length(Nodes)
                Nodes(k).inelement = obj;
            end
        end


    end 
end
 
