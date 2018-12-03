% Updates GUI elements
function UpdateBVATab(obj,~)
h = guidata(obj);

if obj == h.KineticRates_table
   %%% if diagonal elements were clicked, reset them to NaN to indicate
   %%% that they are not used
   h.KineticRates_table.Data(1,1) = {NaN};
   h.KineticRates_table.Data(2,2) = {NaN};
   h.KineticRates_table.Data(3,3) = {NaN};
end