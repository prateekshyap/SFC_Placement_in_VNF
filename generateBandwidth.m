function [bandwidth] = generateBandwidth(network,n)

	bandwidth = zeros(n,n);
	for r = 1 : n
		for c = r+1 : n
			if (network(r,c) ~= 0)
				bandwidth(r,c) = round(network(r,c)/10)*10;
				bandwidth(c,r) = round(network(c,r)/10)*10;
			end
		end
	end

end