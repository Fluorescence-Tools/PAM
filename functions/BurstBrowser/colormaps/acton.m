function [cm_data] = acton(m)
if nargin < 1
    m = [];
end

cm = load('ScientificColourMaps6/acton.mat');
cm = cm.acton;

cm_data = cm;
% if nargin < 1
%     cm_data = cm;
% else
%     hsv=rgb2hsv(cm);
%     hsv(170:end,1)=hsv(170:end,1)+1; % hardcoded
%     cm_data=interp1(linspace(0,1,size(cm,1)),hsv,linspace(0,1,m));
%     cm_data(cm_data(:,1)>1,1)=cm_data(cm_data(:,1)>1,1)-1;
%     cm_data=hsv2rgb(cm_data);
% end