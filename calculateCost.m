function [y1,y2,y3] = calculateCost(N, VI, F, FI, S, L, medium, sfcClassData, sampleNetwork1Original, nextHop, bandwidths, Cv, Cf, Xvn, Xfv, lambda, delta, mu, Xfvi, Xski, vms, vnfs);
	y1 = 0;
	for n = 1 : N %1 to 6
		for v = 1 : VI %1 to 13
			y1 = y1 + Cv(1,vms(v))*Xvn(v,n);
		end
	end
	for v = 1 : VI %1 to 13
		for f = 1 : FI %1 to 22
			y1 = y1 + Cf(1,vnfs(f))*Xfv(f,v);
		end
	end

	y2 = 0;
	dq = zeros(1,F); %Queueing Delay
	dpc = zeros(1,F); %Processing Delay
	for f = 1 : FI %1 to 22
		lambdaSF = 0;
		deltaSF = 0;
		dpc(1,f) = 1/mu(1,vnfs(f));
		for s = 1 : S %1 to 5
			lambdaSF = lambdaSF+lambda(s,vnfs(f));
			deltaSF = deltaSF+delta(s,vnfs(f));
		end
		dq(1,f) = (lambdaSF-deltaSF)/mu(1,vnfs(f));
	    for v = 1 : VI %1 to 13
            y2 = y2+(dq(1,vnfs(f))+dpc(1,vnfs(f)))*Xfvi(f,v)*Xski(s,f);
	    end
	end

	y3 = 0;
	for s = 1 : S %1 to 5
	    currSfcLength = sfcClassData(1,s).chainLength; %Get the length of sth sfc
	    currUsedLinks = sfcClassData(1,s).usedLinks; %Get the physical nodes used
	    for e = 1 : currSfcLength-1 %For each edge in the SFC
	    	startNode = currUsedLinks(1,e); %Get the source
	    	finalNode = currUsedLinks(1,e+1); %Get the destination
	        while startNode ~= finalNode %Till we reach the destination
	        	uNode = startNode; %current node
	        	vNode = nextHop(startNode,finalNode); %next hop node
	        	y3 = y3+sampleNetwork1Original(uNode,vNode)*medium; %Propagation delay
	        	y3 = y3+L/bandwidths(uNode,vNode); %Transmission delay
	        	startNode = nextHop(startNode,finalNode); %Update the start node
	        end
	    end
	end
end