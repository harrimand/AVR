% Clear last plot while leaving grid lines, x Axis and y Axis lines.  

function clearLastPlot(fig)
    figure(fig);
    h = findobj('type', 'line');
    if length(h) > 2
        delete(h(1));
    end
end