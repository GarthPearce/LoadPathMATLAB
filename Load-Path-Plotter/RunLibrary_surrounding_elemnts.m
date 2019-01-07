function [varargout] = RunLibrary_surrounding_elemnts(test_list, prev_els)
%% Surrounding Elements 
% This function essentially reccurs through the element definitions to
% extract the nodes of the surrounding elements. This is used in computing
% the interpolation function as well as in locating a point in a model.

    local_nodes = unique([test_list(:).nodes]);
    
    num_nodes = length(local_nodes(:));
    
    surrounding_elements(num_nodes).elements = [];
    
    for k=1:num_nodes
        nodal_elements =  [local_nodes(k).inelement(:)]';
        surrounding_elements(k).elements = nodal_elements([nodal_elements(:).importeddata]>0);
    end
    unique_list = setdiff([surrounding_elements(:).elements], prev_els,'stable');
    prev_els = union([surrounding_elements(:).elements],prev_els,'stable');
    if isempty(unique_list)
        unique_list = prev_els(end);
    end
    varargout{1} = unique_list;
    varargout{2} = prev_els;
    
    
