clc,clear
% Last updated Sept 25 2019

disp('start time')
datetime

disp('Parallel task')
tic
parfor ii = 1:100
	t = getCurrentTask();
	tid = t.ID;
	a = sin(ii);
	fprintf('From thread = %i, result = %.3f', tid, a)
end
toc

disp('Serial task')
tic
for ii = 1:100
	t = getCurrentTask();
	tid = t.ID;
	a = sin(ii);
	fprintf('From thread = %i, result = %.3f', tid, a)
end
toc


disp('done!')
disp('end time')
datetime
