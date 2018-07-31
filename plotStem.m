%Plot stem on figure = fig from (x, 0) to point (x, y) with optional 
% color argument specified as short name 'r' = red, 'b' = blue, 'c' = cyan
% 'g' = green, 'y' = yellow, 'k' = black, 'w' = white or custom color may be
% normalized [R, G, B] where R, G and B are values between 0 and 1 or 
% 8 bit RGB where R, G and B are values between 0 and 255.

function plotStem(fig, x, y, color)
  figure(fig);
  if nargin == 4
    if ischar(color)
      C = color;
    elseif max(color) > 1
      C = color ./ 255;
    else 
      C = color;
    end
  else
      C = [.7, .2, .5];  %Bright Red
  end
  plot([x, x], [0, y], 'Color', C, 'Linestyle', ':', 'LineWidth', 4);
end
