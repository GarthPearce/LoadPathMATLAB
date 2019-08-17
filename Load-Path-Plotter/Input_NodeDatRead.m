function [nodes] = Input_NodeDatRead(fname, StressData, numNodes)
%% Description
% This script builds node objects from the stress data read in from
% nodeDat.m. The initial reason this was not implemented in one parse was
% inconsistent node's coming from the files. This seemed to be happening
% when ANSYS would delete midside nodes, hence not storing their stress
% values, but keeping the numbering system. I built this as a workaround.
%
% Since then however, I cam up with a better way of doing this which I am
% yet to implement for nodes, but implemented for elements.

    clear nodes
    path_separator = '/';
    if ispc
        path_separator = '\';
    end
    fname = strjoin([fname  path_separator 'ds.dat'],'');
    
    nodeNums = StressData(1,:);
    xstress = StressData(2,:);
    ystress = StressData(3,:);
    zstress = StressData(4,:);
    xystress = StressData(5,:);
    yzstress = StressData(6,:);
    xzstress = StressData(7,:);
    
    %Opening file and scanning to the first useful string.
    datafile = fopen(fname);

    trashdata = 'a';
    startelements = '/com,*********** Nodes ';

    while ~strncmpi(trashdata,startelements, 23)
        trashdata = fgetl(datafile);
    end
    
    nid = 'a';
    
    while ~strncmpi(nid(1), '(', 1)
        nid = strtrim(fgetl(datafile));
    end
    
    nodes(1,numNodes) = Input_Node();
    
    linetest = fgetl(datafile);
    linetest = strsplit(linetest);
    linetest = str2double(linetest);
    
    %Building node objects to store stress data
    i = 1;
    while linetest(1) ~= -1
        if i == linetest(2)
            
            nodes(i) = Input_Node(linetest(2), linetest(3), linetest(4),linetest(5),...
                       xstress(i), ystress(i),zstress(i),xystress(i),...
                       yzstress(i),xzstress(i));
            linetest = fgetl(datafile);
            linetest = strsplit(linetest);
            linetest = str2double(linetest);
        else
            nodes(i) = Node(i, NaN, NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN);
        end
    
    i = i+1;
    end
    fclose(datafile); 
end
