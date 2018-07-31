
function head = columnLabels(labels, start, colSpace)
%  columnLabels(labels, start, spacing) returns a string of evenly spaced labels
%
%  Author:  Darrell Harriman  harrimand@gmail.com
%
%  labels = cellarray of label names.  Eg: {'Col1' 'Col2' 'Col3'}
%  start = Integer Number of spaces before first label in string.
%  spacing = Number of characters/spaces between the start of each label.
%  labels will be truncated if necessary to allow for a space between labels 
%      where colSpace is less than the length of the label.
%
%  Example:
%  labelNames = {'Col1' 'Column2' 'C3'}
%  labelStr = columnLabels(labelNames, 5, 9);
%  labelStr 
%           => '     Col1     Column2  C3       '
%

  head = blanks(start);
  for c = 1:length(labels)
    strLen = rindex([labels{c} '_'],'_') - 1;
    if (colSpace - strLen > 2);
      head = [head labels{c} blanks(colSpace - strLen)];
    else
      head = [head substr(labels{c}, 1, colSpace - 1) blanks(1)];
    end
  end
  head = deblank(head);  % Remove trailing spaces from string.
  
end
