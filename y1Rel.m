function [y1] = y1Rel(N, VI, FI, Cvn, Xvn, Cfv, Xfvi, vms, vnfs)
	y1 = 0;
	for n = 1 : N
		for v = 1 : VI
			y1 = y1 + Cvn(1,vms(v))*Xvn(v,n);
		end
	end
	for v = 1 : VI
		for f = 1 : FI
			y1 = y1 + Cfv(1,vnfs(f))*Xfvi(f,v,1);
		end
	end
end