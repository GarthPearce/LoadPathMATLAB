function [numNodes,PartArr] = Input_datread(fpath, nodes)
%% Description
% This script does much of the pre-proccesing, really its the
% pre-processing workhorse. datread.m takes the nodes generated in
% NodeDatRead.m and builds their corresponding elements.
% It also determines what element type's are in the model and adjusts
% the connectivity accordingly.


    if ismac
        slash = '/';
    elseif ispc
        slash = '\';
    end
    fname = [fpath  slash 'ds.dat'];

    datafile = fopen(fname);
% Scans down the ds.dat file until the start of the element definitions.
    trashdata = 'a';
    startelements = '/com,*********** Elements';

    while ~strncmpi(trashdata,startelements, 25)
        trashdata = fgetl(datafile);
    end
    % This loop runs down until it hits the line where the element type is
    % stored. The way the data is stored in the ds.dat file for some
    % elements means that it is necessary to skip a line when reading in
    % data, hence the skip line variable is a booean value. Tet elements
    % haven't been added here as yet.
    elid = 'a';
    numNodes = 0;
    while ~strncmpi(elid, 'eblock', 5)
        elid = fgetl(datafile);
        if strncmpi(elid, 'et', 2)
            [skipLine, numNodes, ~, type] = caseCheck(elid);
        end
    end

    temp = strsplit(elid,',');
    
    %The number of elements in a part can be read from one of the lines in
    %the ds.dat file.
    numel = str2double(temp(end));
    
    %The linetest variable is the variable used to temporarily store and
    %extract information being read in.
    linetest = fgetl(datafile);
    linetest = fgetl(datafile);
    start = 1;
    numParts = 1;
    
    %The part array was a necessary data structure to contain the different
    %parts that were being meshed independently. It has three attributes,
    %elements, range and span. Span is a weak attribute technically
    %speaking as it is a derivative of range.
    PartArr(numParts).elements(numel) = Define_Element1();
    PartArr(numParts).range = [];
    PartArr(numParts).span = numel;
    counter=1;
    
    %max_rad stores the maximum distance between any two nodes within an
    %element thats in the structure. This radius is used later to filter
    % unecessary tests.
    max_rad = 0;     
    while ~strcmpi(linetest, '-1')
        
        nums = strsplit(linetest);
        nums = str2double(nums(end-numNodes:end));
        
        if start
            start = false;
            stidx = nums(1);
            PartArr(numParts).range(1) = stidx;
        end
        
        nodes_nums = nums(2:end);
        
        %Extracting the corresponding node objects
        element_nodes = nodes(nodes_nums);
        
        %Creating and asssigning nodes to the element object
        PartArr(numParts).elements(counter) = Define_Element1(nums(1), element_nodes,1);
        
        %Storing which part the element belongs to
        PartArr(numParts).elements(counter).part_num = numParts;
        %Stores the radius of influence for the element
        sphere_influence_tracker = PartArr(numParts).elements(counter).sphere_radius;
        
        if sphere_influence_tracker >= max_rad
            max_rad = sphere_influence_tracker;
        end

        linetest = fgetl(datafile);
        counter =counter+1;
        
        if skipLine
            linetest = fgetl(datafile);
        end
        
        %This code just catches the end of a part definition in the ds.dat
        %file and progresses until all parts are populated.
        if strcmpi(linetest, '-1')
            endidx = nums(1);
            PartArr(numParts).range(2) = endidx;
            linetest = fgetl(datafile);
            linetest = fgetl(datafile);
            PartArr(numParts).span = PartArr(numParts).range(2) - PartArr(numParts).range(1);
            if strncmpi(linetest, '/com,*********** Elements for Body',34)
                numParts = numParts+1;
                temp = {};
                while length(temp) <9
                    if strncmpi(linetest, 'et', 2)
                        [skipLine, numNodes,numElements, type] = caseCheck(linetest);
                    end
                    linetest = fgetl(datafile);
                    temp = strsplit(linetest);
                end
                start = true; 
                counter = 1;
            else
                linetest = '-1';
            end
        end
    end
    %The max rad is used as the first sphere of influence radius, then
    %local radii are used.
    PartArr(1).maxRadius = max_rad;    
    fclose(datafile); 
end
function [skipLine, numNodes, numElements, type] = caseCheck(linetest)
%Automating the element check
    ElTypeCheck = strsplit(linetest, ',');
    numNodes = 8;
    skipLine = 0;
    numElements = str2double(ElTypeCheck(end));
    type = char(ElTypeCheck(3));
end