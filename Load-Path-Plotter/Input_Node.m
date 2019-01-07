classdef Input_Node <  Define_FEM
    properties %(SetAccess = protected, GetAccess = protected)
        xStress;
        yStress;
        zStress;
        xyStress;
        yzStress;
        xzStress;
        xCoordinate;
        yCoordinate;
        zCoordinate;
        Coordinates;
        NodeNum = 0;
        xDisplacement;
        yDisplacement;
        tStress  = []       %stress vector
    end
    properties
        inelement =[Define_Element1()]; %arbitrary amount of zeros 
    end
    properties (Dependent = true)
        stress = [xStress, yStress, zStress]
        avStress ;
    end
    methods
        function obj = Input_Node(NodeNumber, X, Y,Z, sx, sy,sz,sxy,syz, sxz)
            if ~exist('sx', 'var')
                sx = 0;
            end
            if ~exist('sy', 'var')
                sy = 0;
            end
            if ~exist('sz', 'var')
                sz = 0;
            end
            if ~exist('syz', 'var')
                syz = 0;
            end
            if ~exist('sxz', 'var')
                sxz = 0;
            end
            if ~exist('sxy', 'var')
                sxy = 0;
            end
            if ~exist('X', 'var')
                X = 0;
            end
            if ~exist('Y', 'var')
                Y = 0;
            end
            if ~exist('Z', 'var')
                Z = 0;
            end
            if ~exist('NodeNumber', 'var')
                NodeNumber = 0;
            end
            obj.xStress = sx;
            obj.yStress = sy;
            obj.zStress = sz;
            obj.xyStress = sxy;
            obj.yzStress = syz;
            obj.xzStress = sxz;
            obj.xCoordinate = X;
            obj.yCoordinate = Y;
            obj.zCoordinate = Z;
            obj.Coordinates = [X; Y; Z];
            obj.NodeNum = NodeNumber;
        end
        
        function ret = get.stress(obj)
            %ret = obj.D * 
        end
        
        function obj = Displacement(obj, dispx, dispy)
            obj.xDisplacement = dispx;
            obj.yDisplacement = dispy;
        end
        
        function obj = set.inelement(obj, Element)
            if isnan(obj.inelement(1).ElementNo)
                obj.inelement(1) = Element;
            else
                obj.inelement(end+1) = Element;
            end
        end
        
        function [ret] = get.inelement(obj)
            ret = [obj.inelement];
        end
        
%         function obj = NodeStress(obj, obj.xDisplacement, obj.yDisplacement)
%             stress = obj.D * 
        
        function UpdateElement(obj, element)
            if isempty(obj.inelement)
                obj.inelement(1) = element
            else
                obj.inelement(end +1) = element
            end
            %obj.inelement(end +1) = element;
        end
        
        function Contained(obj)
            obj.inelement
        end
        
        %%Node Number set and get
        function Number(obj, num)
            obj.NodeNum = num
        end
        function [ret] = ShowNum(obj)
             ret = [obj.NodeNum];
        end
        function obj = set.NodeNum(obj, x)
            if nargin > 0
                if isnumeric(x)
                    obj.NodeNum = x;
                end
            end
        end

        function [ret] = get.NodeNum(obj)
            [ret] = obj.NodeNum;
        end

        %%Coordinate sets
        
        function obj = Stresses(x, y, z)
            obj.xStress = x;
            obj.yStress = y;
            obj.zStress = z;
        end
        
%         function obj = set.xCoordinate(obj, x)
%             if nargin > 0
%                 if isnumeric(x)
%                     obj.xCoordinate = x;
%                 end
%             end
%         end
%         
%         function obj = set.yCoordinate(obj, x)
%             if nargin > 0
%                 if isnumeric(x)
%                     obj.yCoordinate = x;
%                 end
%             end
%         end

        %%Stress set and gets
        function obj = set.xStress(obj, x)
            if nargin > 0
                if isnumeric(x)
                    obj.xStress = x;
                end
            end
        end
        
        function obj = set.yStress(obj, x)
            if nargin > 0
                if isnumeric(x)
                     obj.yStress = x;
                end
            end
        end

        function obj = set.zStress(obj, x)
            if nargin > 0
                if isnumeric(x)
                    obj.zStress = x;
                end
            end
        end
        
        function ret = get.xStress(obj)
            if isempty(obj.xStress)
                ret = obj.tStress(1);
                return
            end
            ret = obj.xStress;
        end
        
        function ret = get.yStress(obj)
            if isempty(obj.yStress)
                obj.yStress = obj.tStress(2);
            end
            ret = obj.yStress;
        end
        
        function ret = get.zStress(obj)
            if isempty(obj.yStress)
                obj.yStress = obj.tStress(3);
            end
            ret = obj.zStress;
        end
        
        function ret = get.avStress(obj)
            if obj.tStress ~= []
                ret = sum(obj.tStress, 2)./size(obj.tStress,2);
            else
                ret = [obj.xStress; obj.yStress; obj.xyStress];
            end
        end
        function [nodeList] = nodeFind(obj, list)
           nodeIdx = zeros(length(list), 1);
           for i =1:length(list)
                nodeIdx(i) = find([obj(:).NodeNum] == list(i));
           end
           nodeList = obj(nodeIdx);
        end
        

        
    end  
end


    