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
% 2)3 types of VMs with 13 instances
%	1: can host upto 4 VNFs
%	2, 3, 4, 5, 9, 10: can host upto 2 VNFs
%	6, 7, 8, 11, 12, 13: can host only 1 VNF
% 3)8 VNFs with 22 instances
%	2, 7, 8: 2 instances
%	1, 3, 5, 6: 3 instances
%	4: 4 instances

%% Constants and Variables

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% V = 3;
% VI = 13;
% F = 8;
% FI = 22;
% S = 5;

fileID = fopen('constants.txt','r');
formatSpecifier = '%f';
dimension = [1,9];

constants = fscanf(fileID,formatSpecifier,dimension);

N = constants(1,1);
V = constants(1,2);
VI = constants(1,3);
F = constants(1,4);
FI = constants(1,5);
S = constants(1,6);

% Failure Probabilities
rhoNode = constants(1,7);
rhoVm = constants(1,8);
rhoVnf = constants(1,9);

fileID = fopen('network.txt','r');
formatSpecifier = '%f';
dimension = [N,N];

sampleNetwork1Original = fscanf(fileID,formatSpecifier,dimension);

sampleNetwork1 = allPairShortestPath(N,sampleNetwork1Original);

% Network Status
% nodes = [1 2 2 3 2 3];
% nodeTypes = [1 3 2];
% vmTypes = [1 6 6];
% vnfInstanceCounts = [3 2 3 4 3 3 2 2];
% vnfServiceRates = [1 2 3 1 2 3 2 1];

% vms = [1 2 2 2 2 3 3 3 2 2 3 3 3];
fileID = fopen('vms.txt','r');
formatSpecifier = '%d';
dimension = [1,VI];
vms = fscanf(fileID,formatSpecifier,dimension);

% vnfs = [2 3 2 1 2 2 3 2 2 2 3 2 1 2 3 1 2 3 1 2 2 3];
fileID = fopen('vnfs.txt','r');
formatSpecifier = '%d';
dimension = [1,FI];
vnfs = fscanf(fileID,formatSpecifier,dimension);

% sfcLengths = [3 3 4 2 3];
fileID = fopen('sfcLengths.txt','r');
formatSpecifier = '%d';
dimension = [1,S];
sfcLengths = fscanf(fileID,formatSpecifier,dimension);

% Cost Matrices of setting up the Network

% Cost of hosting VMs on Physical Nodes
% Cv = [	1	2	4];
fileID = fopen('costVN.txt','r');
formatSpecifier = '%f';
dimension = [1,V];
Cv = fscanf(fileID,formatSpecifier,dimension);

% Cost of deploying VNFs on VMs
% Cf = [	4	2	1];
fileID = fopen('costFV.txt','r');
formatSpecifier = '%f';
dimension = [1,F];
Cf = fscanf(fileID,formatSpecifier,dimension);

% Failure level
iota = 0;

% Binary Variables
X = 0;

% VM to Physical Node matrix --- to be generated
% 		1	2	3	4	5	6
Xvn = [ 
		1	0	0	0	0	0; %1
		0	1	0	0	0	0; %2
		0	1	0	0	0	0; %3
		0	0	1	0	0	0; %4
		0	0	1	0	0	0; %5
		0	0	0	1	0	0; %6
		0	0	0	1	0	0; %7
		0	0	0	1	0	0; %8
		0	0	0	0	1	0; %9
		0	0	0	0	1	0; %10
		0	0	0	0	0	1; %11
		0	0	0	0	0	1; %12
		0	0	0	0	0	1 %13
	];

% Function to VM map --- to be generated
% 		1 	2 	3 	4	5 	6	7	8	9	10	11	12	13
Xfv = [ 
		0	0	0	1	0	0	0	0	0	0	0	0	0; %1_1
		0	0	0	0	0	0	1	0	0	0	0	0	0; %1_2
		0	0	0	0	0	0	0	0	1	0	0	0	0; %1_3
		1	0	0	0	0	0	0	0	0	0	0	0	0; %2_1
		0	1	0	0	0	0	0	0	0	0	0	0	0; %2_2
		0	0	0	0	1	0	0	0	0	0	0	0	0; %3_1
		0	0	0	0	0	0	0	1	0	0	0	0	0; %3_2
		0	0	0	0	0	0	0	0	0	1	0	0	0; %3_3
		0	0	1	0	0	0	0	0	0	0	0	0	0; %4_1
		0	0	0	1	0	0	0	0	0	0	0	0	0; %4_2
		0	0	0	0	0	1	0	0	0	0	0	0	0; %4_3
		0	0	0	0	0	0	0	0	1	0	0	0	0; %4_4
		1	0	0	0	0	0	0	0	0	0	0	0	0; %5_1
		0	0	0	0	0	0	0	0	0	1	0	0	0; %5_2
		0	0	0	0	0	0	0	0	0	0	0	1	0; %5_3
		1	0	0	0	0	0	0	0	0	0	0	0	0; %6_1
		0	0	0	0	1	0	0	0	0	0	0	0	0; %6_2
		0	0	0	0	0	0	0	0	0	0	0	0	1; %6_3
		1	0	0	0	0	0	0	0	0	0	0	0	0; %7_1
		0	0	1	0	0	0	0	0	0	0	0	0	0; %7_2
		0	1	0	0	0	0	0	0	0	0	0	0	0; %8_1
		0	0	0	0	0	0	0	0	0	0	1	0	0 %8_2
	];

% 		1 	2 	3 	4	5 	6	7	8	9	10	11	12	13
Xfv2 = [ 
		0	0	0	1	0	0	1	0	1	0	0	0	0; %1
		1	1	0	0	0	0	0	0	0	0	0	0	0; %2
		0	0	0	0	1	0	0	1	0	1	0	0	0; %3
		0	0	1	1	0	1	0	0	1	0	0	0	0; %4
		1	0	0	0	0	0	0	0	0	1	0	1	0; %5
		1	0	0	0	1	0	0	0	0	0	0	0	1; %6
		1	0	1	0	0	0	0	0	0	0	0	0	0; %7
		0	1	0	0	0	0	0	0	0	0	1	0	0; %8
	];

% SFC to VNF map --- to be generated
% 		1_1	1_2	1_3	2_1	2_2	3_1	3_2	3_3	4_1	4_2	4_3	4_4	5_1	5_2	5_3	6_1	6_2	6_3	7_1	7_2	8_1	8_2
Xsf = [ 
		0	0	1	0	0	1	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0; %1
		0	0	0	1	0	0	1	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0; %2
		0	0	1	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	1	0	1	0; %3
		0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0; %4
		0	0	1	0	0	0	0	0	0	0	1	0	0	0	1	0	0	0	0	0	0	0; %5
	];

% 		1	2	3	4	5	6	7	8
Xsf2 = [ 
		1	0	1	1	0	0	0	0; %1
		0	1	1	0	1	0	0	0; %2
		1	0	0	1	0	0	1	1; %3
		0	1	0	0	0	1	0	0; %4
		1	0	0	1	1	0	0	0; %5
	];

% SFC graphs --- to be generated
% SFC-1 : f1 -> f4 -> f3
% SFC-2 : f3 -> f2 -> f5
% SFC-3 : f4 -> f8 -> f7 -> f1
% SFC-4 : f2 -> f6
% SFC-5 : f5 -> f1 -> f4

% sfcMatrix = zeros(FI,FI);
% sfcMatrix2 = zeros(F,F);
% sfcStatus = input('Choose one option for SFC:\n\t1. Random SFC Generation\n\t2. Custom Input\nEnter your choice:\n');
% if sfcStatus == 1
% elseif sfcStatus == 2
% 	for i = 1 : S
% 		chain = zeros(3);
% 		if mod(i,10) == 1 && mod(i,100) ~= 11
% 			chain = input(sprintf('Enter %dst chain:\n',i));
% 		elseif mod(i,10) == 2 && mod(i,100) ~= 12
% 			chain = input(sprintf('Enter %dnd chain:\n',i));
% 		elseif mod(i,10) == 3 && mod(i,100) ~= 13
% 			chain = input(sprintf('Enter %drd chain:\n',i));
% 		else
% 			chain = input(sprintf('Enter %dth chain:\n',i));
% 		end
% 		chainLength = size(chain)-1;
% 		% sfcMatrix(:,:,i) = zeros(FI,FI);
% 		sfcMatrix2(:,:,i) = zeros(F,F);
% 		for node = 1 : chainLength(1,2)
% 			sfcMatrix2(chain(1,node),chain(1,node+1),i) = 1;
% 		end
% 	end
% end

% sfcMatrix2

% 		1_1	1_2	1_3	2_1	2_2	3_1	3_2	3_3	4_1	4_2	4_3	4_4	5_1	5_2	5_3	6_1	6_2	6_3	7_1	7_2	8_1	8_2
sfcMatrix = [ 
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_2
		0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0; %1_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %2_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %2_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_1
		0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_4
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %7_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %7_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %8_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0 %8_2
	];

%		1	2	3	4	5	6	7	8
sfcMatrix2 = [ 0	0	0	1	0	0	0	0; %1
		0	0	0	0	0	0	0	0; %2
		0	0	0	0	0	0	0	0; %3
		0	0	1	0	0	0	0	0; %4
		0	0	0	0	0	0	0	0; %5
		0	0	0	0	0	0	0	0; %6
		0	0	0	0	0	0	0	0; %7
		0	0	0	0	0	0	0	0 %8
	];

% 		1_1	1_2	1_3	2_1	2_2	3_1	3_2	3_3	4_1	4_2	4_3	4_4	5_1	5_2	5_3	6_1	6_2	6_3	7_1	7_2	8_1	8_2
sfcMatrix(:,:,2) = [ 
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_3
		0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0; %2_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %2_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_1
		0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_4
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %7_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %7_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %8_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0 %8_2
	];

% 				1	2	3	4	5	6	7	8
sfcMatrix2(:,:,2) = [	0	0	0	0	0	0	0	0; %1
				0	0	0	0	1	0	0	0; %2
				0	1	0	0	0	0	0	0; %3
				0	0	0	0	0	0	0	0; %4
				0	0	0	0	0	0	0	0; %5
				0	0	0	0	0	0	0	0; %6
				0	0	0	0	0	0	0	0; %7
				0	0	0	0	0	0	0	0 %8
			];

% 		1_1	1_2	1_3	2_1	2_2	3_1	3_2	3_3	4_1	4_2	4_3	4_4	5_1	5_2	5_3	6_1	6_2	6_3	7_1	7_2	8_1	8_2
sfcMatrix(:,:,3) = [ 
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %2_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %2_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0; %4_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_4
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_3
		0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %7_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %7_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0; %8_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0 %8_2
	];

% 				1	2	3	4	5	6	7	8
sfcMatrix2(:,:,3) = [	0	0	0	0	0	0	0	0; %1
				0	0	0	0	0	0	0	0; %2
				0	0	0	0	0	0	0	0; %3
				0	0	0	0	0	0	0	1; %4
				0	0	0	0	0	0	0	0; %5
				0	0	0	0	0	0	0	0; %6
				1	0	0	0	0	0	0	0; %7
				0	0	0	0	0	0	1	0 %8
			];

% 		1_1	1_2	1_3	2_1	2_2	3_1	3_2	3_3	4_1	4_2	4_3	4_4	5_1	5_2	5_3	6_1	6_2	6_3	7_1	7_2	8_1	8_2
sfcMatrix(:,:,4) = [ 
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0; %2_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %2_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_4
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %7_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %7_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %8_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0 %8_2
	];

% 				1	2	3	4	5	6	7	8
sfcMatrix2(:,:,4) = [	0	0	0	0	0	0	0	0; %1
				0	0	0	0	0	1	0	0; %2
				0	0	0	0	0	0	0	0; %3
				0	0	0	0	0	0	0	0; %4
				0	0	0	0	0	0	0	0; %5
				0	0	0	0	0	0	0	0; %6
				0	0	0	0	0	0	0	0; %7
				0	0	0	0	0	0	0	0 %8
			];

% 		1_1	1_2	1_3	2_1	2_2	3_1	3_2	3_3	4_1	4_2	4_3	4_4	5_1	5_2	5_3	6_1	6_2	6_3	7_1	7_2	8_1	8_2
sfcMatrix(:,:,5) = [ 
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_2
		0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0; %1_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %2_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %2_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_4
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_2
		0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %7_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %7_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %8_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0 %8_2
	];

% 				1	2	3	4	5	6	7	8
sfcMatrix2(:,:,5) = [	0	0	0	1	0	0	0	0; %1
				0	0	0	0	0	0	0	0; %2
				0	0	0	0	0	0	0	0; %3
				0	0	0	0	0	0	0	0; %4
				1	0	0	0	0	0	0	0; %5
				0	0	0	0	0	0	0	0; %6
				0	0	0	0	0	0	0	0; %7
				0	0	0	0	0	0	0	0 %8
			];


% 		1_1	1_2	1_3	2_1	2_2	3_1	3_2	3_3	4_1	4_2	4_3	4_4	5_1	5_2	5_3	6_1	6_2	6_3	7_1	7_2	8_1	8_2
% packet arrival rates
lambda = [ 
		2	2	2	0	0	3	3	3	4	4	4	4	0	0	0	0	0	0	0	0	0	0; %1
		0	0	0	4	4	3	3	3	0	0	0	0	2	2	2	0	0	0	0	0	0	0; %2
		1	1	1	0	0	0	0	0	3	3	3	3	0	0	0	0	0	0	2	2	4	4; %3
		0	0	0	2	2	0	0	0	0	0	0	0	0	0	0	3	3	3	0	0	0	0; %4
		1	1	1	0	0	0	0	0	2	2	2	2	3	3	3	0	0	0	0	0	0	0; %5
	];
% packet drop rates
delta = [ 
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5
	];

% 			1	2	3	4	5	6	7	8
% packet arrival rates
lambda2 = [	2	0	3	4	0	0	0	0; %1
			0	4	3	0	2	0	0	0; %2
			1	0	0	3	0	0	2	4; %3
			0	2	0	0	0	3	0	0; %4
			1	0	0	2	3	0	0	0 %5
		];
% packet drop rates
delta2 = [	0	0	0	0	0	0	0	0; %1
			0	0	0	0	0	0	0	0; %2
			0	0	0	0	0	0	0	0; %3
			0	0	0	0	0	0	0	0; %4
			0	0	0	0	0	0	0	0 %5
		];
% service rates
% 		1_1	1_2	1_3	2_1	2_2	3_1	3_2	3_3	4_1	4_2	4_3	4_4	5_1	5_2	5_3	6_1	6_2	6_3	7_1	7_2	8_1	8_2
mu = [ 	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1];
% 		1	2	3	4	5	6	7	8
mu2 = [	1	1	1	1	1	1	1	1];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Binary Variables
Xfvi = Xfv; % for iota 0, this new binary variable boils down to the existing binary variable indicating the VNF deployment
Xski = Xsf; % for iota 0, this new binary vairable boils down to the existing binary variable indicating the SFC assignment



%% Terms
% Failure Factor


% y_1
% y1 = 0;
% for n = 1 : N %1 to 6
% 	for v = 1 : VI %1 to 13
% 		% fprintf('%d node, %d VM :',n,v);
% 		y1 = y1 + Cv(1,vms(v))*Xvn(v,n);
% 	end
% end
% for v = 1 : VI %1 to 13
% 	for f = 1 : FI %1 to 22
% 		y1 = y1 + Cf(1,vnfs(f))*Xfv(f,v);
% 		% if (Xfv(f,v) ~= 0)
% 		% 	fprintf('%d VM, %d vnf',v,f);
% 		% 	y1
% 		% end
% 	end
% end

% % y_2
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

% % y_3
% y3 = 0;
% for s = 1 : S %1 to 5
%     currSfcLength = sfcLengths(1,s); %get the length of sth sfc
%     currSfcMatrix = sfcMatrix(:,:,s); %get the sth sfc matrix
%     for currSfcNode = 1 : currSfcLength-1 %for all edges
%         currSrc = 0;
%         currDest = 0;
%         vnfRow = -1;
%         vnfCol = -1;
%         % fprintf('\n\n sfc %d, length %d', s, currSfcLength);
%         for r = 1 : FI %1 to 22
%             for c = 1 : FI %1 to 22
%                 if currSfcMatrix(r,c) == 1 %if a virtual link is found
%                     vnfRow = r; %store the row
%                     vnfCol = c; %store the column
%                     currSfcMatrix(r,c) = 0; %mark the link as visited
%                     break;
%                 end
%             end
%             if vnfRow ~= -1
%                 break;
%             end
%         end
%         vmSrc = -1;
%         vmDest = -1;
%         for vm = 1 : VI %1 to 13
%             if Xfv(vnfRow,vm) == 1 %if the corresponding VM is spotted
%                 vmSrc = vm; %store the corresponding source vm
%                 break;
%             end
%         end
%         for vm = 1 : VI %1 to 13
%             if Xfv(vnfCol,vm) == 1 %if the corresponding VM is spotted
%                 vmDest = vm; %store the corresponding destination vm
%                 break;
%             end
%         end
%         for node = 1 : N %1 to 6
%             if Xvn(vmSrc,node) == 1 %if the corresponding physical node is spotted
%                 currSrc = node; %store the corresponding source node
%                 break;
%             end
%         end
%         for node = 1 : N %1 to 6
%             if Xvn(vmDest,node) == 1 %if the corresponding physical node is spotted
%                 currDest = node; %store the corresponding destination node
%                 break;
%             end
%         end
%         % s
%         % currSrc
%         % currDest
%         y3 = y3+sampleNetwork1(currSrc,currDest);
%         % y3
%         % fprintf('===============================================\n');
%     end
% end

[y1, y2, y3] = objective(N, VI, FI, S, sfcLengths, sampleNetwork1, sfcMatrix, Cv, Cf, Xvn, Xfv, lambda, delta, mu, Xfvi, Xski, vms, vnfs);

y1
y2
y3