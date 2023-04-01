function [children] = crossover(gene1, gene2, len, C)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
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
    
        orderIndex1 = 1;
        orderIndex2 = 1;
        for i = 1 : len
            if (common.contains(gene1(i)))
                order1(orderIndex1) = gene1(i);
                orderIndex1 = orderIndex1+1;
            end
            if (common.contains(gene2(i)))
                order2(orderIndex2) = gene2(i);
                orderIndex2 = orderIndex2+1;
            end
        end
    
        orderIndex1 = 1;
        orderIndex2 = 1;
        gene1
        gene2
        len
        for i = 1 : len
            if (common.contains(gene1(i)))
                gene1(i) = order2(orderIndex2);
                orderIndex2 = orderIndex2+1;
            end
            if (common.contains(gene2(i)))
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
    
        orderIndex1 = 1;
        orderIndex2 = 1;
        
        for i = 1 : len
            if (~common.contains(gene1(i)))
                gene1(i) = order2(orderIndex2);
                orderIndex2 = orderIndex2+1;
            end
            if (~common.contains(gene2(i)))
                gene2(i) = order1(orderIndex1);
                orderIndex1 = orderIndex1+1;
            end
        end
        
        children(3,:) = gene1;
        children(4,:) = gene2;
    end
end