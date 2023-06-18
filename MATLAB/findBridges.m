function [bridgeStatus] = findBridges(N, inputNetwork)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
	global discovery;
	global low;
	global visited;
	global isBridge;
    global time;

	isBridge = zeros(N,N);
	discovery = zeros(1,N);
	low = zeros(1,N);
	visited = zeros(1,N);
	time = 1;

	for i = 1 : N
		if visited(i) == 0
			dfs(N, inputNetwork, i, -1);
		end
	end

	bridgeStatus = isBridge;
end

function [] = dfs(N, inputNetwork, src, par)
    global discovery;
	global low;
	global visited;
	global isBridge;
    global time;

	visited(src) = 1;
	discovery(src) = time;
    low(src) = time;
	time = time+1;

	for adj = 1 : N
		if inputNetwork(src,adj) ~= 0
			if visited(adj) == 0
				dfs(N, inputNetwork, adj, src);
				low(src) = min(low(src),low(adj));
			elseif par ~= adj
				low(src)= min(low(src),discovery(adj));
			end
			if low(adj) > discovery(src)
				isBridge(src,adj) = 1;
				isBridge(adj,src) = 1;
			end
		end
	end
end