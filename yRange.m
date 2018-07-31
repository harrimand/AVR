
% Set Y Axis min and max scale on figure(fig) with optional argument for 
% tick spacing.  Optional yStep requires file Dytick.m

function yRange(fig, minY, maxY, yStep)
  figure(fig);
  set(gca, 'ylim', [minY, maxY]);
  if nargin == 4
    Dytick(fig, yStep);
  end
  grid off
  % plot([0, 0], [minY, maxY], 'LineWidth', 2); %Plot line on Y Axis @ 0
end
