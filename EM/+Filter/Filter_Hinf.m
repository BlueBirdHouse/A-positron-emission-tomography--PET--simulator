classdef Filter_Hinf < handle
    %Filter_Hinf 提供一个次优Hinf滤波器
    %   算法参考《B. Hassibi, A. H. Sayed, and T. Kailath, 
    %“Indefinite-quadratic estimation and control. 
    %A unified approach to $Hsp 2$ and $Hsp infty$,” 
    %Society for Industrial & Applied Mathematics Philadelphia Pa, 1999.》
    %次优在这里是指，Hinf性能指标没有考虑已知噪声特性
    
    properties
        %方程参数
        F_;
        G_;
        H_;
        
        %Hinf的结果为状态的加权。加权参数为
        L_;
        
        %维度信息
        n_;
        m_;
        p_;
        q_;
        
        %优化宽松参数和其初始值以及允许最大值
        Gama_ = 3;
        
        %滤波结果（没有P_k_k因为Hinf可以离线计算之）
        X_;
        S_;
        
        %下面是从文件读取的离线运算结果
        R_e_j_Queue_;
        P_k_k_Queue_;
        
        %下面是冗余新息，用来方便算法扩充使用。
        %计算得到的新息。
        Innovation_;
        %本次计算使用的预报。
        Forecast_;
    end
    
    methods
        function obj = Filter_Hinf(n,m,p,q)
            if(n == 0)
                error('状态维度错误！');
            else
                obj.F_ = zeros(n,n);
            end
            
            obj.G_ = zeros(n,m);
            
            if(p == 0)
                error('没有观测！');
            else
                obj.H_ = zeros(p,n);
            end
            
            if(q == 0)
                error('输出权重设置错误！');
            else
                obj.L_ = zeros(q,n);
            end
            
            obj.n_ = n;
            obj.m_ = m;
            obj.p_ = p;
            obj.q_ = q;
            
        end
        
        function Set_Parameter(obj,F,G,H,L)
            %不要通过其它方法设置参数，否则参数的正确性得不到保证。
            if(isempty(F) == false)
                if(size(F) ~= size(obj.F_))
                    error('F的维度错误！');
                end
                obj.F_ = F;
            end
            
            if(isempty(G) == false)
                if(size(G) ~= size(obj.G_))
                    error('G的维度错误！');
                end
                obj.G_ = G;
            end
            
            if(isempty(H) == false)
                if(size(H) ~= size(obj.H_))
                    error('H的维度错误！');
                end
                obj.H_ = H;
            end
            
            if(isempty(L) == false)
                if(size(L) ~= size(obj.L_))
                    error('L的维度错误！');
                end
                obj.L_ = L;
            end   
        end
        
        function Initialization(obj,X)
            [X_m,X_n] = size(X);
            if (X_m == obj.n_)&&(X_n == 1)
                obj.X_ = X;
            else
                error('初值设置错误！');
            end
            
            %调入离线计算数据
            Off_lineComputation = load('+Filter/Filter_Hinf_Off_lineComputation');%In Windows, use '\'
            obj.R_e_j_Queue_ = Off_lineComputation.R_e_j_Queue;
            obj.P_k_k_Queue_ = Off_lineComputation.P_k_k_Queue;
            
        end
        
        function Off_lineComputation(obj,X,P_k_k,Measure_Number)
            %这里处理Hinf可以离线计算的部分
            %X,P_k_k： 为用于初始化滤波器的初值
            %Measure_Number： 一共需要离线计算的数据总量
            %滤波器初始化
            [X_m,X_n] = size(X);
            
            if (X_m == obj.n_)&&(X_n == 1)
                obj.X_ = X;
                obj.S_ = obj.L_*X;
            else
                error('初值设置错误！');
            end
            
            %采用离线计算Hinf的 R_e_j 和 P_k_k 方法来保证整个滤波过程具有相同的Gama.
            R_e_j_Queue = containers.Queue(Measure_Number);
            P_k_k_Queue = containers.Queue(Measure_Number);
            
            F = obj.F_;
            G = obj.G_;
            
            for i = 1:1:Measure_Number
                if(obj.TestOptimal(P_k_k))
                    [R_e_j,~,H_L_Block] = obj.R_e_j_Block(P_k_k);
                    R_e_j_Queue.enqueue({R_e_j});
                    %更新滤波方差
                    P_k_k = F*P_k_k*(F') + G*(G') - F*P_k_k*(H_L_Block')*inv(R_e_j)*H_L_Block*P_k_k*(F');
                    P_k_k_Queue.enqueue({P_k_k});
                    disp(strcat('第 ',num2str(i),' 离线计算完成！'));
                else
                    disp(strcat('At: ',num2str(i)));
                    disp(strcat('Gama= ',num2str(obj.Gama_)));
                    error('Game值不合适，请调整！');
                end
            end
            disp(strcat('Gama= ',num2str(obj.Gama_)));
            save('+Filter/Filter_Hinf_Off_lineComputation','R_e_j_Queue','P_k_k_Queue');%For Windows,use '\'
        end
        
        function [Inov] = Innovation(obj,Y)
            %计算新息
            H = obj.H_;
            F = obj.F_;
            X = obj.X_;
            
            obj.Forecast_ = F*X;
            
            Inov = Y - H*obj.Forecast_;
            
            %存储
            obj.Innovation_ = Inov;
        end
        
        function [R_e_j,Front_Block,H_L_Block] = R_e_j_Block(obj,P_k_k)
            %计算经常用到的R_e_j矩阵块,并输出式子（4.2.11）前面的部分Front_Block
            Gama = obj.Gama_;
            H = obj.H_;
            L = obj.L_;
            
            Up_I = eye(obj.p_);
            Down_GamaI = (-(Gama)^2)*eye(obj.q_);
            Front_Block = blkdiag(Up_I,Down_GamaI);
            
            H_L_Block = [H ; L];
            End_Block = H_L_Block * P_k_k * H_L_Block';
            
            R_e_j = Front_Block + End_Block;
        end
        
        function [X,P_k_k] = Step(obj,Y)
            H = obj.H_;
            
            P_k_k = obj.P_k_k_Queue_.dequeue(1);
            if(iscell(P_k_k))
                P_k_k = P_k_k{:};
            end
            %计算滤波增益
            K = P_k_k*(H')*inv(eye(obj.p_)+H*P_k_k*(H'));
            %计算滤波状态
            Inov = obj.Innovation(Y);
            X = obj.Forecast_ + K*Inov;

            %保存滤波结果
            obj.X_ = X;
            obj.S_ = obj.L_*X;
        end
        
%         function [Answer] = TestOptimal(obj,R_e_j_Block)
%             %测试求解最优性的条件是否满足
%             Answer = false;
%             Eigenvalues = eig(R_e_j_Block);
%             %正惯性指数的个数
%             [PositiveNumber,~] = size(find(Eigenvalues>0));
%             [NegativeNumber,~] = size(find(Eigenvalues<0));
%             if( PositiveNumber == obj.p_)
%                 if(NegativeNumber == obj.q_)
%                     Answer = true;
%                 end
%             end
%         end
%          function [Answer] = TestOptimal(obj)
%             %使用P90，Corollary 4.3.1测试最优性
%             L = obj.L_;
%             P = obj.P_k_k_;
%             H = obj.H_;
%             Gama = obj.Gama_;
%             
%             Matrix_B = Gama^2*(eye(obj.q_)) - L*inv(inv(P)+H'*H)*(L');
%             %warning('off');
%             Answer = obj.PositiveDefinite(Matrix_B);
%             %warning('on');
%          end
        
         function [Answer] = TestOptimal(obj,P)
            %使用P85，式子 4.2.9测试最优性
            L = obj.L_;
            H = obj.H_;
            Gama = obj.Gama_;
            
            Matrix = inv(P) + H'*H - Gama^(-2)*(L')*(L);
            %warning('off');
            Answer = obj.PositiveDefinite(Matrix);
            %warning('on');
         end
          
    end
    
    methods(Static)
        function [Value] = PositiveDefinite(M) 
            try
                [~] = chol(M);
            catch
                Value = false;
                return;
            end
            Value = true;
        end
    end
    
end

