function plot_to_txt(ax,mode)
% reads relevant data from axes and saves in CSV or copies to clipboard
%
% :param ax: input axes
% :param mode: 0 saves to txt, 1 copies to clipboard
plot_name = ax.Title.String;
%% throw out everything that is not a line plot
child = ax.Children;
valid = zeros(numel(child),1);
for i = 1:numel(child)
    if strcmp(child(i).Type,'line')
        valid(i) = 1;
    end
end
child = child(logical(valid));
%% loop over children and extract data
for i = 1:numel(child)
        xdat{1+numel(child)-i} = child(i).XData; % reverse direction for correct plotting order
        ydat{1+numel(child)-i} = child(i).YData;
        name{1+numel(child)-i} = child(i).DisplayName;
end

%% convert to matrix
L = cellfun(@numel,xdat);
maxL = max(L);
DataMat = zeros(maxL,2*numel(xdat));
for i = 1:numel(xdat)
    DataMat(1:L(i),2*i-1) = xdat{i};
    DataMat(1:L(i),2*i) = ydat{i};
end

switch mode
    case 0
        %% write data to csv file
        [filename, pathname, FilterIndex] = uiputfile('*.txt','Save *.txt file');
        if FilterIndex == 0
            return;
        end

        fid = fopen(fullfile(pathname,filename),'w');
        %%% write axes name
        fprintf(fid,'Axes name: %s\n',plot_name);
        %%% write plot names
        fprintf(fid,'%s\n','Plot names:');
        for i = 1:numel(name)
            fprintf(fid,'Plot %i: %s\n',i,name{i});
        end
        %%% write data header
        str = [];
        if numel(name) == 1
            str = sprintf('%s\t%s\t','x','y');
        else
            for i = 1:numel(name)
                str = [str, sprintf('%s\t%s\t',['x' num2str(i)],['y' num2str(i)])];
            end
        end

        fprintf(fid,'%s\n',str);

        %% write data
        len = cellfun(@numel,xdat);
        for i = 1:size(DataMat,1)
            %%% convert row to str
            str = [];
            for j = 1:size(DataMat,2)
                if (i > len(ceil(j/2)))
                    %%% no data should be printed when  the length is exceed
                    % this is to ensure that different length plots can be exported
                    str = [str, sprintf('%s\t','')];
                else
                    str = [str, sprintf('%f\t',DataMat(i,j))];
                end
            end
            %%% write line
            fprintf(fid,'%s\n',str);
        end
    case 1
        Names = cell(1,2*numel(name));
        columns = cell(1,2*numel(name));
        for i = 1:numel(name)
            Names{2*i-1} = name{i};
            columns{2*i-1} = 'x';
            columns{2*i} = 'y';
        end
        % copy to clipboard
        Export = [Names; columns; num2cell(DataMat)];
        Mat2clip(Export);
        %%% Also make it visible in workspace
        assignin('base','DataExport',DataMat);
end