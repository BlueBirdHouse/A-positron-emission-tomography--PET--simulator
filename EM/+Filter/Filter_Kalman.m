classdef Filter_Kalman < handle
    %Filter_Kalman 标准的卡尔曼滤波器
    %   构建一个标准的卡尔曼滤波器
    %   符号参考《卡尔曼滤波及其实时应用》
    
    properties
        %方程参数
        A_;
        B_;
        T_;
        C_;
        D_;
        
        %噪声协方差阵
        Q_;
        R_;
        
        %维度信息
        n_;
        m_;
        p_;
        q_;
        
        %滤波结果
        X_;
        P_k_k_;
        
        %下面是冗余新息，用来方便算法扩充使用。
        %本次计算使用的预报。
        Forecast_;
    end
    
    methods
        function obj = Filter_Kalman(n,m,p,q)
            %n,m,p,q对应《卡尔曼滤波及其实时应用》的标记维度。
            if(n == 0)
                error('状态维度错误！');
            else
                obj.A_ = zeros(n,n);
            end
            
            if(n < m)
                error('输入个数大于状态个数');
            else
                obj.B_ = zeros(n,m);
            end
            
            obj.T_ = zeros(n,p);
            
            if(q == 0)
                error('没有观测！');
            else
                obj.C_ = zeros(q,n);
                obj.D_ = zeros(q,m);
            end
            
            obj.Q_ = zeros(p,p);
            obj.R_ = zeros(q,q);
            
            obj.n_ = n;
            obj.m_ = m;
            obj.p_ = p;
            obj.q_ = q;
        end
        
        function Set_Parameter(obj,A,B,T,C,D,Q,R)
            %不要通过其它方法设置参数，否则参数的正确性得不到保证。
            if(isempty(A) == false)
                if(size(A) ~= size(obj.A_))
                    error('A的维度错误！');
                end
                obj.A_ = A;
            end
            
            if(isempty(B) == false)
                if(size(B) ~= size(obj.B_))
                    error('A的维度错误！');
                end
                obj.B_ = B;
            end
            
            if(isempty(T) == false)
                if(size(T) ~= size(obj.T_))
                    error('A的维度错误！');
                end
                obj.T_ = T;
            end
            
            if(isempty(C) == false)
                if(size(C) ~= size(obj.C_))
                    error('A的维度错误！');
                end
                obj.C_ = C;
            end
            
            if(isempty(D) == false)
                if(size(D) ~= size(obj.D_))
                    error('A的维度错误！');
                end
                obj.D_ = D;
            end
            
            if(isempty(Q) == false)
                if(size(Q) ~= size(obj.Q_))
                    error('A的维度错误！');
                end
                obj.Q_ = Q;
            end
            
            if(isempty(R) == false)
                if(size(R) ~= size(obj.R_))
                    error('A的维度错误！');
                end
                obj.R_ = R;
            end
           
        end
        
        function Initialization(obj,X,P_k_k)
            %滤波器初始化
            [X_m,X_n] = size(X);
            [P_k_k_m,P_k_k_n] = size(P_k_k);
            
            if (X_m == obj.n_)&&(X_n == 1)
                obj.X_ = X;
            else
                error('初值设置错误！');
            end
            if((P_k_k_m == obj.n_)&&(P_k_k_n == obj.n_))
                obj.P_k_k_ = P_k_k;
            else
                error('初值设置错误！');
            end
            
        end
        
        function [X,P_k_k ] = Step(obj,Y,u)
            %% 卡尔曼滤波器的运行函数。
            %如果没有更新任何参数，那么就会继续使用上一次的参数
            A = obj.A_;
            B = obj.B_;
            T = obj.T_;
            C = obj.C_;
            D = obj.D_;
            
            Q = obj.Q_;
            R = obj.R_;
            
            X = obj.X_;
            P_k_k = obj.P_k_k_;
            
            %下面是滤波过程
            P_k_k_1 = A*P_k_k*(A') + T*Q*(T');
            
            if(isempty(R))
                G = P_k_k_1*(C')*inv(C*P_k_k_1*(C'));
            else 
                G = P_k_k_1*(C')*inv(C*P_k_k_1*(C') + R);
            end
            
            P_k_k = P_k_k_1 - G*C*P_k_k_1;
            
            if(isempty(u))
                X_k_k_1 = A*X;
                X = X_k_k_1 + G*(Y - C*X_k_k_1);
                
                obj.Forecast_ = X_k_k_1;
            else
                X_k_k_1 = A*X + B*u;
                X = X_k_k_1 + G*(Y - D*u - C*X_k_k_1);
                
                obj.Forecast_ = X_k_k_1;
            end
            
            %存储结果
            obj.P_k_k_ = P_k_k;
            obj.X_ = X;
        end
    end
    
end

