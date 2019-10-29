% generates doge meme
figure('Color',[1,1,1],'Position',get(0,'screensize'),'Toolbar','none','MenuBar','none');
spy;
set(gca,'Color','none','Xcolor','none','YColor','none');

% generate text
xrange = [-50,150];
yrange = [0,140];
drange = [-90,90];
txt = {'Wow','Such data','Much science','Many statistics'};
xval = xrange(1) + diff(xrange)*rand(numel(txt),1);
yval = yrange(1) + diff(yrange)*rand(numel(txt),1);
t = text(xval,yval,txt,'FontSize',48);

for i = 1:numel(t)
    t(i).Rotation = normrnd(0,30);
end