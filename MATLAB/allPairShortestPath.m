function [ apspMat, nextHop ] = allPairShortestPath( n, mat )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    apspMat = zeros(1,1);
    D0 = mat;
    % dimension = size(mat);
    nextHop = zeros(n,n);
    for r = 1 : n
        for c = 1 : n
            if (D0(r,c) == 0 && r ~= c)
                D0(r,c) = 99999;
            end
        end
    end
    for r = 1 : n
        for c = 1 : n
            if (D0(r,c) == 99999)
                nextHop(r,c) = -1;
            else
                nextHop(r,c) = c;
            end
        end
    end
    Dk = D0;
    for k = 1 : n
        for  i = 1 : n
            for  j = 1 : n
                if (D0(i,k) == 99999 || D0(k,j) == 99999)
                    continue;
                end
                if (D0(i,j) > (D0(i,k)+D0(k,j)))
                    D0(i,j) = D0(i,k)+D0(k,j);
                    nextHop(i,j) = nextHop(i,k);
                end    
            end
        end
    end
    apspMat = D0;
end