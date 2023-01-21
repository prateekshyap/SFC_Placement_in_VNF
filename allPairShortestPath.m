function [ apspMat ] = allPairShortestPath( n, mat )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    apspMat = zeros(1,1);
    D0 = mat;
    for r = 1 : n
        for c = 1 : n
            if (D0(r,c) == 0 && r ~= c)
                D0(r,c) = 99999;
            end
        end
    end
    Dk = D0;
    for k = 1 : n
        for  i = 1 : n
            for  j = 1 : n
                if (D0(i,j) < (D0(i,k)+D0(k,j)))
                    Dk(i,j) = D0(i,j);
                else
                    Dk(i,j) = D0(i,k)+D0(k,j);
            end
        end
        D0 = Dk;
    end
    apspMat = Dk;
end