classdef VM
	properties
		vnfCount
		vnfs
	end
	methods
		function obj = VM(vnfC,vnfS)
            if (nargin ~= 0)
			    obj.vnfCount = vnfC;
			    obj.vnfs = vnfS;
            end
        end
	end
end