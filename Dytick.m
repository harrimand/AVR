% Set Y axis tick spacing.
% integer fig = figure number (Plot Window Number)
% tickSize = tick spacing from 0 (- .. 0 .. +)

function Dytick(fig, tickSize)
  figure(fig);
  yRange = get(gca, 'ylim');
  yMin = yRange(1);
  yMax = yRange(2);
 
  yTick = yMin+mod(abs(yMin),tickSize):tickSize:yMax-mod(abs(yMax),tickSize);
  
  set(gca, 'ytick', []);
  set(gca, 'YMinorGrid', 'off');
  
  set(gca, 'ytick', yTick);
  set(gca, 'YMinorGrid', 'off');
  end
  