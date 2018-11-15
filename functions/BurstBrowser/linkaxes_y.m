
function linkaxes_y(~,obj)
h = guidata(obj.AffectedObject);
switch obj.AffectedObject
    case h.axes_general
        %%% update XLim of 1d y axis
        if any(h.axes_general.YLim ~= h.axes_1d_y.XLim)
            h.axes_1d_y.XLim = h.axes_general.YLim;
        end
    case h.axes_1d_y
        %%% update YLim of 2d axis
        if any(h.axes_general.YLim ~= h.axes_1d_y.XLim)
            h.axes_general.YLim = h.axes_1d_y.XLim;
        end
end