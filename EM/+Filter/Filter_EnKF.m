classdef Filter_EnKF < handle
    %Filter_EnKF 标准的线性集团滤波器
    %   构建一个标准的线性EnKF
    %   符号参考
    % 1. 《J. Mandel, "A brief tutorial on the ensemble Kalman filter," arXiv preprint arXiv:0901.3725, 2009.》
    % 2. J. Mandel, Efficient implementation of the ensemble Kalman filter.
    % University of Colorado at Denver and Health Sciences Center, Center for Computational Mathematics, 2006.
    
    properties
        %方程参数
        A_;%系统矩阵
        H_;%观测矩阵
        
        X_;%存储粒子的矩阵
        
        %噪声协方差阵
        Q_;
        R_;
        
        %维度信息
        n_;%被估计的状态向量的维度
        N_;%例子个数
        m_;%观测的维度
        
        %下面是冗余新息，用来方便算法扩充使用。
    end
    
    properties(Dependent)
        Filter_X;
        Filter_P_k_k;
    end
    
    methods
        %存储属性的回调函数
        function value = get.Filter_X(obj)
            value = mean(obj.X_,2);
        end
        function value = get.Filter_P_k_k(obj)
            value = cov((obj.X_)');
        end
    end
    
    methods
        function obj = Filter_EnKF(n,N,m)
            %n,m,p,q对应《卡尔曼滤波及其实时应用》的标记维度。
            if(n == 0)
                error('状态维度错误！');
            else
                obj.A_ = zeros(n,n);
                obj.X_ = zeros(n,N);
            end
            
            if(m == 0)
                error('没有观测！');
            else
                obj.H_ = zeros(m,n);
            end
            
            obj.Q_ = zeros(n,n);
            obj.R_ = zeros(m,m);
            
            obj.n_ = n;
            obj.N_ = N;
            obj.m_ = m;
        end
        
        function Set_Parameter(obj,A,H,Q,R)
            %不要通过其它方法设置参数，否则参数的正确性得不到保证。
            if(isempty(A) == false)
                if(size(A) ~= size(obj.A_))
                    error('系统矩阵的维度错误！');
                end
                obj.A_ = A;
            end
            
            if(isempty(H) == false)
                if(size(H) ~= size(obj.H_))
                    error('观测矩阵的维度错误！');
                end
                obj.H_ = H;
            end
            
            if(isempty(Q) == false)
                if(size(Q) ~= size(obj.Q_))
                    error('系统误差的协方差错误！');
                end
                obj.Q_ = Q;
            end
            
            if(isempty(R) == false)
                if(size(R) ~= size(obj.R_))
                    error('观测的协方差错误！');
                end
                obj.R_ = R;
            end
           
        end
              
        function Initialization(obj,X,P_k_k)
            %滤波器初始化
            obj.X_ = obj.RandomVector(X,P_k_k,obj.N_);
        end
        
        function [ ] = Step(obj,Y)
            %% 卡尔曼滤波器的运行函数。
            %如果没有更新任何参数，那么就会继续使用上一次的参数
            C = cov((obj.X_)');
            H = obj.H_;
            D = repmat(Y,1,obj.N_) + obj.RandomVector(zeros(obj.m_,1),obj.R_,obj.N_);
            obj.X_ = obj.X_ + C*(H')*inv(H*C*(H') + obj.R_)*(D - H*obj.X_);
            
        end
    end
    
    methods(Static)
        function [Vector] = RandomVector(mu,R,N)
            %生成指定协方差阵的正态随机向量
            if(isempty(R))
                Vector = repmat(mu,1,N);
                return;
            end
            Vector = mvnrnd(mu',R,N);
            Vector = Vector';
        end
    end
    
end

