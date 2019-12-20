function [file_n,species_n,subspecies_n,sel] = get_multiselection(h)
%%% get the selection of species list
sel = h.SpeciesList.Tree.getSelectedNodes;
k = 1;
for s = 1:numel(sel)
    switch sel(s).getLevel
        case 0
            % top level was clicked
            % ignore
        case 1
            % file was clicked
            % which one?
            for i = 1:numel(h.SpeciesList.File)
                file(i) = h.SpeciesList.File(i).equals(sel(s));
            end
            file = find(file);

            species_n(k) = 0;
            subspecies_n(k) = 0;
            file_n(k) = file;
            k = k+1;
        case 2
            % species group was clicked
            % which file?
            f = sel(s).getParent;
            for i = 1:numel(h.SpeciesList.File)
                file(i) = h.SpeciesList.File(i).equals(f);
            end
            file = find(file);
            % which one?
            if ~isempty(file)
                for i = 1:numel(h.SpeciesList.Species{file})
                    species(i) = h.SpeciesList.Species{file}(i).equals(sel(s));
                end
                species = find(species);                
            else % sometimes file is empty, catch it here
                file = 1;
                species = 1;                
            end
            species_n(k) = species;
            subspecies_n(k) = 1;
            file_n(k) = file;
            k = k+1;
        case 3
            % subspecies was clicked
            % which parent file?
            f = sel(s).getParent.getParent;
            for i = 1:numel(h.SpeciesList.File)
                file(i) = h.SpeciesList.File(i).equals(f);
            end
            file = find(file);
            % which parent species?
            parent = sel(s).getParent;
            for i = 1:numel(h.SpeciesList.Species{file})
                group(i) = h.SpeciesList.Species{file}(i).equals(parent);
            end
            species = find(group);
            % which subspecies?
            for i = 1:parent.getChildCount
                subspecies(i) = parent.getChildAt(i-1).equals(sel(s));
            end
            subspecies = find(subspecies)+1;

            species_n(k) = species;
            subspecies_n(k) = subspecies;
            file_n(k) = file;
            k = k+1;
    end
end