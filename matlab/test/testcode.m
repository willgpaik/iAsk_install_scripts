setenv LD_LIBRARY_PATH /usr/lib64:LD_LIBRARY_PATH

parpool('ACI', 40)

parfor ii = 1:100
        t = getCurrentTask();
        tid = t.ID;
        a = sin(ii);
        fprintf('\nTID = %i and result is %.3f', tid, a);
end
disp('done!')


