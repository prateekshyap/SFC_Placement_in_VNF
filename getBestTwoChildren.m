function [i1, i2] = getBestTwoChildren(c)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    i1 = 0;
    i2 = 0;
    if c(1) < c(2) && c(1) < c(3) && c(1) < c(4)
        i1 = 1;
        c(1) = Inf;
    elseif c(2) < c(1) && c(2) < c(3) && c(2) < c(4)
        i1 = 2;
        c(2) = Inf;
    elseif c(3) < c(1) && c(3) < c(2) && c(3) < c(4)
        i1 = 3;
        c(3) = Inf;
    else
        i1 = 4;
        c(4) = Inf;
    end
    if c(1) < c(2) && c(1) < c(3) && c(1) < c(4)
        i2 = 1;
    elseif c(2) < c(1) && c(2) < c(3) && c(2) < c(4)
        i2 = 2;
    elseif c(3) < c(1) && c(3) < c(2) && c(3) < c(4)
        i2 = 3;
    else
        i2 = 4;
    end
end