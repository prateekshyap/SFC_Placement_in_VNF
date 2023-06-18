function [ shortestPaths ] = bellmanFord( n, mat, src )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%creating the array for storing the shortest path values
shortestPaths = zeros (1,n);
for x = 1 : n
	if (x ~= src)
		shortestPaths (x) = 999; %updating all the vertices except the source to a larger value
    end
end
for i = 1 : n-1 %iterations
	for j = 1 : n
		for k = 1 : n
            %relaxing the edge
            if (mat (j,k) == 0)
					continue;
			elseif (shortestPaths (k) > shortestPaths (j) + mat (j,k))
					shortestPaths (k) = shortestPaths (j) + mat (j,k);
			end
		end
	end
end
flag = 0;

%checking for presence of negative weight edges (not required for network
%graphs)
for j = 1 : n
	for k = 1 : n
		if ((shortestPaths (k) > shortestPaths (j) + mat (j,k)) && (mat (j,k) ~= 0)) %then negative weight edge exists
			shortestPaths = false;
            flag = 1;
            break;
        end
    end
    if (flag == 1)
        break;
    end
end
end