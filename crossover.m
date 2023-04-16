function [children] = crossover(gene1, gene2, len, C, VI, type)

    global mutationProbability;
    
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if type == 1
%   This is a modified cyclic crossover hybrid drafting
    import java.util.TreeSet;

    children = zeros(C,len);

    set1 = TreeSet();
    common = TreeSet();

    for i = 1 : len
        set1.add(gene1(i));
    end

    for i = 1 : len
        if set1.contains(gene2(i))
            common.add(gene2(i));
        end
    end

    if common.size() == 0
        draft = zeros(1,len*2);
        draftIndex = 1;
        for i = 1 : len
            draft(draftIndex) = gene1(i);
            draftIndex = draftIndex+1;
        end
        for i = 1 : len
            draft(draftIndex) = gene2(i);
            draftIndex = draftIndex+1;
        end
        indices = zeros(C,len);
        for in = 1 : C
            indices(in,:) = randperm(2*len,len);
        end
        for cin = 1 : C
            for din = 1 : len
                children(cin,din) = draft(indices(cin,din));
            end
        end
    else
        order1 = zeros(1,common.size());
        order2 = zeros(1,common.size());
        visited1 = TreeSet();
        visited2 = TreeSet();
    
        orderIndex1 = 1;
        orderIndex2 = 1;
        for i = 1 : len
            if common.contains(gene1(i)) && ~visited1.contains(gene1(i))
                order1(orderIndex1) = gene1(i);
                visited1.add(gene1(i));
                orderIndex1 = orderIndex1+1;
            end
            if common.contains(gene2(i)) && ~visited2.contains(gene2(i))
                order2(orderIndex2) = gene2(i);
                visited2.add(gene2(i));
                orderIndex2 = orderIndex2+1;
            end
        end
    
        orderIndex1 = 1;
        orderIndex2 = 1;
        
        for i = 1 : len
            if (common.contains(gene1(i)) && orderIndex2 <= common.size())
                gene1(i) = order2(orderIndex2);
                orderIndex2 = orderIndex2+1;
            end
            if (common.contains(gene2(i)) && orderIndex1 <= common.size())
                gene2(i) = order1(orderIndex1);
                orderIndex1 = orderIndex1+1;
            end
        end
    
        children(1,:) = gene1;
        children(2,:) = gene2;

        order1 = zeros(1,len-common.size());
        order2 = zeros(1,len-common.size());
    
        orderIndex1 = 1;
        orderIndex2 = 1;
    
        for i = 1 : len
            if (~common.contains(gene1(i)))
                order1(orderIndex1) = gene1(i);
                orderIndex1 = orderIndex1+1;
            end
            if (~common.contains(gene2(i)))
                order2(orderIndex2) = gene2(i);
                orderIndex2 = orderIndex2+1;
            end
        end
        maxO1 = orderIndex1-1;
        maxO2 = orderIndex2-1;
        orderIndex1 = 1;
        orderIndex2 = 1;
        
        for i = 1 : len
            if (~common.contains(gene1(i)) && orderIndex2 <= maxO2)
                gene1(i) = order2(orderIndex2);
                orderIndex2 = orderIndex2+1;
            end
            if (~common.contains(gene2(i)) && orderIndex1 <= maxO1)
                gene2(i) = order1(orderIndex1);
                orderIndex1 = orderIndex1+1;
            end
        end
        
        children(3,:) = gene1;
        children(4,:) = gene2;
    end






else if type == 2
%   This is two point crossover
    children = zeros(C,len);
    point1 = 0;
    point2 = 0;
    if len == 3
        point1 = 1;
        point2 = 2;
    else
        point1 = randi([1 len-1]);
        point2 = point1;
        while point2 == point1
            point2 = randi([1 len-1]);
        end
        if point1 > point2
            temp = point1;
            point1 = point2;
            point2 = temp;
        end
    end
    children(1,:) = gene1;
    children(2,:) = gene2;
    for i = point1+1 : point2
        temp = children(1,i);
        children(1,i) = children(2,i);
        children(2,i) = temp;
    end
    point1 = 0;
    point2 = 0;
    if len == 3
        point1 = 1;
        point2 = 2;
    else
        point1 = randi([1 len-1]);
        point2 = point1;
        while point2 == point1
            point2 = randi([1 len-1]);
        end
        if point1 > point2
            temp = point1;
            point1 = point2;
            point2 = temp;
        end
    end
    children(3,:) = gene1;
    children(4,:) = gene2;
    for i = point1+1 : point2
        temp = children(3,i);
        children(3,i) = children(4,i);
        children(4,i) = temp;
    end






else
%   This is hybrid two point crossover and generation
    import java.util.TreeSet;
    children = zeros(C,len);
    point1 = 0;
    point2 = 0;
    if len == 3 % If the chain length is 3, the two points will be mandatorily 1 and 2
        point1 = 1;
        point2 = 2;
    else % Otherwise generate random unique indices and ensure that point1 is smaller than point2
        point1 = randi([1 len-1]);
        point2 = point1;
        while point2 == point1
            point2 = randi([1 len-1]);
        end
        if point1 > point2
            temp = point1;
            point1 = point2;
            point2 = temp;
        end
    end
    % If the length is 8 and point1 and point2 are 4 and 6 respectively
    % then the sections are like the following
    % 1 2 3 4 | 5 6 | 7 8
    % Copy the two chromosomes
    children(1,:) = gene1;
    children(2,:) = gene2;
    %% Standard two point crossover
    % Swap the middle section
    for i = point1+1 : point2
        temp = children(1,i);
        children(1,i) = children(2,i);
        children(2,i) = temp;
    end
    % Copy the two chromosomes again
    children(3,:) = gene1;
    children(4,:) = gene2;
    %% Formation operation (replacement of mutation)
    % Take union of both the chromosomes
    parentUnion = TreeSet();
    for i = 1 : len
        parentUnion.add(gene1(i));
        parentUnion.add(gene2(i));
    end
    % Find out the VMs which are not present in the union
    remVal = VI-parentUnion.size();
    remVMs = zeros(1,remVal);
    remIndex = 1;
    for v = 1 : VI
        if ~parentUnion.contains(v)
            remVMs(remIndex) = v;
            remIndex = remIndex+1;
        end
    end
    remIndex = 1;
    mutationSize = ceil(len*mutationProbability/100); % Get the number of indices to be mutated
    % In both section-1 and section-3, alter mutationSize number of indices
    for i = 1 : min(point1,mutationSize)
        if remIndex > remVal
            break;
        end
        children(3,i) = remVMs(remIndex);
        remIndex = remIndex+1;
    end
    for i = point2+1 : min(len,point2+1+mutationSize)
        if remIndex > remVal
            break;
        end
        children(3,i) = remVMs(remIndex);
        remIndex = remIndex+1;
    end
    remIndex = 1;
    for i = 1 : min(point1,mutationSize)
        if remIndex > remVal
            break;
        end
        children(4,i) = remVMs(remIndex);
        remIndex = remIndex+1;
    end
    for i = point2+1 : min(len,point2+1+mutationSize)
        if remIndex > remVal
            break;
        end
        children(4,i) = remVMs(remIndex);
        remIndex = remIndex+1;
    end
end
end