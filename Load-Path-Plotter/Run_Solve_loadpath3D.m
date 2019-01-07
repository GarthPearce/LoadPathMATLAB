function Run_Solve_loadpath3D(sim_dir, seed_dir, save_dir, model_name,path_dir,...
                    pulse, parallel, newPDF, recompute, step_size, path_length,...
                    plot_minimum_vector, plot_maximum_vector)
%% ********************  House Keeping   ******************************
tic
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

    if ismac
        path_separator = '/';
    elseif ispc
        path_separator = '\';
        system(strjoin(['taskkill /fi "WINDOWTITLE eq ', model_name,'.pdf"'],''));
    end

    nodei = strjoin([sim_dir path_separator 'nodeInfo.txt'],'');
    numNodes = importdata(nodei);
    numNodes = numNodes(2);

    %% ******************  Populate Nodes and Elements  *********************

    % Detects whether previous data has been computed, if yes, skips
    % recomputation unless forced by user in GUI

    output_path = strjoin([save_dir, path_separator,'Path Data', path_separator, 'data_', model_data_name,'.mat'], '');

    if ~exist(output_path, 'file') || recompute

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
        ename = 'Path Data';
        dname = char(save_dir);
        mkdir(dname,ename);
        save(strjoin([dname path_separator ename path_separator 'data_' model_data_name '.mat'],''),'PartArr','nodes', 'nodePerEl');
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
        load(strjoin([save_dir path_separator 'Path Data' path_separator 'data_' model_data_name,'.mat'],''));
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
                    reverse_path = false;
                    [x, y, z, intense] = RunLibrary_rungekuttaNatInter3D(...
                        xseed(i),yseed(i),zseed(i), PartArr, path_dir,...
                        path_length,reverse_path,step_size, wb);
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
                        xseed(i),yseed(i),zseed(i), PartArr, path_dir,...
                        path_length,reverse_path,step_size, wb);
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
                    path_length,reverse_path,step_size, wb);
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
                end

                Paths(i).X.forward = x;
                Paths(i).Y.forward = y;
                Paths(i).Z.forward = z;
                Paths(i).I.forward = intense;
                current_time = current_time + 1/numSeeds *80/2;
                reverse_path = true;
                [dkx, dky, dkz, dkintense ] = RunLibrary_rungekuttaNatInter3D(...
                    xseed(i), yseed(i), zseed(i), PartArr, path_dir,...
                    path_length,reverse_path,step_size, wb);

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

    save(strjoin([save_dir path_separator 'Path Data' path_separator 'pathdata_' model_data_name '.mat'],''), 'Paths');
    fig = figure;
    fprintf('Plotting Paths\n')

    modelPlot3D([Paths(:).X],[Paths(:).Y],[Paths(:).Z],[Paths(:).I],...
            PartArr,nodes,pulse, plot_minimum_vector, plot_maximum_vector)
    % Create new directory to store the output plots
    ename = 'Path Plots';
    dname = char(save_dir);
    mkdir(dname,ename);
    %********************Name of 'bmp' file hard-wired ************************
    saveas(fig,strjoin([save_dir path_separator 'Path Plots' path_separator model_name, '.bmp'],''))
    %******************** Waitbar and Status Update ***************************
    if getappdata(wb,'canceling')
        delete(wb)
        return
    end
    fprintf('Printing to PDF\n')
    current_time = current_time + plot_time;
    waitbar(current_time/total_time,wb,sprintf('Printing PDF'))

    if newPDF
        dt = datestr(now,'yy_mm_dd_HH_MM_SS');
    else
        dt = '';
    end
    dateAppenedFN = strjoin([save_dir, path_separator, 'Path Plots', path_separator ,model_name,'_', dt, '.pdf'],'');

    gcf;
    print(fig,dateAppenedFN, '-dpdf','-r1000', '-fillpage');
    open(dateAppenedFN);

    % Contrary to variable name and the description in the GUI, this was
    % repurposed to let the user choose where to print the plot to a pdf or
    % not. As the density is so high to see the paths properly it can be an
    % expensive task to compute.

    delete(wb)
    fprintf('Load paths complete.\n')

    %%********************************End of Computation******************************
    toc
end
function [] = modelPlot3D(x_paths,y_paths,z_paths,Intensity,PartArr,...
                nodes,pulse, plot_minimum_vector, plot_maximum_vector)
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
            if vmax > plot_maximum_vector
                   vmax = plot_maximum_vector;
            end
            ncol = 64 * vmax/plot_maximum_vector;
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