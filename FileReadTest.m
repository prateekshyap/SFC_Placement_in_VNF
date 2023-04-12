clear all;
close all;
clc;

% fileID = fopen('N.txt','r');
% formatSpecifier = '%d';
% N = fscanf(fileID,formatSpecifier);

% fileID = fopen('network.txt','r');
% formatSpecifier = '%f';
% size = [N,N];

% network = fscanf(fileID,formatSpecifier,size);
% network

% fid = fopen('network.txt');
% tline = fgetl(fid);
% while ischar(tline)
%     disp(tline)
%     tline = fgetl(fid);
% end
% fclose(fid);

% cases = input('');
% cases(1,3)

% import java.util.LinkedList;

% q = LinkedList();
% q.add(1);
% q.add(2);
% item = q.remove()

% gvText = "digraph G";
% gvText = gvText+newline+"{";
% gvText = gvText+newline+"ranksep = ""equally""";
% gvText = gvText+newline+"rankdir = LR";
% gvText = gvText+newline+"}";

% gvText

% a = SFC(3,[1 3 4]);
% a.chainLength
% a.chain

% import java.util.HashMap;
% import java.util.ArrayList;
% 
% map = HashMap();
% map.put(1,ArrayList());
% map.get(1).add(3);
% map.get(1)
% map.get(1).add(4);
% map.get(1)
% map.get(1).get(0)
% map.get(1).remove(0);
% map.get(1)

% a = 0.00000001
% b = 0.000000001
% a == b
% a/b

%{
network = zeros(97,97);
links = round(rand(1,100)*20+10);

network(1,18) = links(1); network(18,1) = links(1);
network(2,18) = links(2); network(18,2) = links(2);
network(3,18) = links(3); network(18,3) = links(3);
network(4,18) = links(4); network(18,4) = links(4);
network(5,18) = links(5); network(18,5) = links(5);
network(6,18) = links(6); network(18,6) = links(6);
network(7,18) = links(7); network(18,7) = links(7);
network(8,18) = links(8); network(18,8) = links(8);

network(9,19) = links(9); network(19,9) = links(9);
network(10,19) = links(10); network(19,10) = links(10);
network(11,19) = links(11); network(19,11) = links(11);
network(12,19) = links(12); network(19,12) = links(12);
network(13,19) = links(13); network(19,13) = links(13);
network(14,19) = links(14); network(19,14) = links(14);
network(15,19) = links(15); network(19,15) = links(15);
network(16,19) = links(16); network(19,16) = links(16);
network(17,19) = links(17); network(19,17) = links(17);

network(22,38) = links(19); network(38,22) = links(19);
network(23,38) = links(20); network(38,23) = links(20);
network(24,38) = links(21); network(38,24) = links(21);
network(25,38) = links(22); network(38,25) = links(22);
network(26,38) = links(23); network(38,26) = links(23);
network(27,38) = links(24); network(38,27) = links(24);
network(28,38) = links(25); network(38,28) = links(25);
network(29,38) = links(26); network(38,29) = links(26);

network(30,39) = links(27); network(39,30) = links(27);
network(31,39) = links(28); network(39,31) = links(28);
network(32,39) = links(29); network(39,32) = links(29);
network(33,39) = links(30); network(39,33) = links(30);
network(34,39) = links(31); network(39,34) = links(31);
network(35,39) = links(32); network(39,35) = links(32);
network(36,39) = links(33); network(39,36) = links(33);
network(37,39) = links(34); network(39,37) = links(34);

network(42,58) = links(35); network(58,42) = links(35);
network(43,58) = links(36); network(58,43) = links(36);
network(44,58) = links(37); network(58,44) = links(37);
network(45,58) = links(38); network(58,45) = links(38);
network(46,58) = links(39); network(58,46) = links(39);
network(47,58) = links(40); network(58,47) = links(40);
network(48,58) = links(41); network(58,48) = links(41);
network(49,58) = links(42); network(58,49) = links(42);

network(50,59) = links(43); network(59,50) = links(43);
network(51,59) = links(44); network(59,51) = links(44);
network(52,59) = links(45); network(59,52) = links(45);
network(53,59) = links(46); network(59,53) = links(46);
network(54,59) = links(47); network(59,54) = links(47);
network(55,59) = links(48); network(59,55) = links(48);
network(56,59) = links(49); network(59,56) = links(49);
network(57,59) = links(50); network(59,57) = links(50);

network(62,80) = links(51); network(80,62) = links(51);
network(63,80) = links(52); network(80,63) = links(52);
network(64,80) = links(53); network(80,64) = links(53);
network(65,80) = links(54); network(80,65) = links(54);
network(66,80) = links(55); network(80,66) = links(55);
network(67,80) = links(56); network(80,67) = links(56);
network(68,80) = links(57); network(80,68) = links(57);
network(69,80) = links(58); network(80,69) = links(58);

network(70,81) = links(59); network(81,70) = links(59);
network(71,81) = links(60); network(81,71) = links(60);
network(72,81) = links(61); network(81,72) = links(61);
network(73,81) = links(62); network(81,73) = links(62);
network(74,81) = links(63); network(81,74) = links(63);
network(75,81) = links(64); network(81,75) = links(64);
network(76,81) = links(65); network(81,76) = links(65);
network(77,81) = links(66); network(81,77) = links(66);

network(84,92) = links(67); network(92,84) = links(67);
network(84,93) = links(68); network(93,84) = links(68);
network(85,95) = links(69); network(95,85) = links(69);
network(85,96) = links(70); network(96,85) = links(70);
network(85,97) = links(71); network(97,85) = links(71);

network(86,94) = links(72); network(94,86) = links(72);

links = round(rand(1,100)*30+10);

network(18,20) = links(1); network(20,18) = links(1);
network(18,21) = links(2); network(21,18) = links(2);
network(19,20) = links(3); network(20,19) = links(3);
network(19,21) = links(4); network(21,19) = links(4);
network(38,40) = links(5); network(40,38) = links(5);
network(38,41) = links(6); network(41,38) = links(6);
network(39,40) = links(7); network(40,39) = links(7);
network(39,41) = links(8); network(41,39) = links(8);
network(58,60) = links(9); network(60,58) = links(9);
network(58,61) = links(10); network(61,58) = links(10);
network(59,60) = links(11); network(60,59) = links(11);
network(59,61) = links(12); network(61,59) = links(12);
network(80,78) = links(13); network(78,80) = links(13);
network(80,79) = links(14); network(79,80) = links(14);
network(81,78) = links(15); network(78,81) = links(15);
network(81,79) = links(16); network(79,81) = links(16);

network(82,87) = links(17); network(87,82) = links(17);
network(83,88) = links(18); network(88,83) = links(18);
network(84,89) = links(19); network(89,84) = links(19);
network(85,90) = links(20); network(90,85) = links(20);
network(86,91) = links(21); network(91,86) = links(21);

links = round(rand(1,100)*40+10);

network(82,84) = links(1); network(84,82) = links(1);
network(84,86) = links(2); network(86,84) = links(2);
network(86,85) = links(3); network(85,86) = links(3);
network(85,83) = links(4); network(83,85) = links(4);
network(83,82) = links(5); network(82,83) = links(5);

network(87,89) = links(6); network(89,87) = links(6);
network(89,91) = links(7); network(91,89) = links(7);
network(91,90) = links(8); network(90,91) = links(8);
network(90,88) = links(9); network(88,90) = links(9);
network(88,87) = links(10); network(87,88) = links(10);

network(87,90) = links(11); network(90,87) = links(11);
network(88,89) = links(12); network(89,88) = links(12);
network(89,90) = links(13); network(90,89) = links(13);
network(82,88) = links(14); network(88,82) = links(14);
network(84,87) = links(15); network(87,84) = links(15);
network(86,89) = links(16); network(89,86) = links(16);
network(85,91) = links(17); network(91,85) = links(17);

network(20,84) = links(18); network(84,20) = links(18);
network(20,82) = links(19); network(82,20) = links(19);
network(21,84) = links(20); network(84,21) = links(20);
network(21,82) = links(21); network(82,21) = links(21);
network(40,83) = links(22); network(83,40) = links(22);
network(40,85) = links(23); network(85,40) = links(23);
network(41,83) = links(24); network(83,41) = links(24);
network(41,85) = links(25); network(85,41) = links(25);
network(60,84) = links(26); network(84,60) = links(26);
network(60,86) = links(27); network(86,60) = links(27);
network(61,84) = links(28); network(84,61) = links(28);
network(61,86) = links(29); network(86,61) = links(29);
network(78,86) = links(30); network(86,78) = links(30);
network(78,85) = links(31); network(85,78) = links(31);
network(79,86) = links(32); network(86,79) = links(32);
network(79,85) = links(33); network(85,79) = links(33);


for r = 1 : 97
		for c = r+1 : 97
			if (network(r,c) ~= 0)
				network(r,c) = round(network(r,c)/10)*10;
				network(c,r) = round(network(c,r)/10)*10;
			end
		end
end

nodeTypes = round(rand(1,97)*3+1)*16;
count = 0;
for i = 1 : 97
    if (nodeTypes(i) == 64)
        count = count+1;
        if count > 4
            nodeTypes(i) = 16;
        end
    end
    if nodeTypes(i) == 48
        nodeTypes(i) = 32;
    end
end
% nodeTypes

vnfs = ceil(rand(1,30)*3)+1
sum(vnfs)
%}

% network = zeros(11,11);
% links = ceil(rand(1,100)*15);
% network(1,10) = links(1); network(10,1) = links(1);
% network(5,7) = links(2); network(7,5) = links(2);
% network(9,6) = links(3); network(6,9) = links(3);
% network(10,4) = links(4); network(4,10) = links(4);
% network(1,2) = links(5); network(2,1) = links(5);
% network(8,11) = links(6); network(11,8) = links(6);
% network(2,3) = links(7); network(3,2) = links(7);
% network(2,9) = links(8); network(9,2) = links(8);
% network(2,6) = links(9); network(6,2) = links(9);
% network(8,10) = links(10); network(10,8) = links(10);
% network(9,2) = links(11); network(2,9) = links(11);
% network(4,11) = links(12); network(11,4) = links(12);
% network(7,9) = links(13); network(9,7) = links(13);
% network(4,7) = links(14); network(7,4) = links(14);
% network(2,4) = links(15); network(4,2) = links(15);
% network(10,5) = links(16); network(5,10) = links(16);
% network(8,7) = links(17); network(7,8) = links(17);
% network(9,10) = links(18); network(10,9) = links(18);
% network(7,3) = links(19); network(3,7) = links(19);
% network(8,1) = links(20); network(1,8) = links(20);
% network(1,5) = links(21); network(5,1) = links(21);
% network(1,1) = 1; network(1,1) = 1;
% network(1,1) = 1; network(1,1) = 1;
% network(1,1) = 1; network(1,1) = 1;
% network(1,1) = 1; network(1,1) = 1;
% network(1,1) = 1; network(1,1) = 1;
% network(1,1) = 1; network(1,1) = 1;
% network(1,1) = 1; network(1,1) = 1;
% network(1,1) = 1; network(1,1) = 1;
% network(1,1) = 1; network(1,1) = 1;
% network(1,1) = 1; network(1,1) = 1;
% network(1,1) = 1; network(1,1) = 1;
% network(1,1) = 1; network(1,1) = 1;
% G = graph(network);
% plot(G);
% network


% inputNetwork = generateNetwork(97,126);
% 
% for i = 1 : 97
%     for j = 1 : 97
%         if (inputNetwork(i,j) ~= 0)
%             inputNetwork(i,j) = 1;
%         end
%     end
% end
% 
% degree(:) = sum(inputNetwork)
% nodeCount = 0;
% fprintf('Degree 8-10\n');
% for i = 1 : 97
%     if (degree(i) == 8 || degree(i) == 9 || degree(i) == 10 || degree(i) == 11)
%         fprintf('%d ',i);
%         nodeCount = nodeCount+1;
%     end
% end
% fprintf('\n');
% nodeCount
% fprintf('Degree 4-7\n');
% for i = 1 : 97
%     if (degree(i) == 4 || degree(i) == 5 || degree(i) == 6 || degree(i) == 7)
%         fprintf('%d ',i);
%         nodeCount = nodeCount+1;
%     end
% end
% fprintf('\n');
% nodeCount
% fprintf('Degree 1-3\n');
% for i = 1 : 97
%     if (degree(i) == 1 || degree(i) == 2 || degree(i) == 3)
%         fprintf('%d ',i);
%         nodeCount = nodeCount+1;
%     end
% end
% fprintf('\n');
% nodeCount
% 
% sum(degree)



% mat = zeros(5,4);
% for i = 2 : 3
%     mat(:,:,i) = zeros(5,4);
% end
% mat
% mat(:,:,1) = ones(5,4);
% mat
% mat(2,:,:) = [1 2 3 4; 5 6 7 8; 9 10 11 12]';
% mat

% fileID = fopen('input/sevenReliabilityOne/network.txt','r');
% formatSpecifier = '%f';
% dimension = [16,16];
% 
% inputNetwork = fscanf(fileID,formatSpecifier,dimension); %Physical network
% fclose(fileID);
% bridgeStatus = findBridges(16,inputNetwork)


% import java.util.TreeMap
% 
% test = TreeMap();
% test.put(1,8);
% if size(test.lowerKey(1)) == 0
%     fprintf('null');
% else
%     fprintf('kya hai');
% end




x = [10 12 14 16 18 20];             % The range of x values.
y = [50 100 150 200 250 300];             % The range of y values.
[X,Y] = meshgrid (x,y); % This generates the actual grid of x and y values.

lenX = size(X);
Z = zeros(lenX(1),lenX(2));
Z(1,1) = 100;
Z(1,2) = 110;
Z(1,3) = 120;
Z(1,4) = 130;
Z(1,5) = 140;
Z(1,6) = 150;
Z(2,1) = 90;
Z(2,2) = 92;
Z(2,3) = 94;
Z(2,4) = 97;
Z(2,5) = 99;
Z(2,6) = 100;
Z(3,1) = 120;
Z(3,2) = 125;
Z(3,3) = 131;
Z(3,4) = 134;
Z(3,5) = 135;
Z(3,6) = 138;
Z(4,1) = 90;
Z(4,2) = 120;
Z(4,3) = 125;
Z(4,4) = 131;
Z(4,5) = 135;
Z(4,6) = 138;
Z(5,1) = 90;
Z(5,2) = 92;
Z(5,3) = 94;
Z(5,4) = 97;
Z(5,5) = 99;
Z(5,6) = 100;
Z(6,1) = 100;
Z(6,2) = 110;
Z(6,3) = 120;
Z(6,4) = 130;
Z(6,5) = 140;
Z(6,6) = 150;
% Generating the Z Data
figure(1);              % Generating a new window to plot in.
surf(X,Y,Z)             % The surface plotting function.

figure(2);
mesh(X,Y,Z)

figure(3);
plot3(X,Y,Z);