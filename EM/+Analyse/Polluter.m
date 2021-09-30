classdef Polluter < handle
    %Pulluter 污染者
    %   此处显示详细说明
    
    properties
        %随机量矩阵，用来存储给定的噪声特性
        Pollute = makedist('Normal');
        %记录噪声特性的方差阵
        Variances;
        %本污染者的维度
        m;
        n;
    end
    
    methods
        function obj = Polluter(Variance_Matrix)
            [obj.m,obj.n] = size(Variance_Matrix);
            obj.Variances = Variance_Matrix;
            %下面的策略速度太慢而不考虑
            %初始化污染者
            %首先生成一列
%             Temp = makedist('Normal');
%             Temp = repmat(Temp,obj.m,1);
%             obj.Pollute = repmat(Temp,1,obj.n);
%             for i = 1:1:(obj.m)
%                 for j = 1:1:(obj.n)
%                     disp(strcat('正在生成：',num2str(i),'__',num2str(j),' 随机量。'));
%                     StandardDeviation = sqrt(Variance_Matrix(i,j));
%                     obj.Pollute(i,j) = makedist('Normal','mu',0,'sigma',StandardDeviation);
%                 end
%             end
        end
        
        function [RANDs] = random(obj)
            %% 用来生成一次污染实例
            %下述方法过于慢而不予考虑
%             RANDs = zeros(obj.m,obj.n);
%             for i = 1:1:(obj.m)
%                 for j = 1:1:(obj.n)
%                     disp(strcat('正在污染：',num2str(i),'__',num2str(j),' 元素。'));
%                     RANDs(i,j) = obj.Pollute(i,j).random();
%                 end
%             end
            StandardDeviation_Matrix = sqrt(obj.Variances);
            RANDs = randn(obj.m,obj.n).*StandardDeviation_Matrix;
        end
    end
    
end

