function [] = RunPlot_wireFrame(PartArr,Alpha, Buffer,nodes)
    ifsurfplot = 1;
    if ifsurfplot == 1;
	%Extract faces and order nodes lowest to highest
	nface = 0;
    [irow,numel] = size(PartArr(1).elements);    
    %disp(numel);
	for k = 1:numel;
		elnod = PartArr(1).elements(k).nodenums;
        %disp(elnod);
           nface = nface+1;
		faceM(nface,1) = elnod(1);
		faceM(nface,2) = elnod(2);
		faceM(nface,3) = elnod(3);
		faceM(nface,4) = elnod(4);
           nface = nface+1;
		faceM(nface,1) = elnod(5);
		faceM(nface,2) = elnod(6);
		faceM(nface,3) = elnod(7);
		faceM(nface,4) = elnod(8);
           nface = nface+1;
		faceM(nface,1) = elnod(5);
		faceM(nface,2) = elnod(1);
		faceM(nface,3) = elnod(4);
		faceM(nface,4) = elnod(8);
           nface = nface+1;
		faceM(nface,1) = elnod(6);
		faceM(nface,2) = elnod(2);
		faceM(nface,3) = elnod(3);
		faceM(nface,4) = elnod(7);
           nface = nface+1;
		faceM(nface,1) = elnod(5);
		faceM(nface,2) = elnod(6);
		faceM(nface,3) = elnod(2);
		faceM(nface,4) = elnod(1);
           nface = nface+1;
		faceM(nface,1) = elnod(8);
		faceM(nface,2) = elnod(7);
		faceM(nface,3) = elnod(3);
		faceM(nface,4) = elnod(4);
	end
	%Sort nodes on face in ascending order
	faceMO = sort(faceM,2);
	%Sort array by values in first column
	[sortedmat, index] = sortrows(faceMO,1);
    %sortedmat = sortrows(faceMO,1)
	%Find unique faces (= surface face)
    for jj = 1:nface-1;
        n1 = sortedmat(jj,1);
        if n1 > 0;
		n2 = sortedmat(jj,2);
		n3 = sortedmat(jj,3);
		n4 = sortedmat(jj,4);
		jj1 = jj+1;
        if jj1 < nface;
        %for jj1 = jj+1:nface;
        while sortedmat(jj1,1) == n1
          %if sortedmat(jj1,1) == n1;
			if sortedmat(jj1,2) == n2;
				if sortedmat(jj1,3) == n3;
					if sortedmat(jj1,4) == n4;
						for kkk = 2:4;
							sortedmat(jj1,kkk) = 0;
							sortedmat(jj,kkk) = 0;
						end
					end
				end
            end
          %end
          jj1 = jj1+1;
        end  
        end
        end
        %end
	end
        jj = 0;
		for kk = 1:nface;
			if sortedmat(kk,2) > 0;
				jj=jj+1;
                kkdk = index(kk);
				for kkk = 1:4;
					facesurf(jj,kkk) = faceM(kkdk,kkk);
                    %facesurf(jj,kkk) = sortedmat(kk,kkk);
				end					
			end
		end
		nfacesurf = jj; 
        kkdk = 0;
        xmax = -1.0e10;
        xmin = 1.0e10;
        ymax = xmax;
        ymin = xmin;
        zmax = xmax;
        zmin = xmin;
        for k = 1:nfacesurf;
            for kk = 1:4;
                kkdk = kkdk+1;
                kkk = facesurf(k,kk);
                XX(kkdk) = nodes(kkk).xCoordinate;
                YY(kkdk) = nodes(kkk).yCoordinate;
                ZZ(kkdk) = nodes(kkk).zCoordinate;               
                quad(k,kk) = kkdk;                
            end
        end   
            C = [0; 0; 0];
            drawnow;
            wf = quadmesh(quad,XX,YY,ZZ,C);
            wf.FaceAlpha = 0;
            wf.EdgeColor = [0; 0; 0];
            alpha = 0.5;
            wf.EdgeAlpha = Alpha;            
%        end    
    end
    if ifsurfplot == 0
    hold on
    warning('off','MATLAB:delaunayTriangulation:DupPtsWarnId');
    mmMat = ones(3,2);
    for k = 1:size(PartArr(:),1)
        tempNodearr = [PartArr(k).elements.nodes];
        x = [tempNodearr.xCoordinate];
        y = [tempNodearr.yCoordinate];
        z = [tempNodearr.zCoordinate];
        mmMat = newMinMax(x,y,z,mmMat);
        C = [x;y;z];
        DT = delaunayTriangulation(C');
        K = convexHull(DT);
        wf = trimesh(K,DT.Points(:,1),DT.Points(:,2),DT.Points(:,3));
        wf.FaceAlpha = 0;
        wf.EdgeColor = rand(1,3);
        wf.EdgeAlpha = Alpha;
    end
    a = gca;
    a.DataAspectRatio = [1 1 1];
    a.XLabel.String = 'X';
    a.YLabel.String = 'Y';
    a.ZLabel.String = 'Z';
    alim =max((mmMat(:,2) - mmMat(:,1)))*Buffer;
    lims =[mmMat(:,1)-alim,mmMat(:,2)+alim];
    a.XLim = lims(1,:);
    a.YLim = lims(2,:);
    a.ZLim = mmMat(3,:);
    end
end

function [mmMat] = newMinMax(x,y,z,mmMat)
    tempMinMaxVal =@(x,y,z) [[min(x);min(y);min(z)],[max(x);max(y);max(z)]];
    tmmV = tempMinMaxVal(x,y,z);
    a = mmMat(:,1) > tmmV(:,1);
    b = mmMat(:,2) < tmmV(:,2);
    mmMat(a,1) = tmmV(a,1);
    mmMat(b,2) = tmmV(b,2);
end
function hh = quadmesh(quad,x,y,z,varargin)
%QUADMESH Quadrilateral mesh plot.
%   QUADMESH(QUAD,X,Y,Z,C) displays the quadrilaterals defined in the M-by-4
%   face matrix QUAD as a mesh.  A row of QUAD contains indexes into
%   the X,Y, and Z vertex vectors to define a single quadrilateral face.
%   The edge color is defined by the vector C.
%
%   QUADMESH(QUAD,X,Y,Z) uses C = Z, so color is proportional to surface
%   height.
%
%   QUADMESH(TRI,X,Y) displays the quadrilaterals in a 2-d plot.
%
%   H = QUADMESH(...) returns a handle to the displayed quadrilaterals.
%
%   QUADMESH(...,'param','value','param','value'...) allows additional
%   patch param/value pairs to be used when creating the patch object. 
%
%   See also PATCH.
%
% Script code based on copyrighted code from mathworks for TRIMESH.
% Allan P. Engsig-Karup, apek@mek.dtu.dk.

ax = axescheck(varargin{:});
ax = newplot(ax);

if nargin == 3 || (nargin > 4 && ischar(z))
  d = tri(:,[1 2 3 4 1])';
  if nargin == 3
    h = plot(ax, x(d), y(d));
  else
    h = plot(ax, x(d), y(d),z,varargin{1},varargin{2:end});
  end
  if nargout == 1, hh = h; end
  return;
end

start = 1;
if nargin>4 && rem(nargin-4,2)==1
  c = varargin{1};
  start = 2;
elseif nargin<3
  error(id('NotEnoughInputs'),'Not enough input arguments');
else
  c = z;
end

if ischar(get(ax,'color')),
  fc = get(gcf,'Color');
else
  fc = get(ax,'color');
end

%pbaspect([2,0.5,0.25]);
RLX = max(x) - min(x);
RLY = max(y) - min(y);
RLZ = max(z) - min(z);
RLXX = 1.0;
RLYY = RLY/RLX;
RLZZ = RLZ/RLX;
pbaspect([RLXX,RLYY,RLZZ]);

h = patch('faces',quad,'vertices',[x(:) y(:) z(:)],'facevertexcdata',c(:),...
	  'facecolor',fc,'edgecolor',get(ax,'defaultsurfacefacecolor'),...
	  'facelighting', 'none', 'edgelighting', 'flat',...
      'parent',ax,...
	  varargin{start:end});
if ~ishold(ax), view(ax,3), grid(ax,'on'), end
if nargout == 1, hh = h; end

end
function str = id(str)
str = ['MATLAB:quadmesh:' str];

return
end