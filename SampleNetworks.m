clear all
close all
clc

%% First Sample Network
% General Information:
% ---------------------
% 1)6 Physical Nodes
%	1: highest power but lesser cores
%	2, 3, 5: mid power and mid cores
%	4, 6: lowest power but more cores
% 2)3 types of VMs with 8 instances
%	6: can host upto 4 VNFs
%	1, 3, 4, 5, 9, 13: can host upto 2 VNFs
%	2, 7, 8, 10, 11, 12: can host only 1 VNF
% 3)8 VNFs with
%				  	1	2	3	4	5	6 
sampleNetwork1 = [	
					0	3	4	0	1	3; %1
				  	3	0	2	0	2	0; %2
				  	4	2	0	1	4	0; %3
				  	0	0	1	0	2	3; %4
				  	1	2	4	2	0	4; %5
				  	3	0	0	3	4	0 %6
				 ];

% sampleNetwork1
% sampleNetwork1'

%% Constants and Variables
% Failure Probabilities
rhoNode = 0.2
rhoVm = 0.25
rhoVnf = 0.3

% Cost Matrices of setting up the Network

% Cost of hosting VMs on Physical Nodes
% 		1   2   3   4   5   6
Cvn = [ 
		1   1   1   1   1   1; %1
    	1   1   1   1   1   1; %2
    	1   1   1   1   1   1; %3
    ];

% Cost of deploying VNFs on VMs
% 		1   2   3
Cfv = [ 
		1   1   1; %1
		1   1   1; %2
		1   1   1; %3
		1   1   1; %4
		1   1   1; %5
		1   1   1; %6
		1   1   1; %7
		1   1   1 %8
	];

% Failure level
iota = 0

% Binary Variables
X = 0

% VM to Physical Node matrix
% 		1	2	3	4	5	6
Xvn = [ 
		0	0	1	0	0	0; %1
		0	0	0	0	0	1; %2
		0	0	0	0	1	0; %3
		0	0	1	0	0	0; %4
		0	1	0	0	0	0; %5
		1	0	0	0	0	0; %6
		0	0	0	1	0	0; %7
		0	0	0	1	0	0; %8
		0	0	0	0	1	0; %9
		0	0	0	1	0	0; %10
		0	0	0	0	0	1; %11
		0	0	0	0	0	1; %12
		0	1	0	0	0	0 %13
	];

% Function to VM map
% 		1 	2 	3 	4	5 	6	7	8	9	10	11	12	13
Xfv = [ 
		1	0	0	0	0	0	0	0	0	0	0	0	0; %1_1
		0	0	1	0	0	0	0	0	0	0	0	0	0; %1_2
		0	0	0	0	0	0	0	1	0	0	0	0	0; %1_3
		0	0	0	0	1	0	0	0	0	0	0	0	0; %2_1
		0	0	0	0	0	1	0	0	0	0	0	0	0; %2_2
		0	0	0	1	0	0	0	0	0	0	0	0	0; %3_1
		0	0	0	0	0	0	0	0	1	0	0	0	0; %3_2
		0	0	0	0	0	0	0	0	0	1	0	0	0; %3_3
		1	0	0	0	0	0	0	0	0	0	0	0	0; %4_1
		0	0	1	0	0	0	0	0	0	0	0	0	0; %4_2
		0	0	0	0	0	0	1	0	0	0	0	0	0; %4_3
		0	0	0	0	0	0	0	0	0	0	0	0	1; %4_4
		0	0	0	0	0	1	0	0	0	0	0	0	0; %5_1
		0	0	0	0	0	0	0	0	1	0	0	0	0; %5_2
		0	0	0	0	0	0	0	0	0	0	1	0	0; %5_3
		0	0	0	1	0	0	0	0	0	0	0	0	0; %6_1
		0	0	0	0	0	1	0	0	0	0	0	0	0; %6_2
		0	0	0	0	0	0	0	0	0	0	0	1	0; %6_3
		0	0	0	0	0	1	0	0	0	0	0	0	0; %7_1
		0	0	0	0	0	0	0	0	0	0	0	0	1; %7_2
		0	1	0	0	0	0	0	0	0	0	0	0	0; %8_1
		0	0	0	0	1	0	0	0	0	0	0	0	0 %8_2
	];

% SFC to VNF map
% 		1_1	1_2	1_3	2_1	2_2	3_1	3_2	3_3	4_1	4_2	4_3	4_4	5_1	5_2	5_3	6_1	6_2	6_3	7_1	7_2	8_1	8_2
Xsf = [ 
		0	1	0	0	0	1	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0; %1
		0	0	0	0	1	0	0	1	0	0	0	0	1	0	0	0	0	0	0	0	0	0; %2
		0	1	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	1	0	0	1; %3
		0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0; %4
		0	1	0	0	0	0	0	0	0	0	1	0	0	0	1	0	0	0	0	0	0	0; %5
	];

%% Terms
% Failure Factor


% y_1
y1 = 0


% y_2


% y_3

