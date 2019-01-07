function [x_path, y_path,z_path, intensity] =  RunLibrary_rungekuttaNatInter3D(...
    xseed,yseed,zseed, PartArr, pathDir,maxPathLength, ReversePath,...
    step_size, wb)

    %p0 is initial seed point. Projection multiplier is used to 'jump' gaps
    %between parts in the model. It will project the path from onee part to
    %another. This procedure is a big source of time, some thought needs to
    %be given to how to optimise this routine.
    projectionMultiplier = 2;
    p0 = [xseed; yseed; zseed];

    %Anonymous functions to streamline the organisation of the path
    %direction.
    Vx =@(stress, shearxy,shearxz) [stress; shearxy; shearxz];
    Vy =@(stress, shearxy, shearyz) [shearxy; stress; shearyz];
    Vz =@(stress, shearxz, shearyz) [shearxz; shearyz; stress];

    switch lower(pathDir)
        case 'x'
            V = Vx;
        case 'y'
            V = Vy;
        case 'z'
            V = Vz;
    end
    %Locate the seed point in the model globally.

    [in, Element] = point_in_element(p0, PartArr);

    if in
        %Get and set stress function
        [F, Fs1, Fs2] = setInterpFunc(Element, pathDir, ReversePath);
    else
        fprintf('Seed Point (%f, %f, %f) not in solution domain\n', xseed, yseed, zseed);
        x_path = [];
        y_path = [];
        z_path =[];
        intensity = [];
        return
    end
    %Populating with NaN's prevents plotting errors later.
    p = NaN(3,maxPathLength,'double');
    intensity = NaN(1,maxPathLength,'double');
    w = 1;
    element_change = false;

    while w <= maxPathLength && in ~= false
        %Terminate program if cancel button is pressed
        if getappdata(wb,'canceling')
            delete(wb)
            break
        end
        %Interpolate stress initially, and get the relative normalisation
        %value. If the element is unchanged, the same stress function can
        %be used.

        p(:,w) = p0;
        stress = F(p0(1), p0(2), p0(3));
        shear1 = Fs1(p0(1), p0(2), p0(3));
        shear2 = Fs2(p0(1), p0(2), p0(3));
        intensity(w) = norm([stress shear1 shear2]);
        %Find dp1 at first interpolation.
        %Normalise the poining vector relative to the initial test point.
        %Calculate new points:

        %Runge-Kutta
        dp1 = V(stress, shear1, shear2)*step_size/intensity(w);
        p1 = p0 + dp1;

        dp2 = stress_interp(p1);
        p2 = p0 + 0.5*dp2;

        dp3 = stress_interp(p2);
        p3 = p0 + 0.5*dp3;

        dp4 = stress_interp(p3);

        p0 = p0 + 1/6 * (dp1 + 2*dp2 + 2*dp3 + dp4);

	    %Locate element that the point is inside
        [in, new_Element] = point_in_element(p0, PartArr);

        %If the point is outside the local radius, we attempt to find it
        %globablly. The path is projected along its last vector in an
        %attempt to get it to 'land' in another element for the case where
        %its in a small gap between elements.

        % [in, p0, Element] = projection(in, p0, Element)

        if in && new_Element(1).ElementNo ~= Element(1).ElementNo
            [F, Fs1, Fs2] = setInterpFunc(Element,pathDir, ReversePath);
        end

        Element = new_Element;
        w=w+1;
    end
    nancols = ~isnan(p(1,:));
    if nancols > 1
        %To keep plot inside domain
        nancols = nancols-1;
    end
    x_path = p(1,nancols);
    y_path = p(2,nancols);
    z_path = p(3,nancols);
    intensity = intensity(nancols);

    function [d_point] = stress_interp(p)
        stress = F(p(1), p(2), p(3));
        shear1 = Fs1(p(1), p(2), p(3));
        shear2 = Fs2(p(1), p(2), p(3));
        d_point =  V(stress, shear1, shear2)*step_size/intensity(w);
    end
end
function [F, Fs1, Fs2] = setInterpFunc(Element, pathDir, ReversePath)
    %Natural interpolation method is used to form a stress function to then
    %compute the paths.
    surr_elements = RunLibrary_surrounding_elemnts(Element, Element);
    nodes = unique([surr_elements(:).nodes]);
    coordx = [nodes(:).xCoordinate]';
    coordy = [nodes(:).yCoordinate]';
    coordz = [nodes(:).zCoordinate]';

    switch pathDir
        case 'X'
            stress_tensor = [[nodes(:).xStress]', [nodes(:).xyStress]', [nodes(:).xzStress]'];
        case 'Y'
            stress_tensor = [[nodes(:).yStress]', [nodes(:).xyStress]', [nodes(:).yzStress]'];
        case 'Z'
            stress_tensor = [[nodes(:).zStress]', [nodes(:).yzStress]', [nodes(:).xzStress]'];
    end
    F = scatteredInterpolant(coordx, coordy, coordz, stress_tensor(:,1), 'natural');
    Fs1 = scatteredInterpolant(coordx, coordy, coordz, stress_tensor(:,2), 'natural');
    Fs2 = scatteredInterpolant(coordx, coordy, coordz, stress_tensor(:,3), 'natural');
    %Flips the stress function when the backwards path is being computed.
    if ReversePath
        F=@(x,y, z) -F(x,y, z);
        Fs1=@(x,y,z) -Fs1(x,y,z);
        Fs2=@(x,y,z) -Fs2(x,y,z);
    end
end

function [varargout] = point_in_element(p0, PartArr)
    in_test = ~any(dot(PartArr.face_normals,-PartArr.face_centroids + p0,1)>0,2);
    in = any(in_test);
    Element = PartArr(1).elements(in_test);
    varargout = {in, Element};
end

function [varargout] = projection(in, p0, Element)
    if ~in
        extension = 1;
        while ~in && extension < projectionMultiplier+1
            R = (p0 - p(:,w)) * extension * 2 + p0;
            [in, new_Element] = point_in_element(R, PartArr);
            extension = extension+1;
        end
        if in
            p0 = R;
            Element = new_Element;
        end
    end
    varargout = {in, p0, Element};
end
