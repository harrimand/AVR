% Clear all plots while leaving grid lines, x Axis and y Axis lines.

function clearPlots(fig)
    figure(fig);
    h = findobj('type', 'line');
    delete(h(1:length(h)-2));
end
