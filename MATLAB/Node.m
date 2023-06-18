classdef Node
	properties
		vmCount
		vms
	end
	methods
		function obj = Node(vmC,vmS)
            if (nargin ~= 0)
			    obj.vmCount = vmC;
			    obj.vms = vmS;
            end
        end
	end
end