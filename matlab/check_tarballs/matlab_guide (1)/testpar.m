parfor ii = 1:100
%    %  disp(ii)
	t = getCurrentTask();
	tid = t.ID;
	a = sin(ii);
	fprintf('From thread = %i, result = %.3f', tid, a)
end
% 
disp('done!')



