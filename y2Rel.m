function [y2] = y2Rel(VI, FI, r, S, lambda, delta, mu, Xfvi, Xsfi, vnfStatus, sfcClassData, rhoNode, rhoVm, rhoVnf)
	y2 = 0;
	dq = zeros(FI,r);
	dpc = zeros(1,FI);
	lambdaSF = zeros(FI,r);
	deltaSF = zeros(FI,r);
	for s = 1 : S
		usedInstances = sfcClassData(s).usedInstances;
		chainLength = sfcClassData(s).chainLength;
		for iota = 1 : r
			for c = 1 : chainLength
				lambdaSF(usedInstances(c),iota) = lambdaSF(usedInstances(c),iota)+lambda(s,vnfStatus(usedInstances(c)));
				deltaSF(usedInstances(c),iota) = deltaSF(usedInstances(c),iota)+delta(s,vnfStatus(usedInstances(c)));
			end
		end
	end

	for f = 1 : FI
		dpc(f) = 1/mu(vnfStatus(f));
		for iota = 1 : r
			dq(f,iota) = (lambdaSF(f,iota)-deltaSF(f,iota))/mu(vnfStatus(f));
		end
	end

	%% No Failure
	for s = 1 : S
		for f = 1 : FI
			for v = 1 : VI
				y2 = y2 + (dq(f,1)+dpc(f))*Xfvi(f,v,1)*Xsfi(s,f,1);
			end
		end
	end

	%% Failure
	for iota = 2 : r
		for s = 1 : S
			for f = 1 : FI
				for v = 1 : VI
					y2 = y2 + (dq(f,iota)+dpc(f))*Xsfi(s,f,iota)*rhoNode^iota*(1-rhoNode); % Node failure
					y2 = y2 + (dq(f,iota)+dpc(f))*Xsfi(s,f,iota)*rhoVm^iota*(1-rhoVm); % VM failure
					y2 = y2 + (dq(f,iota)+dpc(f))*Xsfi(s,f,iota)*rhoVnf^iota*(1-rhoVnf); % VNF failure
				end
			end
		end
	end
end