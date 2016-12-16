function colormap(name)
%Function for loading colormaps used by Datamaster

%Load colormap
switch name
    case 'warm'
        load('WarmColorMap.mat');
    case 'jet'
        cmap = colormap('jet');
    case 'icopper'
        cmap = flip(colormap('copper'));
    otherwise
        error('Unknown colormap');
end

%Apply Colormap
colormap(gca, cmap);
end

