classdef Filter_EM_Automatic < Filter.Filter_EM
    %Filter_EM_Automatic 使用自动化学科的规范和方法重新编写EM算法
    %   编写本函数的目的主要是为了检测对EM方法的理解是否正确。
    
    properties
        %EM方法需要使用的内部参数。
        %注意，EM方法是迭代方法，在迭代过程中，不能改变内部参数
        Sino_;
        Asum;
        
        %滤波器的估计
        X;
    end
    
    methods
        
        function obj = Filter_EM_Automatic(Sino)
            obj = obj@Filter.Filter_EM();
            obj.Sino_ = Sino;
            %初始化状态
            [X_m,X_n] = size(obj.Sino_.X);
            obj.X = ones(X_m,X_n);
            %计算系统方程的列和向量
            obj.Asum = sum(Sino.C)';
        end
        
        function [x] = Step(obj)
            %反复调用直到退出条件达成。
            G = obj.Sino_.C;
            
            ri = obj.Sino_.ri_;
            [ri_m,ri_n] = size(ri);
            ri = reshape(ri,ri_m * ri_n,1);
            
            yi = obj.Sino_.Y_Poisson;
            
            x = obj.X;
            
            yp = G * x + ri;
            eterm = G' * (yi ./ yp);
            x = x .* eterm ./ obj.Asum;
            
            obj.X = x;
        end
    end
    
end

