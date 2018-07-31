
% Set X Axis min and max scale on figure(fig) with optional argument for 
% tick spacing.  Optional xStep requires file Dxtick.m

function xRange(fig, minX, maxX, xStep)
  figure(fig);
  set(gca, 'xlim', [minX, maxX]);
  if nargin == 4
    Dxtick(fig, xStep);
  end
  % plot([minX, maxX], [0, 0], 'LineWidth', 2); %Plot line on X Axis @ 0
end
