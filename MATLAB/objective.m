function [y1, y2, y3] = objective(N, VI, FI, S, L, medium, sfcLengths, sampleNetwork1Original, sampleNetwork1, nextHop, bandwidths, sfcMatrix, Cv, Cf, Xvn, Xfv, lambda, delta, mu, Xfvi, Xski, vms, vnfs)
	y1 = 0;
	for n = 1 : N %1 to 6
		for v = 1 : VI %1 to 13
			% fprintf('%d node, %d VM :',n,v);
			y1 = y1 + Cv(1,vms(v))*Xvn(v,n);
		end
	end
	for v = 1 : VI %1 to 13
		for f = 1 : FI %1 to 22
			y1 = y1 + Cf(1,vnfs(f))*Xfv(f,v);
			% if (Xfv(f,v) ~= 0)
			% 	fprintf('%d VM, %d vnf',v,f);
			% 	y1
			% end
		end
	end

	% y_2
	y2 = 0;
	dq = zeros(1,FI); % Queueing Delay
	dpc = zeros(1,FI); % Processing Delay
	for f = 1 : FI %1 to 22
		lambdaSF = 0;
		deltaSF = 0;
		dpc(1,f) = 1/mu(1,f);
		for s = 1 : S %1 to 5
			lambdaSF = lambdaSF+lambda(s,f);
			deltaSF = deltaSF+delta(s,f);
		end
		dq(1,f) = (lambdaSF-deltaSF)/mu(1,f);
	    for v = 1 : VI %1 to 13
            y2 = y2+(dq(1,f)+dpc(1,f))*Xfvi(f,v)*Xski(s,f);
            % if (Xfvi(f,v)*Xski(s,f) ~= 0)
            %     fprintf('%d %d %d = ',s,f,v);
            %     y2
            % end
	    end
	end

	% y2 = 0;
	% dq = zeros(1,FI); % Queueing Delay
	% for f = 1 : FI %1 to 22
	% 	lambdaSF = 0;
	% 	deltaSF = 0;
	% 	for s = 1 : S %1 to 5
	% 		lambdaSF = lambdaSF+lambda(s,f);
	% 		deltaSF = deltaSF+delta(s,f);
	% 	end
	% 	dq(1,f) = (lambdaSF-deltaSF)/mu(1,f);
	% end
	% dpc = zeros(1,FI); % Processing Delay
	% for f = 1 : FI %1 to 22
	%     dpc(1,f) = 1/mu(1,f);
	% end
	% for s = 1 : S %1 to 5
	%     for v = 1 : VI %1 to 13
	%         for f = 1 : FI %1 to 22
	%             y2 = y2+(dq(1,f)+dpc(1,f))*Xfvi(f,v)*Xski(s,f);
	%             % if (Xfvi(f,v)*Xski(s,f) ~= 0)
	%             %     fprintf('%d %d %d = ',s,f,v);
	%             %     y2
	%             % end
	%         end
	%     end
	% end

	% y_3
	y3 = 0;
	for s = 1 : S %1 to 5
	    currSfcLength = sfcLengths(1,s); %get the length of sth sfc
	    currSfcMatrix = sfcMatrix(:,:,s); %get the sth sfc matrix
	    for currSfcNode = 1 : currSfcLength-1 %for all edges
	        currSrc = 0;
	        currDest = 0;
	        vnfRow = -1;
	        vnfCol = -1;
	        % fprintf('\n\n sfc %d, length %d', s, currSfcLength);
	        for r = 1 : FI %1 to 22
	            for c = 1 : FI %1 to 22
	                if currSfcMatrix(r,c) == 1 %if a virtual link is found
	                    vnfRow = r; %store the row
	                    vnfCol = c; %store the column
	                    currSfcMatrix(r,c) = 0; %mark the link as visited
	                    break;
	                end
	            end
	            if vnfRow ~= -1
	                break;
	            end
	        end
	        vmSrc = -1;
	        vmDest = -1;
	        for vm = 1 : VI %1 to 13
	            if Xfv(vnfRow,vm) == 1 %if the corresponding VM is spotted
	                vmSrc = vm; %store the corresponding source vm
	                break;
	            end
	        end
	        for vm = 1 : VI %1 to 13
	            if Xfv(vnfCol,vm) == 1 %if the corresponding VM is spotted
	                vmDest = vm; %store the corresponding destination vm
	                break;
	            end
	        end
	        for node = 1 : N %1 to 6
	            if Xvn(vmSrc,node) == 1 %if the corresponding physical node is spotted
	                currSrc = node; %store the corresponding source node
	                break;
	            end
	        end
	        for node = 1 : N %1 to 6
	            if Xvn(vmDest,node) == 1 %if the corresponding physical node is spotted
	                currDest = node; %store the corresponding destination node
	                break;
	            end
	        end
	        % s
	        % currSrc
	        % currDest

	        % y3 = y3+sampleNetwork1(currSrc,currDest)*medium; %Propagation delay
	        % y3 = y3+L/bandwidths(currSrc,currDest); %Transmission delay

	        startNode = currSrc;
	        visitedNode = zeros(1,N);
	        while startNode ~= currDest
	        	uNode = startNode;
	        	vNode = nextHop(startNode,currDest);
	        	y3 = y3+sampleNetwork1Original(uNode,vNode)*medium;
	        	y3 = y3+L/bandwidths(uNode,vNode);
	        	startNode = nextHop(startNode,currDest);
	        end

	        % y3
	        % fprintf('===============================================\n');
	    end
	end
end