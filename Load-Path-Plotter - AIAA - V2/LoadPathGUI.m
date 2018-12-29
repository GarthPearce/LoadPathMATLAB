function varargout = LoadPathGUI(varargin)
% LOADPATHGUI MATLAB code for LoadPathGUI.fig
%      LOADPATHGUI, by itself, creates a new LOADPATHGUI or raises the existing
%      singleton*.
%
%      H = LOADPATHGUI returns the handle to a new LOADPATHGUI or the
%      handle to
%      the existing singleton*.
%
%      LOADPATHGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOADPATHGUI.M with the given input arguments.
%
%      LOADPATHGUI('Property','Value',...) creates a new LOADPATHGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LoadPathGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LoadPathGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LoadPathGUI

% Last Modified by GUIDE v2.5 13-Dec-2018 21:12:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LoadPathGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @LoadPathGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before LoadPathGUI is made visible.
function LoadPathGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LoadPathGUI (see VARARGIN)

% Choose default command line output for LoadPathGUI
handles.output = hObject;

% Update handles structure
set(handles.checkbox1, 'value',1)
set(handles.edit3, 'String', 'Load Path Model 1')
set(handles.edit1, 'String', 'C:\')
set(handles.edit2, 'String', 'C:\')
set(handles.edit4, 'String', 'C:\')
set(handles.text15, 'String', 'Step Size')

guidata(hObject, handles);

% UIWAIT makes LoadPathGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LoadPathGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in cmd_getDir.
function cmd_getDir_Callback(hObject, eventdata, handles)
% hObject    handle to cmd_getDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    folder_name = uigetdir(handles.edit1.String, 'Select Folder Containing Simulation Files');
    set(handles.edit1, 'String', folder_name)
    handles.cmd_getDir.UserData = sim_folder_check(folder_name);


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1



% --------------------------------------------------------------------


% --- Executes on selection change in popupm0enu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
    contents = cellstr(get(hObject,'String'));
    contents{get(hObject,'Value')};


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [file_name, path_dir] = uigetfile({'*.txt'}, 'Select Seed Point File');
    set(handles.edit2, 'String', [path_dir file_name])
    handles.pushbutton4.UserData = seed_point_check([path_dir file_name]);


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = helpdlg(['The Load Path program has been optimised to output a set of'...
' initialising data in the event that the user would like to select new'...
' seed locations. This greatly speeds up subsequent plots.'...
newline newline...
'If the underlying model has been modified then the user'...
' will need to select this option, as this data will need to be recomputed.'...
' If this is the first time this model has had load paths plotted, there'...
' is no need to select this option.'],'Recomputing Data');
help_dialog_settings(h)

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = helpdlg(['By default the Load Path program will output a simple PDF '...
    'of the path plots. If the user would like to plot paths at '...
    'different seed locations, the program will overwrite the previous '...
    'PDF.'...
    newline newline...
    'Select this option if the previous PDF is to be retained. New '...
    'PDF''''s will have the same file name but with the date and '...
    'time appended to the end of the name in the following structure:'...
    newline newline...
    '"''Output File Name - Path Direction\_HH.MM.SS\_dd/mm/yy''"'],...
    'Generating New PDF''''s');
help_dialog_settings(h)

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

helpmessage = ...
    ['The path direction should be selected in the relative to the '...
    'model''''s coordinate system. ' newline newline...
    '\bfNote:\rm Keep in mind that paths '...
    'that do not exit the model space at a reaction point will eddy.'...
    'When paths eddy, they will proceed to keep being computed '...
    'until the upper limit of the path length is reached leading to '...
    'longer run times.'...
    ];
h = helpdlg(helpmessage, 'Path Direction''''s');

help_dialog_settings(h)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpmessage = ...
    ['The Seed Point file is a text file that dictates where the '...
    'load paths will initiate from. Future developements will allow '...
    'the user to interactively select seed locations in a MATLAB '...
    'figure as well as load a file of seed locations.'...
    newline newline...
    'The format of the seed file for \itn\rm number of points is:'...
    newline newline...
    'X_1, Y_1, Z_1'...
    newline...
    'X_2, Y_2, Z_2'...
    newline...
    '      \ldots' newline newline...
    'X_n, Y_n, Z_n'...
    ];
h = helpdlg(helpmessage, 'Seed Point Files');

help_dialog_settings(h)

% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpmessage = ...
    ['The dimension of the simulation refers to whether the model is '...
    'two or three dimensional. AIAA - V1 only 3D.'...
    ];
h = helpdlg(helpmessage, 'Dimension of Simulation');

help_dialog_settings(h)

% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpmessage = ...
    ['The Load Path program has been developed to allow clustering '...
    'and general parallel processing.'...
    'If this option is selected the simulation will parallelise to '...
    'a default of four slave workers. This drastically improves '...
    'the performance.' newline...
    'However, it is recommended to run the program '...
    'with a single seed point first as MATLAB requires an intial '...
    'run of the code to perform optimally with parallelisation.'...
    newline newline ...
    'The default is on.'...
    ];
h = helpdlg(helpmessage, 'Dimension of Simulation');

help_dialog_settings(h)

% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpmessage = ...
    ['The simulation folder path is the directory where the core '...
    'simulation files are stored. It will typically look like: '...
    newline newline...
    '\itC:Sample Simulation\\Sample Simulation\_files\\dp0\\SYS-X\\MECH\rm'...
    newline newline...
    'The \it"SYS-X"\rm part of the file path refers to the system within '...
    'the ANSYS simulation. The user may have renamed the systems '...
    'within simulation, therefore it is important to check that'...
    ' the directory points to the correct system.'...
    newline newline...
    'This directory should contain all the files relavent to the load '...
    'path program. These files specifically are:\it' newline newline...
    'ds.dat' newline...
    'nodeInfo.txt' newline...
    'elInfo.txt' newline...
    'NodalSolution.txt\rm' newline...
    ];
h = helpdlg(helpmessage, 'Dimension of Simulation');

help_dialog_settings(h)


function help_dialog_settings(handle)
    text_handle = handle.Children(3).Children;
    text_handle.Interpreter = 'tex';
    text_handle.FontName = 'Cambria';
    text_handle.FontSize = 10;
    buffer = 7;
    chi_extent = text_handle.Extent;
    par_pos = handle.Position;
    new_pos_x = (chi_extent(3)+chi_extent(1));
    new_pos_y = (chi_extent(4)+chi_extent(2));
    handle.Position(3) = new_pos_x+buffer;
    handle.Position(4) = new_pos_y+buffer;
    


function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpmessage = ...
    ['Please choose a title for the load path model. Do not append '...
    'the load path direction or other information other than the title '...
    'as these are added automatically in the output files.'...
    ];
h = helpdlg(helpmessage, 'Choosing a Title');

help_dialog_settings(h)


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

helpmessage = ...
    ['Turn this option on if plotting pulse. '...
    'Code will create seeds and define minimum and maximum for plot of pulse.'
    ];
h = helpdlg(helpmessage, 'Plotting Pulse');

help_dialog_settings(h)


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    folder_name = uigetdir('C:\', 'Select Save Directory');
    set(handles.edit4, 'String', folder_name)


function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpmessage = ...
    ['The default save directory is the C: drive. Select an alternative '...
    'directory to save the output files and results.'...
    newline newline...
    '\bfNote:\rm Ensure the "data_*.mat" data file is in the save '...
    'directory if you are wanting to reuse the initilaisation data from '...
    'a previous simulation. Otherwise this information will be '...
    'recalculated, extending runtimes.'
    ];
h = helpdlg(helpmessage, 'Save Directory Selection');

help_dialog_settings(h)


% function retval = save_dir_check(save_dir)
%     retval = 1;
%     errmsg = '';
%     
%     if ~exist(save_dir, 'file')
%         retval = 0;
%         errmsg = ['The file does not exist.'...
%             newline newline...
%             'See "What''''s This?" for details on how to fill this field.'];
%     end
%     
%     if ~retval
%         errordlg(errmsg,'File Error');
%     end

    

    
function [retval] = sim_folder_check(sim_dir)
    retval = 1;
    
    req_files = {'ds.dat','nodeInfo.txt','nodalSolution.txt'};
    
    if ~exist(sim_dir, 'dir')
        retval = 0;
        errmsg = ['The directory does not exist or is not a folder.'...
            newline newline...
            'See "What''''s This?" for details on how to fill this field.'];
    end
    
    listing = dir(sim_dir);
    file_list = {listing.name};
    num_files = size(intersect(file_list,req_files),2);
    
    if sum(num_files) <length(req_files)
        retval = 0;
        errmsg = ['The appropriate files cannot be found. '...
            'Ensure all required files are available and '...
            'named according to the help directions.'...
            newline newline...
            'See "What''''s This?" for details.'];
    end
    
    if ~retval
        e = errordlg(errmsg,'File Error');
        help_dialog_settings(e)
    end

function [retval] = seed_point_check(seed_dir)
    retval = 1;
    errmsg = '';
    
    if ~exist(seed_dir, 'file')
        retval = 0;
        errmsg = ['The file does not exist.'...
            newline newline...
            'See "What''''s This?" for details on how to fill this field.'];
    end
    
    if ~retval
        e = errordlg(errmsg,'File Error');
        help_dialog_settings(e)
    end

    
    
    % --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    if ~handles.cmd_getDir.UserData
         errmsg = ['The appropriate files cannot be found. '...
            'The simulation cannot be started without the correct files. '...
            'Please select the correct Simulation Folder Path.'...
            newline newline...
            'See "What''''s This?" for details.'];
        e = errordlg(errmsg,'File Error');
        help_dialog_settings(e)
        return
    end
    
    if ~handles.pushbutton4.UserData
        errmsg = ['Please ensure the appropriate seed file is selected.'...
            'The simulation cannot be started without the correct files. '...
            newline newline...
            'See "What''''s This?" for details.'];
        e = errordlg(errmsg,'File Error');
        help_dialog_settings(e)
        return
    end
    
    if ~step_size_error_check(handles.edit5)
        return
    end
    
    if ~path_length_error_check(handles.edit6)
        return
    end
    
    %if ~path_minimum_vector_error_check(handles.edit7)
    %    return
    %end   
    
    %dimension = handles.popupmenu1.String{handles.popupmenu1.Value};
    dimension = '3D';
    model_name = handles.edit3.String;
    pulse = handles.checkbox4.Value;
    parallel = handles.checkbox1.Value;
    newPDF = handles.checkbox2.Value;
    recompute = handles.checkbox3.Value;
    sim_dir = string(handles.edit1.String);
    seed_dir = string(handles.edit2.String);
    save_dir = string(handles.edit4.String);
    path_dir = string(handles.popupmenu2.String{handles.popupmenu2.Value});
    step_size = handles.edit5.UserData;
    path_length = handles.edit6.UserData;
    plot_minimum_vector = handles.edit7.UserData;
    plot_maximum_vector = handles.edit8.UserData;
    Run_Solve_loadpath3D(...
        sim_dir, seed_dir, save_dir, model_name,path_dir,...
        pulse, parallel, newPDF,recompute, step_size, path_length,...
        plot_minimum_vector, plot_maximum_vector);

function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double
   if step_size_error_check(hObject)
        hObject.UserData = str2double(get(hObject,'String'));
   end

% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double
    if path_length_error_check(hObject)
        hObject.UserData = str2double(get(hObject,'String'));
    end
function [ret] = path_length_error_check(hObject)
    ret = 0;
    if isempty(get(hObject,'String'))
        return
    end
    path_length = str2double(get(hObject,'String'));
    if isnan(path_length) ||~floor(path_length) == path_length || path_length <= 0
        errmsg = ['The the path length must be a positive real integer.'...
            newline newline...
            'See "What''''s This?" for details.'];
        e = errordlg(errmsg,'Path Length');
        help_dialog_settings(e)
    end
    ret = 1;

function [ret] = step_size_error_check(hObject)
    ret = 0;
    if isempty(get(hObject,'String'))
        return
    end
    step = str2double(get(hObject,'String'));
    if isnan(step) || step<=0
        errmsg = ['The step size must be a positive real number.'...
            newline newline...
            'See "What''''s This?" for details.'];
        e = errordlg(errmsg,'Step Size Error');
        help_dialog_settings(e)
    end
    ret = 1;
    
% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
