function [y1] = getY1(N, VI, FI, Cvn, Xvn, Cfv, Xfv, vms, vnfs)
	y1 = 0;
	for n = 1 : N %1 to 6
		for v = 1 : VI %1 to 13
			y1 = y1 + Cvn(1,vms(v))*Xvn(v,n);
		end
    end
	for v = 1 : VI %1 to 13
		for f = 1 : FI %1 to 22
            if (vnfs(f) == 0) continue; end
			y1 = y1 + Cfv(1,vnfs(f))*Xfv(f,v);
		end
	end
end