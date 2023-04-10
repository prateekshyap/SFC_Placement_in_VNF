function [y3] = y3Rel(N, FI, L, r, S, medium, network, bandwidths, Xllvi, rhoNode, rhoVm, rhoVnf)
	y3 = 0;

	%% No Failure
	for s = 1 : S
		for f1 = 1 : FI
			for f2 = 1 : FI
				for n1 = 1 : N
					for n2 = n1+1 : N
                        if network(n1,n2) ~= 0
						    y3 = y3 + ((network(n1,n2)*medium)+L/bandwidths(n1,n2))*Xllvi(s,f1,f2,n1,n2,1);
                        end
					end
				end
			end
		end
	end

	%% Failure
	for iota = 2 : r
		for s = 1 : S
			for f1 = 1 : FI
				for f2 = 1 : FI
					for n1 = 1 : N
						for n2 = n1+1: N
                            if network(n1,n2) ~= 0
							    y3 = y3 + ((network(n1,n2)*medium)+L/bandwidths(n1,n2))*Xllvi(s,f1,f2,n1,n2,iota)*rhoNode^iota*(1-rhoNode);
							    y3 = y3 + ((network(n1,n2)*medium)+L/bandwidths(n1,n2))*Xllvi(s,f1,f2,n1,n2,iota)*rhoVm^iota*(1-rhoVm);
							    y3 = y3 + ((network(n1,n2)*medium)+L/bandwidths(n1,n2))*Xllvi(s,f1,f2,n1,n2,iota)*rhoVnf^iota*(1-rhoVnf);
                            end
						end
					end
				end
			end
		end
	end
end