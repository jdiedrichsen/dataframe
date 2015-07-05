function progress_bar(iter)
% Progressbar for the command prompt
    if rem(iter,10) == 0
        fprintf(1, '%d', iter);
        if rem(iter, 100) == 0
            fprintf(1, '\n');
        end;
    else
        fprintf(1, '.');
    end;
