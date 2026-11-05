function map = CMRmap()
% CMRmap  ShockLab colormap as an [n,3] RGB matrix.
% Reads CMRmap.txt from the same folder as this file, so it works from any
% working directory. Bundled with the shocklab-figures Claude Code plugin.
map = readmatrix(fullfile(fileparts(mfilename('fullpath')), 'CMRmap.txt'));
end
