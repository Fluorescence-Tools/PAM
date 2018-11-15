%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates Corrections in GUI and UserValues  %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateCorrections(obj,e,h)
global UserValues BurstData BurstMeta

if nargin == 2
    if isempty(obj)
        h = guidata(findobj('Tag','BurstBrowser'));
    else
        h = guidata(obj);
    end
end

file = BurstMeta.SelectedFile;
if isempty(obj) %%% Just change the data to what is stored in UserValues
    if isempty(BurstData)
        %%% function was called on GUI startup, default to 2cMFD
        h.CorrectionsTable.Data(:,2) = {UserValues.BurstBrowser.Corrections.Gamma_GR;...
            UserValues.BurstBrowser.Corrections.Beta_GR;...
            UserValues.BurstBrowser.Corrections.CrossTalk_GR;...
            UserValues.BurstBrowser.Corrections.DirectExcitation_GR;...
            UserValues.BurstBrowser.Corrections.GfactorGreen;...
            UserValues.BurstBrowser.Corrections.GfactorRed;...
            UserValues.BurstBrowser.Corrections.l1;...
            UserValues.BurstBrowser.Corrections.l2;...
            UserValues.BurstBrowser.Corrections.Background_GGpar;...
            UserValues.BurstBrowser.Corrections.Background_GGperp;...
            UserValues.BurstBrowser.Corrections.Background_GRpar;...
            UserValues.BurstBrowser.Corrections.Background_GRperp;...
            UserValues.BurstBrowser.Corrections.Background_RRpar;...
            UserValues.BurstBrowser.Corrections.Background_RRperp};
    else
        %%% Catch case where no Background Information is stored in
        %%% BurstData
        if ~isfield(BurstData{file},'Background')
            switch BurstData{file}.BAMethod
                case {1,2}
                    BurstData{file}.Background.Background_GGpar = UserValues.BurstBrowser.Corrections.Background_GGpar;
                    BurstData{file}.Background.Background_GGperp = UserValues.BurstBrowser.Corrections.Background_GGperp;
                    BurstData{file}.Background.Background_GRpar = UserValues.BurstBrowser.Corrections.Background_GRpar;
                    BurstData{file}.Background.Background_GRperp = UserValues.BurstBrowser.Corrections.Background_GRperp;
                    BurstData{file}.Background.Background_RRpar = UserValues.BurstBrowser.Corrections.Background_RRpar;
                    BurstData{file}.Background.Background_RRperp = UserValues.BurstBrowser.Corrections.Background_RRperp;
                case {3,4}
                    BurstData{file}.Background.Background_BBpar = UserValues.BurstBrowser.Corrections.Background_BBpar;
                    BurstData{file}.Background.Background_BBperp = UserValues.BurstBrowser.Corrections.Background_BBperp;
                    BurstData{file}.Background.Background_BGpar = UserValues.BurstBrowser.Corrections.Background_BGpar;
                    BurstData{file}.Background.Background_BGperp = UserValues.BurstBrowser.Corrections.Background_BGperp;
                    BurstData{file}.Background.Background_BRpar = UserValues.BurstBrowser.Corrections.Background_BRpar;
                    BurstData{file}.Background.Background_BRperp = UserValues.BurstBrowser.Corrections.Background_BRperp;
                    BurstData{file}.Background.Background_GGpar = UserValues.BurstBrowser.Corrections.Background_GGpar;
                    BurstData{file}.Background.Background_GGperp = UserValues.BurstBrowser.Corrections.Background_GGperp;
                    BurstData{file}.Background.Background_GRpar = UserValues.BurstBrowser.Corrections.Background_GRpar;
                    BurstData{file}.Background.Background_GRperp = UserValues.BurstBrowser.Corrections.Background_GRperp;
                    BurstData{file}.Background.Background_RRpar = UserValues.BurstBrowser.Corrections.Background_RRpar;
                    BurstData{file}.Background.Background_RRperp = UserValues.BurstBrowser.Corrections.Background_RRperp;
                case {5}
                    BurstData{file}.Background.Background_GG = UserValues.BurstBrowser.Corrections.Background_GGpar;
                    BurstData{file}.Background.Background_GR = UserValues.BurstBrowser.Corrections.Background_GRpar;
                    BurstData{file}.Background.Background_RR = UserValues.BurstBrowser.Corrections.Background_RRpar;
            end
        end
        %%% Backwards Compatibility Check (Remove at some point)
        if ~isstruct(BurstData{file}.Background) % Second check for compatibility of old data (Background was stored in array, not in struct)
            switch BurstData{file}.BAMethod
                case {1,2}
                    Background.Background_GGpar = BurstData{file}.Background(1);
                    Background.Background_GGperp = BurstData{file}.Background(2);
                    Background.Background_GRpar = BurstData{file}.Background(3);
                    Background.Background_GRperp = BurstData{file}.Background(4);
                    Background.Background_RRpar = BurstData{file}.Background(5);
                    Background.Background_RRperp = BurstData{file}.Background(6);
                case {3,4}
                    Background.Background_BBpar = BurstData{file}.Background(1);
                    Background.Background_BBperp = BurstData{file}.Background(2);
                    Background.Background_BGpar = BurstData{file}.Background(3);
                    Background.Background_BGperp = BurstData{file}.Background(4);
                    Background.Background_BRpar = BurstData{file}.Background(5);
                    Background.Background_BRperp = BurstData{file}.Background(6);
                    Background.Background_GGpar = BurstData{file}.Background(7);
                    Background.Background_GGperp = BurstData{file}.Background(8);
                    Background.Background_GRpar = BurstData{file}.Background(9);
                    Background.Background_GRperp = BurstData{file}.Background(10);
                    Background.Background_RRpar = BurstData{file}.Background(11);
                    Background.Background_RRperp = BurstData{file}.Background(12);
            end
            BurstData{file}.Background = Background;
        end
        %%% Set Correction Struct to UserValues. From here on, corrections
        %%% are stored individually per measurement.
        if ~isfield(BurstData{file},'Corrections') || ~isstruct(BurstData{file}.Corrections) % Second check for compatibility of old data
            switch BurstData{file}.BAMethod
                case {1,2,5}
                    BurstData{file}.Corrections.CrossTalk_GR = UserValues.BurstBrowser.Corrections.CrossTalk_GR;
                    BurstData{file}.Corrections.DirectExcitation_GR = UserValues.BurstBrowser.Corrections.DirectExcitation_GR;
                    BurstData{file}.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
                    BurstData{file}.Corrections.Beta_GR = UserValues.BurstBrowser.Corrections.Beta_GR;
                    BurstData{file}.Corrections.GfactorGreen =  UserValues.BurstBrowser.Corrections.GfactorGreen;
                    BurstData{file}.Corrections.GfactorRed = UserValues.BurstBrowser.Corrections.GfactorRed;
                    BurstData{file}.Corrections.DonorLifetime = UserValues.BurstBrowser.Corrections.DonorLifetime;
                    BurstData{file}.Corrections.AcceptorLifetime = UserValues.BurstBrowser.Corrections.AcceptorLifetime;
                    BurstData{file}.Corrections.FoersterRadius = UserValues.BurstBrowser.Corrections.FoersterRadius;
                    BurstData{file}.Corrections.LinkerLength = UserValues.BurstBrowser.Corrections.LinkerLength;
                case {3,4}
                    BurstData{file}.Corrections.CrossTalk_GR = UserValues.BurstBrowser.Corrections.CrossTalk_GR;
                    BurstData{file}.Corrections.CrossTalk_BG = UserValues.BurstBrowser.Corrections.CrossTalk_BG;
                    BurstData{file}.Corrections.CrossTalk_BR = UserValues.BurstBrowser.Corrections.CrossTalk_BR;
                    BurstData{file}.Corrections.DirectExcitation_GR = UserValues.BurstBrowser.Corrections.DirectExcitation_GR;
                    BurstData{file}.Corrections.DirectExcitation_BG = UserValues.BurstBrowser.Corrections.DirectExcitation_BG;
                    BurstData{file}.Corrections.DirectExcitation_BR = UserValues.BurstBrowser.Corrections.DirectExcitation_BR;
                    BurstData{file}.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
                    BurstData{file}.Corrections.Gamma_BG = UserValues.BurstBrowser.Corrections.Gamma_BG;
                    BurstData{file}.Corrections.Gamma_BR = UserValues.BurstBrowser.Corrections.Gamma_BR;
                    BurstData{file}.Corrections.Beta_GR = UserValues.BurstBrowser.Corrections.Beta_GR;
                    BurstData{file}.Corrections.Beta_BG = UserValues.BurstBrowser.Corrections.Beta_BG;
                    BurstData{file}.Corrections.Beta_BR = UserValues.BurstBrowser.Corrections.Beta_BR;
                    BurstData{file}.Corrections.GfactorBlue = UserValues.BurstBrowser.Corrections.GfactorBlue;
                    BurstData{file}.Corrections.GfactorGreen = UserValues.BurstBrowser.Corrections.GfactorGreen;
                    BurstData{file}.Corrections.GfactorRed = UserValues.BurstBrowser.Corrections.GfactorRed;
                    BurstData{file}.Corrections.DonorLifetimeBlue = UserValues.BurstBrowser.Corrections.DonorLifetimeBlue;
                    BurstData{file}.Corrections.DonorLifetime = UserValues.BurstBrowser.Corrections.DonorLifetime;
                    BurstData{file}.Corrections.AcceptorLifetime = UserValues.BurstBrowser.Corrections.AcceptorLifetime;
                    BurstData{file}.Corrections.FoersterRadius = UserValues.BurstBrowser.Corrections.FoersterRadius;
                    BurstData{file}.Corrections.LinkerLength = UserValues.BurstBrowser.Corrections.LinkerLength;
                    BurstData{file}.Corrections.FoersterRadiusBG = UserValues.BurstBrowser.Corrections.FoersterRadiusBG;
                    BurstData{file}.Corrections.LinkerLengthBG = UserValues.BurstBrowser.Corrections.LinkerLengthBG;
                    BurstData{file}.Corrections.FoersterRadiusBR = UserValues.BurstBrowser.Corrections.FoersterRadiusBR;
                    BurstData{file}.Corrections.LinkerLengthBR = UserValues.BurstBrowser.Corrections.LinkerLengthBR;
                    BurstData{file}.Corrections.r0_green = UserValues.BurstBrowser.Corrections.r0_green;
                    BurstData{file}.Corrections.r0_red = UserValues.BurstBrowser.Corrections.r0_red;
                    BurstData{file}.Corrections.r0_blue = UserValues.BurstBrowser.Corrections.r0_blue;
            end
        end
        if ~isfield(BurstData{file}.Corrections,'r0_green')
            BurstData{file}.Corrections.r0_green = UserValues.BurstBrowser.Corrections.r0_green;
        end
        if ~isfield(BurstData{file}.Corrections,'r0_red')
            BurstData{file}.Corrections.r0_red = UserValues.BurstBrowser.Corrections.r0_red;
        end
        if ~isfield(BurstData{file}.Corrections,'r0_blue') && any(BurstData{file}.BAMethod == [3,4])
            BurstData{file}.Corrections.r0_blue = UserValues.BurstBrowser.Corrections.r0_blue;
        end
        %%% Update GUI with values stored in BurstData Structure
        switch BurstData{file}.BAMethod
            case {1,2,5}
                h.DonorLifetimeEdit.String = num2str(BurstData{file}.Corrections.DonorLifetime);
                h.AcceptorLifetimeEdit.String = num2str(BurstData{file}.Corrections.AcceptorLifetime);
                h.FoersterRadiusEdit.String = num2str(BurstData{file}.Corrections.FoersterRadius);
                h.LinkerLengthEdit.String = num2str(BurstData{file}.Corrections.LinkerLength);
                h.r0Green_edit.String = num2str(BurstData{file}.Corrections.r0_green);
                h.r0Red_edit.String = num2str(BurstData{file}.Corrections.r0_red);
            case {3,4}
                h.DonorLifetimeBlueEdit.String = num2str(BurstData{file}.Corrections.DonorLifetimeBlue);
                h.DonorLifetimeEdit.String = num2str(BurstData{file}.Corrections.DonorLifetime);
                h.AcceptorLifetimeEdit.String = num2str(BurstData{file}.Corrections.AcceptorLifetime);
                h.FoersterRadiusEdit.String = num2str(BurstData{file}.Corrections.FoersterRadius);
                h.LinkerLengthEdit.String = num2str(BurstData{file}.Corrections.LinkerLength);
                h.FoersterRadiusBGEdit.String = num2str(BurstData{file}.Corrections.FoersterRadiusBG);
                h.LinkerLengthBGEdit.String = num2str(BurstData{file}.Corrections.LinkerLengthBG);
                h.FoersterRadiusBREdit.String = num2str(BurstData{file}.Corrections.FoersterRadiusBR);
                h.LinkerLengthBREdit.String = num2str(BurstData{file}.Corrections.LinkerLengthBR);
                h.r0Blue_edit.String = num2str(BurstData{file}.Corrections.r0_blue);
                h.r0Green_edit.String = num2str(BurstData{file}.Corrections.r0_green);
                h.r0Red_edit.String = num2str(BurstData{file}.Corrections.r0_red);
        end
        
        if any(BurstData{file}.BAMethod == [1,2,5]) %%% 2cMFD, same as default
            h.CorrectionsTable.Data(:,2) = {BurstData{file}.Corrections.Gamma_GR;...
                BurstData{file}.Corrections.Beta_GR;...
                BurstData{file}.Corrections.CrossTalk_GR;...
                BurstData{file}.Corrections.DirectExcitation_GR;...
                BurstData{file}.Corrections.GfactorGreen;...
                BurstData{file}.Corrections.GfactorRed;...
                UserValues.BurstBrowser.Corrections.l1;...
                UserValues.BurstBrowser.Corrections.l2;...
                BurstData{file}.Background.Background_GGpar;...
                BurstData{file}.Background.Background_GGperp;...
                BurstData{file}.Background.Background_GRpar;...
                BurstData{file}.Background.Background_GRperp;...
                BurstData{file}.Background.Background_RRpar;...
                BurstData{file}.Background.Background_RRperp};
        elseif any(BurstData{file}.BAMethod == [3,4]) %%% 3cMFD
            h.CorrectionsTable.Data(:,2) = {BurstData{file}.Corrections.Gamma_GR;...
                BurstData{file}.Corrections.Gamma_BG;...
                BurstData{file}.Corrections.Gamma_BR;...
                BurstData{file}.Corrections.Beta_GR;...
                BurstData{file}.Corrections.Beta_BG;...
                BurstData{file}.Corrections.Beta_BR;...
                BurstData{file}.Corrections.CrossTalk_GR;...
                BurstData{file}.Corrections.CrossTalk_BG;...
                BurstData{file}.Corrections.CrossTalk_BR;...
                BurstData{file}.Corrections.DirectExcitation_GR;...
                BurstData{file}.Corrections.DirectExcitation_BG;...
                BurstData{file}.Corrections.DirectExcitation_BR;...
                BurstData{file}.Corrections.GfactorBlue;...
                BurstData{file}.Corrections.GfactorGreen;...
                BurstData{file}.Corrections.GfactorRed;...
                UserValues.BurstBrowser.Corrections.l1;...
                UserValues.BurstBrowser.Corrections.l2;...
                BurstData{file}.Background.Background_BBpar;...
                BurstData{file}.Background.Background_BBperp;...
                BurstData{file}.Background.Background_BGpar;...
                BurstData{file}.Background.Background_BGperp;...
                BurstData{file}.Background.Background_BRpar;...
                BurstData{file}.Background.Background_BRperp;...
                BurstData{file}.Background.Background_GGpar;...
                BurstData{file}.Background.Background_GGperp;...
                BurstData{file}.Background.Background_GRpar;...
                BurstData{file}.Background.Background_GRperp;...
                BurstData{file}.Background.Background_RRpar;...
                BurstData{file}.Background.Background_RRperp};
        end
        
    end
else %%% Update UserValues and BurstData with new values
    LSUserValues(0);
    if ~h.MultiselectOnCheckbox.UserData
       files = BurstMeta.SelectedFile;
    else %%% loop over selected files
       files = get_multiselection(h);
       files = unique(files);
    end
    switch obj
        case h.CorrectionsTable
            Data = obj.Data(:,2);
            if isnan(e.NewData)
                %%% revert to old data and don't proceed
                obj.Data{e.Indices(1),e.Indices(2)} = e.PreviousData;
                return;
            end
            h.ApplyCorrectionsButton.ForegroundColor = [1 0 0];
            if any(BurstData{file}.BAMethod == [1,2,5]) %%% 2cMFD
                %%% Update UserValues Structure
                UserValues.BurstBrowser.Corrections.Gamma_GR = Data{1};
                UserValues.BurstBrowser.Corrections.Beta_GR = Data{2};
                UserValues.BurstBrowser.Corrections.CrossTalk_GR = Data{3};
                UserValues.BurstBrowser.Corrections.DirectExcitation_GR= Data{4};
                UserValues.BurstBrowser.Corrections.GfactorGreen = Data{5};
                UserValues.BurstBrowser.Corrections.GfactorRed = Data{6};
                UserValues.BurstBrowser.Corrections.l1 = Data{7};
                UserValues.BurstBrowser.Corrections.l2 = Data{8};
                UserValues.BurstBrowser.Corrections.Background_GGpar= Data{9};
                UserValues.BurstBrowser.Corrections.Background_GGperp= Data{10};
                UserValues.BurstBrowser.Corrections.Background_GRpar= Data{11};
                UserValues.BurstBrowser.Corrections.Background_GRperp= Data{12};
                UserValues.BurstBrowser.Corrections.Background_RRpar= Data{13};
                UserValues.BurstBrowser.Corrections.Background_RRperp= Data{14};
                for file = files
                    switch e.Indices(1)
                        case 1
                            BurstData{file}.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
                        case 2
                            BurstData{file}.Corrections.Beta_GR = UserValues.BurstBrowser.Corrections.Beta_GR;
                        case 3
                            BurstData{file}.Corrections.CrossTalk_GR = UserValues.BurstBrowser.Corrections.CrossTalk_GR;
                        case 4
                            BurstData{file}.Corrections.DirectExcitation_GR = UserValues.BurstBrowser.Corrections.DirectExcitation_GR;
                        case 5
                            BurstData{file}.Corrections.GfactorGreen = UserValues.BurstBrowser.Corrections.GfactorGreen;
                        case 6
                            BurstData{file}.Corrections.GfactorRed = UserValues.BurstBrowser.Corrections.GfactorRed;
                        case 7
                            
                        case 8
                            
                        case 9
                            BurstData{file}.Background.Background_GGpar = UserValues.BurstBrowser.Corrections.Background_GGpar;
                        case 10
                            BurstData{file}.Background.Background_GGperp = UserValues.BurstBrowser.Corrections.Background_GGperp;
                        case 11
                            BurstData{file}.Background.Background_GRpar = UserValues.BurstBrowser.Corrections.Background_GRpar;
                        case 12
                            BurstData{file}.Background.Background_GRperp = UserValues.BurstBrowser.Corrections.Background_GRperp;
                        case 13
                            BurstData{file}.Background.Background_RRpar = UserValues.BurstBrowser.Corrections.Background_RRpar;
                        case 14
                            BurstData{file}.Background.Background_RRperp = UserValues.BurstBrowser.Corrections.Background_RRperp;
                    end
                end
                if ~strcmp(h.Corrections.TwoCMFD.axes_crosstalk.Title.String,'Lifetime of Donor only')
                    %%% only execute when axis is not used for lifetime plot
                    switch e.Indices(1)
                        case 3 %%% crosstalk was changed, update the Gauss fit plot
                            crosstalk_new = e.NewData;
%                             mean_new = crosstalk_new/(crosstalk_new+1);
%                             if BurstMeta.Plots.histE_donly.YData == 1
%                                 % correction histograms don't exist yet
%                                 DetermineCorrections(h.DetermineCorrectionsButton,[]); 
%                             end
%                             obj.Data{e.Indices(1),2} = crosstalk_new; %update the value in the table
%                             [~, GaussFun] = GaussianFit(BurstMeta.Plots.histE_donly.XData',...
%                                                         BurstMeta.Plots.histE_donly.YData',...
%                                                         mean_new); %create the new red line
%                             BurstMeta.Plots.Fits.histE_donly(1).YData = GaussFun;
                            UserValues.BurstBrowser.Corrections.CrossTalk_GR = crosstalk_new;
                            BurstData{file}.Corrections.CrossTalk_GR = crosstalk_new;
                        case 4 %%% direct exc. was changed, update the Gauss fit plot
                            directexc_new = e.NewData;
%                             mean_new = directexc_new/(directexc_new+1);
%                             if BurstMeta.Plots.histS_aonly.YData == 1
%                                 % correction histograms don't exist yet
%                                 DetermineCorrections(h.DetermineCorrectionsButton,[]); %generate the directexc histogram if it isn't there already
%                             end
%                             obj.Data{e.Indices(1),2} = directexc_new; %update the value in the table
%                             [~, GaussFun] = GaussianFit(BurstMeta.Plots.histS_aonly.XData',...
%                                                         BurstMeta.Plots.histS_aonly.YData',...
%                                                         mean_new); %create the new red line
%                             BurstMeta.Plots.Fits.histS_aonly(1).YData = GaussFun;
                            UserValues.BurstBrowser.Corrections.DirectExcitation_GR = directexc_new;
                            BurstData{file}.Corrections.DirectExcitation_GR = directexc_new;
                    end
                end
            elseif any(BurstData{file}.BAMethod == [3,4]) %%% 3cMFD
                %%% first update the gamma values!
                %%% gamma_br = gamma_bg*gamma_gr
                switch e.Indices(1)
                    case 1 %%% gamma GR was changed
                        %%% hold gamma BR constant, but change gamma BG
                        %%% (gamma BG is not really used directly in the code)
                        Data{2} = Data{3}/Data{1};
                        obj.Data{2,2} = Data{2};
                    case 2 %%% gamma BG was changed, update gamma BR
                        Data{3} = Data{2}*Data{1};
                        obj.Data{3,2} = Data{3};
                    case 3 %%% gamma BR was changed, update gamma BG
                        Data{2} = Data{3}/Data{1};
                        obj.Data{2,2} = Data{2};
                end
                %%% Update UserValues
                UserValues.BurstBrowser.Corrections.Gamma_GR = Data{1};
                UserValues.BurstBrowser.Corrections.Gamma_BG = Data{2};
                UserValues.BurstBrowser.Corrections.Gamma_BR = Data{3};
                UserValues.BurstBrowser.Corrections.Beta_GR = Data{4};
                UserValues.BurstBrowser.Corrections.Beta_BG = Data{5};
                UserValues.BurstBrowser.Corrections.Beta_BR = Data{6};
                UserValues.BurstBrowser.Corrections.CrossTalk_GR = Data{7};
                UserValues.BurstBrowser.Corrections.CrossTalk_BG = Data{8};
                UserValues.BurstBrowser.Corrections.CrossTalk_BR = Data{9};
                UserValues.BurstBrowser.Corrections.DirectExcitation_GR= Data{10};
                UserValues.BurstBrowser.Corrections.DirectExcitation_BG= Data{11};
                UserValues.BurstBrowser.Corrections.DirectExcitation_BR= Data{12};
                UserValues.BurstBrowser.Corrections.GfactorBlue = Data{13};
                UserValues.BurstBrowser.Corrections.GfactorGreen = Data{14};
                UserValues.BurstBrowser.Corrections.GfactorRed = Data{15};
                UserValues.BurstBrowser.Corrections.l1 = Data{16};
                UserValues.BurstBrowser.Corrections.l2 = Data{17};
                UserValues.BurstBrowser.Corrections.Background_BBpar= Data{18};
                UserValues.BurstBrowser.Corrections.Background_BBperp= Data{19};
                UserValues.BurstBrowser.Corrections.Background_BGpar= Data{20};
                UserValues.BurstBrowser.Corrections.Background_BGperp= Data{21};
                UserValues.BurstBrowser.Corrections.Background_BRpar= Data{22};
                UserValues.BurstBrowser.Corrections.Background_BRperp= Data{23};
                UserValues.BurstBrowser.Corrections.Background_GGpar= Data{24};
                UserValues.BurstBrowser.Corrections.Background_GGperp= Data{25};
                UserValues.BurstBrowser.Corrections.Background_GRpar= Data{26};
                UserValues.BurstBrowser.Corrections.Background_GRperp= Data{27};
                UserValues.BurstBrowser.Corrections.Background_RRpar= Data{28};                
                UserValues.BurstBrowser.Corrections.Background_RRperp= Data{29};
                for file = files
                    switch e.Indices(1)
                        case 1
                            BurstData{file}.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
                        case {2,3} %%% Update both gamma_BG and gamma_BR if either one is changed
                            BurstData{file}.Corrections.Gamma_BG = UserValues.BurstBrowser.Corrections.Gamma_BG;
                            BurstData{file}.Corrections.Gamma_BR = UserValues.BurstBrowser.Corrections.Gamma_BR;
                        case 4
                            BurstData{file}.Corrections.Beta_GR = UserValues.BurstBrowser.Corrections.Beta_GR;
                        case 5
                            BurstData{file}.Corrections.Beta_BG = UserValues.BurstBrowser.Corrections.Beta_BG;
                        case 6
                            BurstData{file}.Corrections.Beta_BR = UserValues.BurstBrowser.Corrections.Beta_BR;
                        case 7
                            BurstData{file}.Corrections.CrossTalk_GR = UserValues.BurstBrowser.Corrections.CrossTalk_GR;
                        case 8
                            BurstData{file}.Corrections.CrossTalk_BG = UserValues.BurstBrowser.Corrections.CrossTalk_BG;
                        case 9
                            BurstData{file}.Corrections.CrossTalk_BR = UserValues.BurstBrowser.Corrections.CrossTalk_BR;
                        case 10
                            BurstData{file}.Corrections.DirectExcitation_GR = UserValues.BurstBrowser.Corrections.DirectExcitation_GR;
                        case 11
                            BurstData{file}.Corrections.DirectExcitation_BG = UserValues.BurstBrowser.Corrections.DirectExcitation_BG;
                        case 12
                            BurstData{file}.Corrections.DirectExcitation_BR = UserValues.BurstBrowser.Corrections.DirectExcitation_BR;
                        case 13
                            BurstData{file}.Corrections.GfactorBlue = UserValues.BurstBrowser.Corrections.GfactorBlue;
                        case 14
                            BurstData{file}.Corrections.GfactorGreen = UserValues.BurstBrowser.Corrections.GfactorGreen;
                        case 15
                            BurstData{file}.Corrections.GfactorRed = UserValues.BurstBrowser.Corrections.GfactorRed;
                        case 16
                            
                        case 17
                            
                        case 18
                            BurstData{file}.Background.Background_BBpar = UserValues.BurstBrowser.Corrections.Background_BBpar;
                        case 19
                            BurstData{file}.Background.Background_BBperp = UserValues.BurstBrowser.Corrections.Background_BBperp;
                        case 20
                            BurstData{file}.Background.Background_BGpar = UserValues.BurstBrowser.Corrections.Background_BGpar;
                        case 21
                            BurstData{file}.Background.Background_BGperp = UserValues.BurstBrowser.Corrections.Background_BGperp;
                        case 22
                            BurstData{file}.Background.Background_BRpar = UserValues.BurstBrowser.Corrections.Background_BRpar;
                        case 23
                            BurstData{file}.Background.Background_BRperp = UserValues.BurstBrowser.Corrections.Background_BRperp;
                        case 24
                            BurstData{file}.Background.Background_GGpar = UserValues.BurstBrowser.Corrections.Background_GGpar;
                        case 25
                            BurstData{file}.Background.Background_GGperp = UserValues.BurstBrowser.Corrections.Background_GGperp;
                        case 26
                            BurstData{file}.Background.Background_GRpar = UserValues.BurstBrowser.Corrections.Background_GRpar;
                        case 27
                            BurstData{file}.Background.Background_GRperp = UserValues.BurstBrowser.Corrections.Background_GRperp;
                        case 28
                            BurstData{file}.Background.Background_RRpar = UserValues.BurstBrowser.Corrections.Background_RRpar;
                        case 29
                            BurstData{file}.Background.Background_RRperp = UserValues.BurstBrowser.Corrections.Background_RRperp;
                    end
                end
                switch e.Indices(1)
                    case {7:12} 
                        %msgbox('anders, if you"re interested in having the red plots being updated when you change this value, see the two color code or let me know! xxx Jelle')
                end
            end
        case h.DonorLifetimeEdit
            if ~isnan(str2double(h.DonorLifetimeEdit.String))
                UserValues.BurstBrowser.Corrections.DonorLifetime = str2double(h.DonorLifetimeEdit.String);
                for file = files
                    BurstData{file}.Corrections.DonorLifetime = UserValues.BurstBrowser.Corrections.DonorLifetime;
                end
            else %%% Reset value
                h.DonorLifetimeEdit.String = num2str(UserValues.BurstBrowser.Corrections.DonorLifetime);
            end
            UpdateLifetimePlots([],[],h);
            PlotLifetimeInd([],[],h);
            ApplyCorrections([],[],h);
        case h.AcceptorLifetimeEdit
            if ~isnan(str2double(h.AcceptorLifetimeEdit.String))
                UserValues.BurstBrowser.Corrections.AcceptorLifetime = str2double(h.AcceptorLifetimeEdit.String);
                for file = files
                    BurstData{file}.Corrections.AcceptorLifetime = UserValues.BurstBrowser.Corrections.AcceptorLifetime;
                end
            else %%% Reset value
                h.AcceptorLifetimeEdit.String = num2str(UserValues.BurstBrowser.Corrections.AcceptorLifetime);
            end
            UpdateLifetimePlots([],[],h);
            PlotLifetimeInd([],[],h);
        case h.DonorLifetimeBlueEdit
            if ~isnan(str2double(h.DonorLifetimeBlueEdit.String))
                UserValues.BurstBrowser.Corrections.DonorLifetimeBlue = str2double(h.DonorLifetimeBlueEdit.String);
                for file = files
                    BurstData{file}.Corrections.DonorLifetimeBlue = UserValues.BurstBrowser.Corrections.DonorLifetimeBlue;
                end
            else %%% Reset value
                h.DonorLifetimeBlueEdit.String = num2str(UserValues.BurstBrowser.Corrections.DonorLifetimeBlue);
            end
            UpdateLifetimePlots([],[],h);
            PlotLifetimeInd([],[],h);
            ApplyCorrections([],[],h);
        case h.FoersterRadiusEdit
            if ~isnan(str2double(h.FoersterRadiusEdit.String))
                UserValues.BurstBrowser.Corrections.FoersterRadius = str2double(h.FoersterRadiusEdit.String);
                for file = files
                    BurstData{file}.Corrections.FoersterRadius = UserValues.BurstBrowser.Corrections.FoersterRadius;
                end
            else %%% Reset value
                h.FoersterRadiusEdit.String = num2str(UserValues.BurstBrowser.Corrections.FoersterRadius);
            end
            UpdateLifetimePlots([],[],h);
            PlotLifetimeInd([],[],h);
            ApplyCorrections([],[],h);
        case h.LinkerLengthEdit
            if ~isnan(str2double(h.LinkerLengthEdit.String))
                UserValues.BurstBrowser.Corrections.LinkerLength = str2double(h.LinkerLengthEdit.String);
                for file = files
                    BurstData{file}.Corrections.LinkerLength = UserValues.BurstBrowser.Corrections.LinkerLength;
                end
            else %%% Reset value
                h.LinkerLengthEdit.String = num2str(UserValues.BurstBrowser.Corrections.LinkerLength);
            end
            UpdateLifetimePlots([],[],h);
            PlotLifetimeInd([],[],h);
        case h.FoersterRadiusBGEdit
            if ~isnan(str2double(h.FoersterRadiusBGEdit.String))
                UserValues.BurstBrowser.Corrections.FoersterRadiusBG = str2double(h.FoersterRadiusBGEdit.String);
                for file = files
                    BurstData{file}.Corrections.FoersterRadiusBG = UserValues.BurstBrowser.Corrections.FoersterRadiusBG;
                end
            else %%% Reset value
                h.FoersterRadiusBGEdit.String = num2str(UserValues.BurstBrowser.Corrections.FoersterRadiusBG);
            end
            UpdateLifetimePlots([],[],h);
            PlotLifetimeInd([],[],h);
            ApplyCorrections([],[],h);
        case h.LinkerLengthBGEdit
            if ~isnan(str2double(h.LinkerLengthBGEdit.String))
                UserValues.BurstBrowser.Corrections.LinkerLengthBG = str2double(h.LinkerLengthBGEdit.String);
                for file = files
                    BurstData{file}.Corrections.LinkerLengthBG = UserValues.BurstBrowser.Corrections.LinkerLengthBG;
                end
            else %%% Reset value
                h.LinkerLengthBGEdit.String = num2str(UserValues.BurstBrowser.Corrections.LinkerLengthBG);
            end
            UpdateLifetimePlots([],[],h);
            PlotLifetimeInd([],[],h);
        case h.FoersterRadiusBREdit
            if ~isnan(str2double(h.FoersterRadiusBREdit.String))
                UserValues.BurstBrowser.Corrections.FoersterRadiusBR = str2double(h.FoersterRadiusBREdit.String);
                for file = files
                    BurstData{file}.Corrections.FoersterRadiusBR = UserValues.BurstBrowser.Corrections.FoersterRadiusBR;
                end
            else %%% Reset value
                h.FoersterRadiusBREdit.String = num2str(UserValues.BurstBrowser.Corrections.FoersterRadiusBR);
            end
            UpdateLifetimePlots([],[],h);
            PlotLifetimeInd([],[],h);
            ApplyCorrections([],[],h);
        case h.LinkerLengthBREdit
            if ~isnan(str2double(h.LinkerLengthBREdit.String))
                UserValues.BurstBrowser.Corrections.LinkerLengthBR = str2double(h.LinkerLengthBREdit.String);
                for file = files
                    BurstData{file}.Corrections.LinkerLengthBR = UserValues.BurstBrowser.Corrections.LinkerLengthBR;
                end
            else %%% Reset value
                h.LinkerLengthBREdit.String = num2str(UserValues.BurstBrowser.Corrections.LinkerLengthBR);
            end
            UpdateLifetimePlots([],[],h);
            PlotLifetimeInd([],[],h);
        case h.r0Green_edit
            if ~isnan(str2double(h.r0Green_edit.String))
                UserValues.BurstBrowser.Corrections.r0_green = str2double(h.r0Green_edit.String);
                for file = files
                    BurstData{file}.Corrections.r0_green = UserValues.BurstBrowser.Corrections.r0_green;
                end
            else %%% Reset value
                h.r0Green_edit.String = num2str(UserValues.BurstBrowser.Corrections.r0_green);
            end
        case h.r0Red_edit
            if ~isnan(str2double(h.r0Red_edit.String))
                UserValues.BurstBrowser.Corrections.r0_red = str2double(h.r0Red_edit.String);
                for file = files
                    BurstData{file}.Corrections.r0_red = UserValues.BurstBrowser.Corrections.r0_red;
                end
            else %%% Reset value
                h.r0Red_edit.String = num2str(UserValues.BurstBrowser.Corrections.r0_red);
            end
        case h.r0Blue_edit
            if ~isnan(str2double(h.r0Blue_edit.String))
                UserValues.BurstBrowser.Corrections.r0_blue = str2double(h.r0Blue_edit.String);
                for file = files
                    BurstData{file}.Corrections.r0_blue = UserValues.BurstBrowser.Corrections.r0_blue;
                end
            else %%% Reset value
                h.r0Blue_edit.String = num2str(UserValues.BurstBrowser.Corrections.r0_blue);
            end
    end  
    LSUserValues(1);
end