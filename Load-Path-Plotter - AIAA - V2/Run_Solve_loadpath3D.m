function Run_Solve_loadpath3D(sim_dir, seed_dir, save_dir, model_name,path_dir,...
                    pulse, parallel, newPDF, recompute, step_size, path_length,...
                    plot_minimum_vector, plot_maximum_vector)
%% ********************  House Keeping   ******************************
% Closes previously opened waitbars
    F = findall(0,'type','figure','tag','TMWWaitbar');
    delete(F);

    % Read's seed data in
    Seed = importdata(seed_dir, ',');
    [numSeeds, ~] = size(Seed);
    if numSeeds > 0
        xseed = Seed(:,1);
        yseed = Seed(:,2);
        zseed = Seed(:,3);
    end

%% HouseKeeping - waitbar setup
    wb = waitbar(0,'1','Name','Computing Load Paths',...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
    setappdata(wb,'canceling',0)
    data_read_time = 7;
    plot_time = 3;
    print_time = 10;
    path_time = 80;
    total_time = data_read_time + plot_time + print_time + path_time;
    current_time = 0;
    warning('off','MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
    warning('off','MATLAB:MKDIR:DirectoryExists')

    %% Naming output files and killing interfering processes
    model_name = [model_name, ' - ',upper(path_dir), ' Path'];
    model_data_name = regexprep(model_name, ' ', '_');

    %Want to make this platform independent. This line is only supported in
    %windows distributions. Working on generalising, as yest dont have
    %corresponding mac command.
%     system(['taskkill /fi "WINDOWTITLE eq ', model_name,'.pdf"']);
    if ismac
        slash = '/';
    elseif ispc
        slash = '\';
        system(['taskkill /fi "WINDOWTITLE eq ', model_name,'.pdf"']);
    end

    nodei = [sim_dir slash 'nodeInfo.txt'];
    numNodes = importdata(nodei);
    numNodes = numNodes(2);

    %% ******************  Populate Nodes and Elements  *********************

    % Detects whether previous data has been computed, if yes, skips
    % recomputation unless forced by user in GUI

    if ~exist([save_dir slash 'Path Data' slash 'data_' model_data_name,'.mat'], 'file') || recompute

        fprintf('New model or user nominated to recompute data. Starting now.\n')
        waitbar(current_time/total_time,wb,sprintf('Computing Initial Data'))

        %Nodal Information module
        [StressData, numNodes] = Input_nodeDat(sim_dir, numNodes);
        current_time = current_time + data_read_time/3;
        waitbar(current_time/total_time,wb,sprintf('Computing Initial Data'))
        fprintf('Nodal information complete. Starting stress population.\n')

        %Node data module
        [nodes] = Input_NodeDatRead(sim_dir, StressData, numNodes);
        current_time = current_time + data_read_time/3;
        waitbar(current_time/total_time,wb,sprintf('Computing Initial Data'))
        fprintf('Nodal stresses populated. Element generation beginning.\n')

        %Element data and main data structure generation -  %DK read element connectivity is read
        [nodePerEl, PartArr] = Input_datread(sim_dir,nodes); 
        current_time = current_time + data_read_time/3;

        fprintf('Elements constructed, directories being created and data being saved.\n')
        mkdir([save_dir, slash 'Path Data'])
        save([save_dir,slash 'Path Data' slash 'data_',model_data_name,'.mat'],'PartArr','nodes', 'nodePerEl');

    %% ******************  Define quadrilateral faces of elements **************************
    %% ******************  and check face normal is positive pointing out  **************
    %% ******************  Only works for Hex8 Bricks
        numParts = 1;
        [irow,numel] = size(PartArr(numParts).elements);
        RN(1:3,1:6,1:numel) = 0.0;
        XC(1:6,1:numel) = 0.0;
        YC(1:6,1:numel) = 0.0;
        ZC(1:6,1:numel) = 0.0;
        nfaces = 6;
        %numel = PartArr(1).span;
            I = 1;
            J = 2;
            K = 3;
            L = 4;
            M = 5;
            N = 6;
            O = 7;
            P = 8;
        dkfaces = [[J;I;L;K],[I;J;N;M],[J;K;O;N],[K;L;P;O],[L;I;M;P],[M;N;O;P]];
        for kk = 1:numel
            elnods = PartArr(1).elements(kk).nodenums;
            for k = 1:nfaces
                for kkk = 1:4
                    kkkk = dkfaces(kkk,k);
                    kkkkk = elnods(kkkk);
                    Xdk(kkk,k) = nodes(kkkkk).xCoordinate;
                    Ydk(kkk,k) = nodes(kkkkk).yCoordinate;
                    Zdk(kkk,k) = nodes(kkkkk).zCoordinate;
                end
                %Centroid of face
                XC(k,kk) = 0.0;
                YC(k,kk) = 0.0;
                ZC(k,kk) = 0.0;
                for kkk = 1:4
                    XC(k,kk) = XC(k,kk) + Xdk(kkk,k)/4.0;
                    YC(k,kk) = YC(k,kk) + Ydk(kkk,k)/4.0;
                    ZC(k,kk) = ZC(k,kk) + Zdk(kkk,k)/4.0;
                end
            end
            %CG of  element kk
            for kkk=1:3
                CGXYZ(kkk,kk) = 0.0;
            end
            for k = 1 : nfaces;
                CGXYZ(1,kk) = CGXYZ(1,kk) + XC(k,kk)/6.0;
                CGXYZ(2,kk) = CGXYZ(2,kk) + YC(k,kk)/6.0;
                CGXYZ(3,kk) = CGXYZ(3,kk) + ZC(k,kk)/6.0;
            end
            for k = 1:nfaces;
                %Normal to face
                V1 = Xdk(3,k) - Xdk(1,k);
                V2 = Ydk(3,k) - Ydk(1,k);
                V3 = Zdk(3,k) - Zdk(1,k);
                RL = V1*V1 + V2*V2 + V3*V3;
                RL = sqrt(RL);
                V1 = V1/RL;
                V2 = V2/RL;
                V3 = V3/RL;
                W1 = Xdk(4,k) - Xdk(2,k);
                W2 = Ydk(4,k) - Ydk(2,k);
                W3 = Zdk(4,k) - Zdk(2,k);
                RL = W1*W1 + W2*W2 + W3*W3;
                RL = sqrt(RL);
                W1 = W1/RL;
                W2 = W2/RL;
                W3 = W3/RL;
                %Normal = V1 X V2
                RN(1,k,kk) = V2*W3-V3*W2;
                RN(2,k,kk) = V3*W1-V1*W3;
                RN(3,k,kk) = V1*W2-V2*W1;
                V1 = XC(k,kk) - CGXYZ(1,kk);
                V2 = YC(k,kk) - CGXYZ(2,kk);
                V3 = ZC(k,kk) - CGXYZ(3,kk);
                dot = RN(1,k,kk)*V1 + RN(2,k,kk)*V2 + RN(3,k,kk)*V3;
                if dot < 0;
                    for kkk = 1:3;
                        RN(kkk,k,kk) = -RN(kkk,k,kk);
                    end
                end
            end
        end
        clear N
%         N = gpuArray([XC;YC;ZC]);
        N(1,:,:) = XC;
        N(2,:,:) = YC;
        N(3,:,:) = ZC;
        %% ******************  If numSeeds == 0 Define Seeds based on maximum pointing vector **************************
        %% ******************  Defines seeds at peak of pulse for transient solution          **************************   
        if numSeeds == 0;
            %Set up list of element pointing vectors
            %Determine x-coordinate for maximum magnitude of pointing vector 
            %to define peak of pulse. Set seeds on all elements with XCG
            %equal to that value        
            VectorMag(1:numel) = 0.0; 
            for k = 1:numel
                elnods = PartArr(1).elements(k).nodenums;
                PointVec(1:3) = 0.0;
                for kk = 1,8;
                    kkk = elnods(kk);    
                    if path_dir == 'X'
                        PointVec(1) = PointVec(1) + nodes(kkk).xStress/8.0;
                        PointVec(2) = PointVec(2) + nodes(kkk).xyStress/8.0;
                        PointVec(3) = PointVec(3) + nodes(kkk).xzStress/8.0;
                    end
                    if path_dir == 'Y'
                        PointVec(1) = PointVec(1) + nodes(kkk).xyStress/8.0;
                        PointVec(2) = PointVec(2) + nodes(kkk).yStress/8.0;
                        PointVec(3) = PointVec(3) + nodes(kkk).yzStress/8.0;
                    end
                    if path_dir == 'Z'
                        PointVec(1) = PointVec(1) + nodes(kkk).xzStress/8.0;
                        PointVec(2) = PointVec(2) + nodes(kkk).yzStress/8.0;
                        PointVec(3) = PointVec(3) + nodes(kkk).zStress/8.0;
                    end
                end
                VectorMag(k) = sqrt(PointVec(1)*PointVec(1)+PointVec(2)*PointVec(2)+PointVec(3)*PointVec(3));
            end
            [VectorSort, IX] = sort(VectorMag);
                k=1;
                kk = IX(numel-k+1);
                xs = CGXYZ(1,kk);
                ys = CGXYZ(2,kk);
                zs = CGXYZ(3,kk);
                nSeeds = 0;
            for k = 1:numel;    
                if abs(CGXYZ(1,k) - xs) < 0.1;
                nSeeds = nSeeds + 1;
                xseed(nSeeds) = CGXYZ(1,k);
                yseed(nSeeds) = CGXYZ(2,k);
                zseed(nSeeds) = CGXYZ(3,k);
                end
            end    
            numSeeds = nSeeds;
        end  
            
    else
        %This loads data if the preprocessign has already been done.
        fprintf('Previous model detected, loading data.\n')
        waitbar(current_time/total_time,wb,sprintf('Loading Data'))
        load([save_dir slash 'Path Data' slash 'data_' model_data_name,'.mat']);
        current_time = current_time + data_read_time;
        
        fprintf('Data loaded. Starting path computation.\n')
        
    end
        %******************** Waitbar and Status Update ***************************

    if getappdata(wb,'canceling')
        delete(wb)
        return
    end
    
    waitbar(current_time/total_time,wb,sprintf('Starting Paths'))

    %% ****************  Load Path Generation  ******************************
    
    %Initialise data containers for load paths
    
    Paths(numSeeds).X.forward = [];
    Paths(numSeeds).Y.forward = [];
    Paths(numSeeds).Z.forward = [];
    Paths(numSeeds).I.forward = [];
    Paths(numSeeds).X.total = [];
    Paths(numSeeds).Y.total = [];
    Paths(numSeeds).Z.total = [];
    Paths(numSeeds).I.total = [];
        
    switch parallel
        %Parallel computation if load paths
        case 1
            workers = 4;
                % Currently 2D and 3D are separate, very crude. Future
                % update is to pass as vector and scale all functions
                % according to the length of that vector.
                parfor (i = 1:numSeeds, workers)
                    fprintf('Starting path %i\n',i)
                    warning('off','MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
                    %Main work horse module - Runge Kutta

                    [x, y, z, intense] = RunLibrary_rungekuttaNatInter3D(xseed(i),...
                        yseed(i),zseed(i), PartArr, path_dir, nodePerEl,path_length,false,step_size,wb,nodes,RN,XC,YC,ZC);                        
                    if isempty(x)
                        fprintf('Path %i unsuccessful\n',i)
                        continue
                    end

                    Paths(i).X.forward = x;
                    Paths(i).Y.forward = y;
                    Paths(i).Z.forward = z;
                    Paths(i).I.forward = intense;

                     [x, y, z, intense ] = ...
                        RunLibrary_rungekuttaNatInter3D(xseed(i), yseed(i),...
                        zseed(i), PartArr, path_dir, nodePerEl,path_length, true,step_size, wb,RN,N);                       
                    Paths(i).X.total = [fliplr(x), Paths(i).X.forward];
                    Paths(i).Y.total = [fliplr(y), Paths(i).Y.forward];
                    Paths(i).Z.total = [fliplr(z), Paths(i).Z.forward];
                    Paths(i).I.total = [fliplr(intense), Paths(i).I.forward];
                    [mdk,ndk] = size(intense);                                               
                    fprintf('Path %i done\n',i);                        
                end
                current_time = current_time +80;   
    	  % ******************   Single thread processing
        case 0
            for i = 1:numSeeds
                %fprintf('Starting path %i\n',i)
                if getappdata(wb,'canceling')
                    delete(wb)
                    return
                end

                waitbar(current_time/total_time,wb,sprintf('Seed %i of %i Computing', i, numSeeds))
                warning('off','MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
                reverse_path = false;
                [dkx, dky, dkz, dkintense] = RunLibrary_rungekuttaNatInter3D(...
                    xseed(i),yseed(i),zseed(i), PartArr, path_dir,...
                    path_length,reverse_path,step_size, wb,RN,N);
                if isempty(dkx)
                    fprintf('Path %i unsuccessful\n',i)
                    continue
                end

                %Next block only plot peak of pulse
                if pulse == 1
                    clear x;
                    clear y;
                    clear z;
                    clear intense;
                    x = [];
                    y = [];
                    z = [];
                    intense = [];
                    kdk = 1;
                    kkdk = 0;
                    [mdk,ndk] = size(dkintense);
                    while kdk < ndk;
                        %Hard wired to plot path only if magnitude of pointing vector > 20
                        %pointing vector > 20.0
                        if dkintense(kdk) > 20.0;
                            kkdk = kkdk+1;
                            x(kkdk) = dkx(kdk);
                            y(kkdk) = dky(kdk);
                            z(kkdk) = dkz(kdk);
                            intense(kkdk) = dkintense(kdk);
                        end
                        kdk = kdk + 1;
                    end
                end
                if pulse == 0
                    x = dkx;
                    y = dky;
                    z = dkz;
                    intense = dkintense;
                end  

                Paths(i).X.forward = x;
                Paths(i).Y.forward = y;
                Paths(i).Z.forward = z;
                Paths(i).I.forward = intense;
                current_time = current_time + 1/numSeeds *80/2;
                reverse_path = true;
                [dkx, dky, dkz, dkintense ] = RunLibrary_rungekuttaNatInter3D(...
                    xseed(i), yseed(i), zseed(i), PartArr, path_dir,...
                    path_length,reverse_path,step_size, wb,RN,N);

                %Next block added by dk to only plot peak of pulse

                if pulse == 1
                    clear x;
                    clear y;
                    clear z;
                    clear intense;
                    x = [];
                    y = [];
                    z = [];
                    intense = [];
                    kdk = 1;
                    kkdk = 0;                      
                    [mdk,ndk] = size(dkintense);
                    while kdk < ndk;
                        %Only plot path if magnitude of pointing
                        %vector  > 20 and x coordinate is < 200.
                        %This is to stop path extending past 200 in some
                        %cases and changing length of plot for movie. 
                        if dkintense(kdk) > plot_minimum_vector;
                            kkdk = kkdk+1;
                            x(kkdk) = dkx(kdk);
                            y(kkdk) = dky(kdk);
                            z(kkdk) = dkz(kdk);
                            intense(kkdk) = dkintense(kdk);
                        end
                        kdk = kdk + 1;
                    end
                end
                if pulse == 0
                    x = dkx;
                    y = dky;
                    z = dkz;
                    intense = dkintense;
                    [mdk,ndk] = size(intense);
                end
                Paths(i).X.total = [fliplr(x), Paths(i).X.forward];
                Paths(i).Y.total = [fliplr(y), Paths(i).Y.forward];
                Paths(i).Z.total = [fliplr(z), Paths(i).Z.forward];
                Paths(i).I.total = [fliplr(intense), Paths(i).I.forward];
                current_time = current_time + 1/numSeeds *80/2;
                fprintf('Path %i done\n',i)
            end
    end
    fprintf('All seeds tested and appropriate paths computed. Saving path data.\n')

    %******************** Waitbar and Status Update ***************************

    if getappdata(wb,'canceling')
        delete(wb)
        return
    end
    waitbar(current_time/total_time,wb,sprintf('Paths Finished Paths, Saving and Plotting now...\n'))

    %% ****************  Plotting and Printing  ******************************
    %Data is output to .mat files so that in a future update the user can
    %modulate the load path program. For example they could load previous
    %paths and just run the plotting and printing section of the code. Or
    %the user could just compute the paths and then send them to someone
    %else to plot them on their machine or with their specific settings.

    %Other considerations are for future transient analysis where multiple
    %data sets may have to be condensed. And that its a good backup of the
    %path calculation.

    save([save_dir slash 'Path Data' slash 'pathdata_' model_data_name '.mat'], 'Paths');
    fig = figure;
    fprintf('Plotting Paths\n')

    modelPlot3D([Paths(:).X],[Paths(:).Y],[Paths(:).Z],[Paths(:).I],PartArr,nodes,pulse)
    % Create new directory to store the output plots
    mkdir(save_dir,[slash 'Path Plots'])
    %********************Name of 'bmp' file hard-wired ************************
    %saveas(fig,'examples\Example1 - Isotropic Plate with Loaded Hole\Path Plots\myplot.bmp')
    saveas(fig,[save_dir slash 'Path Plots' slash model_name, '.bmp'])
    %******************** Waitbar and Status Update ***************************
    if getappdata(wb,'canceling')
        delete(wb)
        return
    end
    fprintf('Printing to PDF\n')
    current_time = current_time + plot_time;
    waitbar(current_time/total_time,wb,sprintf('Printing PDF'))

    if newPDF
        dt = datestr(now,'HH.MM.SS_dd/mm/yy');
        dateAppenedFN = [save_dir, slash 'Path Plots' slash ,model_name,'_', dt, '.pdf'];
    else
        dateAppenedFN = [save_dir,slash 'Path Plots' slash ,model_name, '.pdf'];
    end

    % Contrary to variable name and the description in the GUI, this was
    % repurposed to let the user choose where to print the plot to a pdf or
    % not. As the density is so high to see the paths properly it can be an
    % expensive task to compute.
    
    %Future update will check whether an instance of the .pdf is already
    %open and modify the name so that saving conflicts dont happen.
            
    delete(wb)
    fprintf('Load paths complete.\n')

    %%********************************End of Computation******************************
end
function [] = modelPlot3D(x_paths,y_paths,z_paths,Intensity,PartArr,nodes,pulse)
    %Just some custom settings for plotting the paths
    Alpha = 0.1;
    Buffer = 0.35;
    RunPlot_wireFrame(PartArr,Alpha, Buffer,nodes);
    seedLength = size(x_paths(:),1);
    maxInt = max(max([Intensity.total]));
    minInt = min(min([Intensity.total]));
    if isempty(maxInt)
        disp('No Successful Paths')
        return
    end
    for k = 1:seedLength
        if isempty(x_paths(k).total)
            fprintf('Path %i unsuccessful', k)
            continue
        end
        cd = colormap('parula');
        %%*********************************If transient solution hardwire maximum ***********
        %%*********************************Should be same for all plots in sequence *********
        %%*********************************Not just current plot. ***************************
        %%*********************************pulse = 1 if plot is transient *************
        if pulse == 1
		    cd = colormap(flipud(hot));
            cdd = [];
            cd = [];
            cdd = flipud(hot(64));
            vmax = max([Intensity(k).total]);
            if vmax > plot_maximum_vector;
                   vmax = plot_maximum_vector;
            end       
            ncol = 64 * vmax/plot_maximum_vector;
            for i = 1:ncol;
                for j = 1:3;
                    cd(i,j) = cdd(i,j);
                end
            end 
            cd = colormap(cd);
        end    
        %finish   
        cd = interp1(linspace(minInt,maxInt,length(cd)),cd,Intensity(k).total);
        cd = uint8(cd'*255);
        cd(4,:) = 255;
        paths = line(x_paths(k).total,y_paths(k).total,z_paths(k).total);
        drawnow;
        set(paths.Edge,'ColorBinding','interpolated', 'ColorData',cd)
    end
    %Turn off plot of colorbar
    colorbar;
end
