function [StressData, count] = Input_nodeDat(filePath, numNodes)
%% Description
% 
%  This function scans the nodalSolution.txt file and extracts the nodal
%  stress information. This is stored in StressData and passed on.
%  

%% Columns of StressData have the structure:
% StressData format:  
%[<Node number>, <X stress>, <Y stress>, <Z stress>, <XY stress>, <YZ stress>, <XZ stress>]

    path_separator = '/';
    if ispc
        path_separator = '\';
    end
    N_RESULTS = 7;
    filePath = strjoin([filePath  path_separator 'nodalSolution.txt'],'');
    
    dataFile = fopen(filePath);
%Scans until the start of the file is found. Trash data is a temp variable
%to test and advance the reading function.
    trashdata = 'a';
    startelements = '    NODE';

    while ~strncmpi(trashdata,startelements, length(startelements))
        trashdata = fgetl(dataFile);
    end
    StressData = nan(N_RESULTS,numNodes);
    count = 1;
    for i = 1:numNodes
        linetest = strtrim(fgetl(dataFile));
        
        if isempty(linetest)
            break
        end
        
        linetest = str2double(strsplit(linetest))';
        
        StressData(:,linetest(1)) = linetest;
        count = count+1;
    end
    count=count-1;
    fclose(dataFile);
end
