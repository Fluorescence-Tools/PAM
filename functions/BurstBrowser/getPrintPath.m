function path = getPrintPath()
global UserValues BurstData BurstMeta
if UserValues.BurstBrowser.Settings.UseFilePathForExport
    path = BurstData{BurstMeta.SelectedFile}.PathName;
else
    path = UserValues.BurstBrowser.PrintPath;
end