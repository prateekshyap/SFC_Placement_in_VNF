function [newValues, newChildren] = getSortedChildren(c, vmChildren, C, length)
	rank = zeros(1,C);
	copy = c;
	if c(1) <= c(2) && c(1) <= c(3) && c(1) <= c(4)
        rank(1) = 1;
        c(1) = Inf;
    elseif c(2) <= c(1) && c(2) <= c(3) && c(2) <= c(4)
        rank(1) = 2;
        c(2) = Inf;
    elseif c(3) <= c(1) && c(3) <= c(2) && c(3) <= c(4)
        rank(1) = 3;
        c(3) = Inf;
    else
        rank(1) = 4;
        c(4) = Inf;
    end
	if c(1) ~= Inf && c(1) <= c(2) && c(1) <= c(3) && c(1) <= c(4)
        rank(2) = 1;
        c(1) = Inf;
    elseif c(2) ~= Inf && c(2) <= c(1) && c(2) <= c(3) && c(2) <= c(4)
        rank(2) = 2;
        c(2) = Inf;
    elseif c(3) ~= Inf && c(3) <= c(1) && c(3) <= c(2) && c(3) <= c(4)
        rank(2) = 3;
        c(3) = Inf;
    else
        rank(2) = 4;
        c(4) = Inf;
    end
	if c(1) ~= Inf && c(1) <= c(2) && c(1) <= c(3) && c(1) <= c(4)
        rank(3) = 1;
        c(1) = Inf;
    elseif c(2) ~= Inf && c(2) <= c(1) && c(2) <= c(3) && c(2) <= c(4)
        rank(3) = 2;
        c(2) = Inf;
    elseif c(3) ~= Inf && c(3) <= c(1) && c(3) <= c(2) && c(3) <= c(4)
        rank(3) = 3;
        c(3) = Inf;
    else
        rank(3) = 4;
        c(4) = Inf;
    end
    if c(1) ~= Inf && c(1) <= c(2) && c(1) <= c(3) && c(1) <= c(4)
        rank(4) = 1;
    elseif c(2) ~= Inf && c(2) <= c(1) && c(2) <= c(3) && c(2) <= c(4)
        rank(4) = 2;
    elseif c(3) ~= Inf && c(3) <= c(1) && c(3) <= c(2) && c(3) <= c(4)
        rank(4) = 3;
    else
        rank(4) = 4;
    end

    newChildren = vmChildren;
    newValues = c;

    for cin = 1 : C
    	newValues(cin) = copy(rank(cin));
    	for l = 1 : length
    		newChildren(cin,l) = vmChildren(rank(cin),l);
    	end
    end
end