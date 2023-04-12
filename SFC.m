classdef SFC
	properties
		chainLength
		chain
		usedLinks = zeros(1,2);
		usedInstances = zeros(1,2);
	end
	methods
		function obj = SFC(len,vec,links,nodes)
            if (nargin ~= 0)
			    obj.chainLength = len;
			    obj.chain = vec;
			    obj.usedLinks = links;
			    obj.usedInstances = nodes;
            end
        end
	end
end