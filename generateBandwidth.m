function [bandwidth] = generateBandwidth(network,n,range)

	bandwidth = zeros(n,n);
	for r = 1 : n
		for c = r+1 : n
			if (network(r,c) ~= 0)
				randomBandwidth = (range(2)-range(1)).*rand(1,1) + range(1);
				bandwidth(r,c) = randomBandwidth;
				bandwidth(c,r) = randomBandwidth;
			end
		end
	end

end