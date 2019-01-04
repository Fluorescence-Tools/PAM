%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Updates the Parameter List after change of data %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_ParameterList(obj,~,h)
global BurstData BurstMeta
if nargin == 2
    if isempty(obj)
        h = guidata(findobj('Tag','BurstBrowser'));
    else
        h = guidata(obj);
    end
end

file = BurstMeta.SelectedFile;
if numel(h.ParameterListX.String) ~= numel(BurstData{file}.NameArray) || any(~strcmp(h.ParameterListX.String',BurstData{file}.NameArray))
    paramX = h.ParameterListX.String{h.ParameterListX.Value};
    h.ParameterListX.String = BurstData{file}.NameArray;
    val = find(strcmp(BurstData{file}.NameArray,paramX));
    if ~isempty(val)
        h.ParameterListX.Value = val;
    else
        h.ParameterListX.Value = 1;
    end
end

if numel(h.ParameterListY.String) ~= numel(BurstData{file}.NameArray)
    paramY = h.ParameterListY.String{h.ParameterListY.Value};
    h.ParameterListY.String = BurstData{file}.NameArray;
    val = find(strcmp(BurstData{file}.NameArray,paramY));
    if ~isempty(val)
        h.ParameterListY.Value = val;
    else
        h.ParameterListY.Value = 1;
    end
end