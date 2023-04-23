function [y3] = y3Rel(N, FI, L, r, S, medium, network, nextHop, bandwidths, rhoNode, rhoVm, rhoVnf, sfcClassData, isFinal)
    global y3Yet;

	y3 = 0;

    %{
    % This block is the alternative code for calculating y3 but takes forever to finish -_-
	%% No Failure
	for s = S : S
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
		for s = S : S
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
    %}

    %% No Failure
    for s = 1 : S %1 to 5
	    currSfcLength = sfcClassData(s).chainLength; %Get the length of sth sfc
	    currUsedLinks = sfcClassData(s).usedLinks(:,1); %Get the physical nodes used
	    for e = 1 : currSfcLength-1 %For each edge in the SFC
	    	startNode = currUsedLinks(e); %Get the source
	    	finalNode = currUsedLinks(e+1); %Get the destination
	        while startNode ~= finalNode %Till we reach the destination
	        	uNode = startNode; %current node
	        	vNode = nextHop(startNode,finalNode); %next hop node
	        	y3 = y3+network(uNode,vNode)*medium; %Propagation delay
	        	y3 = y3+L/bandwidths(uNode,vNode); %Transmission delay
	        	startNode = nextHop(startNode,finalNode); %Update the start node
	        end
	    end
    end

    %% Failure
    for iota = 2 : r
        for s = 1 : S %1 to 5
	        currSfcLength = sfcClassData(s).chainLength; %Get the length of sth sfc
	        currUsedLinks = sfcClassData(s).usedLinks(:,iota); %Get the physical nodes used
	        for e = 1 : currSfcLength-1 %For each edge in the SFC
	    	    startNode = currUsedLinks(e); %Get the source
	    	    finalNode = currUsedLinks(e+1); %Get the destination
	            while startNode ~= finalNode %Till we reach the destination
	        	    uNode = startNode; %current node
	        	    vNode = nextHop(startNode,finalNode); %next hop node
	        	    y3 = y3+(network(uNode,vNode)*medium)*rhoNode^iota*(1-rhoNode); %Propagation delay
                    y3 = y3+(network(uNode,vNode)*medium)*rhoVm^iota*(1-rhoVm);
                    y3 = y3+(network(uNode,vNode)*medium)*rhoVnf^iota*(1-rhoVnf);
	        	    y3 = y3+(L/bandwidths(uNode,vNode))*rhoNode^iota*(1-rhoNode); %Transmission delay
	        	    y3 = y3+(L/bandwidths(uNode,vNode))*rhoVm^iota*(1-rhoVm);
	        	    y3 = y3+(L/bandwidths(uNode,vNode))*rhoVnf^iota*(1-rhoVnf);
	        	    startNode = nextHop(startNode,finalNode); %Update the start node
	            end
	        end
        end
    end

    if isFinal == 1
        y3Yet = y3;
    end
end