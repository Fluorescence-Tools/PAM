%%% add universal circle to phasor plot
function add_universal_circle(ax,linkerwidth)
global BurstData BurstMeta UserValues
if nargin < 2
    linkerwidth = false;
end
file = BurstMeta.SelectedFile;
x = 0:0.001:1;
y = sqrt(0.5^2-(x-0.5).^2);
axes(ax);hold on;
plot(x,y,'--','LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);

if linkerwidth %%% also add adjusted universal circle in presence of linker fluctuations
    R0 = BurstData{file}.Corrections.FoersterRadius;
    TAC = (BurstData{file}.Phasor.PhasorRange(1)/BurstData{file}.FileInfo.MI_Bins)*BurstData{file}.TACRange*1E9;
    tauD = BurstData{file}.Corrections.DonorLifetime;
    sigma = BurstData{file}.Corrections.LinkerLength;
    if sigma > 0.1
        [g,s] = universal_circle_linker(R0,sigma,tauD,TAC);
        plot(g,s,'--','LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine4);
    end
end