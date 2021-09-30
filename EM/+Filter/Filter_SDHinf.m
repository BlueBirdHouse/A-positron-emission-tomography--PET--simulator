classdef Filter_SDHinf < Filter.Filter_Hinf
    %Filter_SDKF 执行SD-Kalman滤波
    %   SD-Kalman滤波继承自一般卡尔曼滤波
    
    properties
        %Anscombe变换的推荐值。
        c_Anscombe = 3/8;
    end
    
    methods
        function obj = Filter_SDHinf(n,m,p,q)
            obj = obj@Filter.Filter_Hinf(n,m,p,q);
            
        end
        
        function Set_Parameter(obj,Sino)
            %重写参数设定函数
            
            %生成A
            F = eye(obj.n_);
            
            %生成C
            H = Sino.C;
            
            %生成R
            %使用准确的状态生成
            %Ey = (Sino.C * Sino.X + obj.c_Anscombe).^(1/2);
            %使用观测代替生成
            %Ey = (Sino.Y_Poisson + obj.c_Anscombe).^(1/2);
            
            %Diag = Ey.^2 + 1/8;
            %R = diag(Diag);
            
            %录入参数
            L = eye(obj.n_);
            Set_Parameter@Filter.Filter_Hinf(obj,F,[],H,L);
        end
        
        function [X,P_k_k ] = Step(obj,Sino)
            %重写滤波函数
            
            %做Anscombe变换,然后平方，在减去(c+1/4)相当于
            Y_Poisson = Sino.Y_Poisson;
            y = Y_Poisson - 1/4;
            
            [X,P_k_k ] = Step@Filter.Filter_Hinf(obj,y);
        end
    end
    
end

