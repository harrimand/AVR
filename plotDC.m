function plotDC(fig, DC, color)
%Plot a horizontal line where Y = DC
%   Detailed explanation goes here

    figure(fig);
      if nargin == 3
          if ischar(color)
            C = color;
          elseif max(color) > 1
            C = color ./ 255;
          else 
            C = color;
          end
      else
          % C = [128, 96, 16] ./ 255;  %Black
          C = [0, 0, 0] ./ 255;  %Black
      end
    XRange = get(gca, 'XLim');
    plot([XRange(1), XRange(2)], [DC, DC], 'Color', C, 'LineWidth', 2 )
end
