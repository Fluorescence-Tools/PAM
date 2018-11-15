function Param_to_clip(~,~)
global BurstData BurstMeta
%%% copy the currently selected x-parameter to clipboard
h = guidata(gcbo);
%%% get the parameter
data = BurstData{BurstMeta.SelectedFile}.DataArray(BurstData{BurstMeta.SelectedFile}.Selected,strcmp(h.ParameterListX.String{h.ParameterListX.Value},BurstData{BurstMeta.SelectedFile}.NameArray));
Mat2clip(data);