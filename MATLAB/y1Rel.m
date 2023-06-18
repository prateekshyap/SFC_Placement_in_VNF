function [y1] = y1Rel(N, VI, FI, Cvn, Xvn, Cfv, Xfvi, vms, vnfs, isFinal)
    y1 = 0;
	for n = 1 : N
		for v = 1 : VI
			y1 = y1 + Cvn(vms(v))*Xvn(v,n);
		end
    end
	for v = 1 : VI
		for f = 1 : FI
			y1 = y1 + Cfv(vms(v),vnfs(f))*Xfvi(f,v,1);
		end
	end
end