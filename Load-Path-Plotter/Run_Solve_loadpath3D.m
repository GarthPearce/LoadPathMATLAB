function Run_Solve_loadpath3D(simulationDirectory, seedDirectory, saveDirectory, modelName,pathDirectory,...
                    pulse, parallel, newPDF, recompute, stepSize, pathLength,...
                    plotMinimumVector, plotMaximumVector)
%% ********************  House Keeping   ******************************
tic
% Closes previously opened waitbars
    F = findall(0,'type','figure','tag','TMWWaitbar');
    delete(F);

    % Read's seed data in
    Seed = importdata(seedDirectory, ',');
    [numSeeds, ~] = size(Seed);
    if numSeeds > 0
        xSeed = Seed(:,1);
        ySeed = Seed(:,2);
        zSeed = Seed(:,3);
    end

%% HouseKeeping - waitbar setup
    waitBar = waitbar(0,'1','Name','Computing Load Paths',...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
    setappdata(waitBar,'canceling',0)
    DATA_READ_TIME = 7;
    PLOT_TIME = 3;
    PRINT_TIME = 10;
    PATH_TIME = 80;
    totalTime = DATA_READ_TIME + PLOT_TIME + PRINT_TIME + PATH_TIME;
    CURRENT_TIME = 0;
    warning('off','MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
    warning('off','MATLAB:MKDIR:DirectoryExists')

    %% Naming output files and killing interfering processes
    modelName = [modelName, ' - ',upper(pathDirectory), ' Path'];
    modelDataName = regexprep(modelName, ' ', '_');

    pathSeparator = '/';
    if ispc
        pathSeparator = '\';
        system(strjoin(['taskkill /fi "WINDOWTITLE eq ', modelName,'.pdf"'],''));
    end

    iNode = strjoin([simulationDirectory pathSeparator 'nodeInfo.txt'],'');
    numNodes = importdata(iNode);
    numNodes = numNodes(2);

    %% ******************  Populate Nodes and Elements  *********************

    % Detects whether previous data has been computed, if yes, skips
    % recomputation unless forced by user in GUI

    output_path = strjoin([saveDirectory, pathSeparator,'Path Data', pathSeparator, 'data_', modelDataName,'.mat'], '');

    if ~exist(output_path, 'file') || recompute

        fprintf('New model or user nominated to recompute data. Starting now.\n')
        waitbar(CURRENT_TIME/totalTime,waitBar,sprintf('Computing Initial Data'))

        %Nodal Information module
        [StressData, numNodes] = Input_nodeDat(simulationDirectory, numNodes);
        CURRENT_TIME = CURRENT_TIME + DATA_READ_TIME/3;
        waitbar(CURRENT_TIME/totalTime,waitBar,sprintf('Computing Initial Data'))
        fprintf('Nodal information complete. Starting stress population.\n')

        %Node data module
        [nodes] = Input_NodeDatRead(simulationDirectory, StressData, numNodes);
        CURRENT_TIME = CURRENT_TIME + DATA_READ_TIME/3;
        waitbar(CURRENT_TIME/totalTime,waitBar,sprintf('Computing Initial Data'))
        fprintf('Nodal stresses populated. Element generation beginning.\n')

        %Element data and main data structure generation -  %DK read element connectivity is read
        [nodePerEl, PartArr] = Input_datread(simulationDirectory,nodes); 
        CURRENT_TIME = CURRENT_TIME + DATA_READ_TIME/3;

        fprintf('Elements constructed, directories being created and data being saved.\n')
        eName = 'Path Data';
        dName = char(saveDirectory);
        mkdir(dName,eName);
        save(strjoin([dName pathSeparator eName pathSeparator 'data_' modelDataName '.mat'],''),'PartArr','nodes', 'nodePerEl');
    %% ******************  Define quadrilateral faces of elements **************************
    %% ******************  and check face normal is positive pointing out  **************
    %% ******************  Only works for Hex8 Bricks

        numParts = 1;
        [irow,numel] = size(PartArr(numParts).elements);

        %% ******************  If numSeeds == 0 Define Seeds based on maximum pointing vector **************************
        %% ******************  Defines seeds at peak of pulse for transient solution          **************************
        if numSeeds == 0
            %Set up list of element pointing vectors
            %Determine x-coordinate for maximum magnitude of pointing vector 
            %to define peak of pulse. Set seeds on all elements with XCG
            %equal to that value
            VectorMag = zeros(1,numel);
            for k = 1:numel
                elnods = PartArr(1).elements(k).nodenums;
                PointVec = zeros(1,3);
                for kk = 1,8;
                    kkk = elnods(kk);
                    if pathDirectory == 'X'
                        PointVec(1) = PointVec(1) + nodes(kkk).xStress/8.0;
                        PointVec(2) = PointVec(2) + nodes(kkk).xyStress/8.0;
                        PointVec(3) = PointVec(3) + nodes(kkk).xzStress/8.0;
                    end
                    if pathDirectory == 'Y'
                        PointVec(1) = PointVec(1) + nodes(kkk).xyStress/8.0;
                        PointVec(2) = PointVec(2) + nodes(kkk).yStress/8.0;
                        PointVec(3) = PointVec(3) + nodes(kkk).yzStress/8.0;
                    end
                    if pathDirectory == 'Z'
                        PointVec(1) = PointVec(1) + nodes(kkk).xzStress/8.0;
                        PointVec(2) = PointVec(2) + nodes(kkk).yzStress/8.0;
                        PointVec(3) = PointVec(3) + nodes(kkk).zStress/8.0;
                    end
                end
                VectorMag(k) = norm(PointVec);
            end
            [VectorSort, IX] = sort(VectorMag);
            k=1;
            kk = IX(numel-k+1);
            xs = CGXYZ(1,kk);
            ys = CGXYZ(2,kk);
            zs = CGXYZ(3,kk);
            nSeeds = 0;
            for k = 1:numel
                if abs(CGXYZ(1,k) - xs) < 0.1
                    nSeeds = nSeeds + 1;
                    xSeed(nSeeds) = CGXYZ(1,k);
                    ySeed(nSeeds) = CGXYZ(2,k);
                    zSeed(nSeeds) = CGXYZ(3,k);
                end
            end
            numSeeds = nSeeds;
        end
    else
        %This loads data if the preprocessign has already been done.
        fprintf('Previous model detected, loading data.\n')
        waitbar(CURRENT_TIME/totalTime,waitBar,sprintf('Loading Data'))
        load(strjoin([saveDirectory pathSeparator 'Path Data' pathSeparator 'data_' modelDataName,'.mat'],''));
        CURRENT_TIME = CURRENT_TIME + DATA_READ_TIME;

        fprintf('Data loaded. Starting path computation.\n')
    end
        %******************** Waitbar and Status Update ***************************

    if getappdata(waitBar,'canceling')
        delete(waitBar)
        return
    end

    waitbar(CURRENT_TIME/totalTime,waitBar,sprintf('Starting Paths'))

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
                    reverse_path = false;
                    [x, y, z, intense] = RunLibrary_rungekuttaNatInter3D(...
                        xSeed(i),ySeed(i),zSeed(i), PartArr, pathDirectory,...
                        pathLength,reverse_path,stepSize, waitBar);
                    if isempty(x)
                        fprintf('Path %i unsuccessful\n',i)
                        continue
                    end
                    reverse_path = true;
                    Paths(i).X.forward = x;
                    Paths(i).Y.forward = y;
                    Paths(i).Z.forward = z;
                    Paths(i).I.forward = intense;

                     [x, y, z, intense ] = RunLibrary_rungekuttaNatInter3D(...
                        xSeed(i),ySeed(i),zSeed(i), PartArr, pathDirectory,...
                        pathLength,reverse_path,stepSize, waitBar);
                    Paths(i).X.total = [fliplr(x), Paths(i).X.forward];
                    Paths(i).Y.total = [fliplr(y), Paths(i).Y.forward];
                    Paths(i).Z.total = [fliplr(z), Paths(i).Z.forward];
                    Paths(i).I.total = [fliplr(intense), Paths(i).I.forward];
                    [mdk,ndk] = size(intense);
                    fprintf('Path %i done\n',i);
                end
                CURRENT_TIME = CURRENT_TIME +80;
    	  % ******************   Single thread processing
        case 0
            for i = 1:numSeeds
                %fprintf('Starting path %i\n',i)
                if getappdata(waitBar,'canceling')
                    delete(waitBar)
                    return
                end
                waitbar(CURRENT_TIME/totalTime,waitBar,sprintf('Seed %i of %i Computing', i, numSeeds))
                warning('off','MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
                reverse_path = false;
                [dkx, dky, dkz, dkintense] = RunLibrary_rungekuttaNatInter3D(...
                    xSeed(i),ySeed(i),zSeed(i), PartArr, pathDirectory,...
                    pathLength,reverse_path,stepSize, waitBar);
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
                        %Plot path only if magnitude of pointing vector >
                        %minimum define in input
                        if dkintense(kdk) > plotMinimumVector;
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
                CURRENT_TIME = CURRENT_TIME + 1/numSeeds *80/2;
                reverse_path = true;
                [dkx, dky, dkz, dkintense ] = RunLibrary_rungekuttaNatInter3D(...
                    xSeed(i), ySeed(i), zSeed(i), PartArr, pathDirectory,...
                    pathLength,reverse_path,stepSize, waitBar);

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
                        if dkintense(kdk) > plotMinimumVector;
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
                CURRENT_TIME = CURRENT_TIME + 1/numSeeds *80/2;
                fprintf('Path %i done\n',i)
            end
    end
    fprintf('All seeds tested and appropriate paths computed. Saving path data.\n')

    %******************** Waitbar and Status Update ***************************

    if getappdata(waitBar,'canceling')
        delete(waitBar)
        return
    end
    waitbar(CURRENT_TIME/totalTime,waitBar,sprintf('Paths Finished Paths, Saving and Plotting now...\n'))

    %% ****************  Plotting and Printing  ******************************
    %Data is output to .mat files so that in a future update the user can
    %modulate the load path program. For example they could load previous
    %paths and just run the plotting and printing section of the code. Or
    %the user could just compute the paths and then send them to someone
    %else to plot them on their machine or with their specific settings.

    %Other considerations are for future transient analysis where multiple
    %data sets may have to be condensed. And that its a good backup of the
    %path calculation.

    save(strjoin([saveDirectory pathSeparator 'Path Data' pathSeparator 'pathdata_' modelDataName '.mat'],''), 'Paths');
    fig = figure;
    fprintf('Plotting Paths\n')

    modelPlot3D([Paths(:).X],[Paths(:).Y],[Paths(:).Z],[Paths(:).I],...
            PartArr,nodes,pulse, plotMinimumVector, plotMaximumVector)
    % Create new directory to store the output plots
    eName = 'Path Plots';
    dName = char(saveDirectory);
    mkdir(dName,eName);
    %********************Name of 'bmp' file hard-wired ************************
    saveas(fig,strjoin([saveDirectory pathSeparator 'Path Plots' pathSeparator modelName, '.bmp'],''))
    %******************** Waitbar and Status Update ***************************
    if getappdata(waitBar,'canceling')
        delete(waitBar)
        return
    end
    fprintf('Printing to PDF\n')
    CURRENT_TIME = CURRENT_TIME + PLOT_TIME;
    waitbar(CURRENT_TIME/totalTime,waitBar,sprintf('Printing PDF'))

    if newPDF
        dt = datestr(now,'yy_mm_dd_HH_MM_SS');
    else
        dt = '';
    end
    dateAppenedFN = strjoin([saveDirectory, pathSeparator, 'Path Plots', pathSeparator ,modelName,'_', dt, '.pdf'],'');

    gcf;
    print(fig,dateAppenedFN, '-dpdf','-r1000', '-fillpage');
    % open(dateAppenedFN);

    % Contrary to variable name and the description in the GUI, this was
    % repurposed to let the user choose where to print the plot to a pdf or
    % not. As the density is so high to see the paths properly it can be an
    % expensive task to compute.

    delete(waitBar)
    fprintf('Load paths complete.\n')

    %%********************************End of Computation******************************
    toc
end
function [] = modelPlot3D(x_paths,y_paths,z_paths,Intensity,PartArr,...
                nodes,pulse, plotMinimumVector, plotMaximumVector)
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
            if vmax > plotMaximumVector
                   vmax = plotMaximumVector;
            end
            ncol = 64 * vmax/plotMaximumVector;
            for i = 1:ncol
                for j = 1:3
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
    caxis([minInt maxInt])
end