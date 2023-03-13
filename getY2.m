function [y2] = getY2(VI, F, FI, S, lambda, delta, mu, Xfvi, Xski, vnfs)
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
end