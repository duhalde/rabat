function M = rbtAlignedMatrix(a,b)

    [C, lags] = xcorr(a,b);

    [~, ind] = max(C);

    lag = lags(ind);

    if lag < 0
        b = b(abs(lag)+1:end);
    elseif lag > 0
        b = [zeros(1, lag) b];
    end

    M = [a; b(1:length(a))];
    
end