classdef Filter_Hinf < handle
    %Filter_Hinf �ṩһ������Hinf�˲���
    %   �㷨�ο���B. Hassibi, A. H. Sayed, and T. Kailath, 
    %��Indefinite-quadratic estimation and control. 
    %A unified approach to $Hsp 2$ and $Hsp infty$,�� 
    %Society for Industrial & Applied Mathematics Philadelphia Pa, 1999.��
    %������������ָ��Hinf����ָ��û�п�����֪��������
    
    properties
        %���̲���
        F_;
        G_;
        H_;
        
        %Hinf�Ľ��Ϊ״̬�ļ�Ȩ����Ȩ����Ϊ
        L_;
        
        %ά����Ϣ
        n_;
        m_;
        p_;
        q_;
        
        %�Ż����ɲ��������ʼֵ�Լ��������ֵ
        Gama_ = 3;
        
        %�˲������û��P_k_k��ΪHinf�������߼���֮��
        X_;
        S_;
        
        %�����Ǵ��ļ���ȡ������������
        R_e_j_Queue_;
        P_k_k_Queue_;
        
        %������������Ϣ�����������㷨����ʹ�á�
        %����õ�����Ϣ��
        Innovation_;
        %���μ���ʹ�õ�Ԥ����
        Forecast_;
    end
    
    methods
        function obj = Filter_Hinf(n,m,p,q)
            if(n == 0)
                error('״̬ά�ȴ���');
            else
                obj.F_ = zeros(n,n);
            end
            
            obj.G_ = zeros(n,m);
            
            if(p == 0)
                error('û�й۲⣡');
            else
                obj.H_ = zeros(p,n);
            end
            
            if(q == 0)
                error('���Ȩ�����ô���');
            else
                obj.L_ = zeros(q,n);
            end
            
            obj.n_ = n;
            obj.m_ = m;
            obj.p_ = p;
            obj.q_ = q;
            
        end
        
        function Set_Parameter(obj,F,G,H,L)
            %��Ҫͨ�������������ò����������������ȷ�Եò�����֤��
            if(isempty(F) == false)
                if(size(F) ~= size(obj.F_))
                    error('F��ά�ȴ���');
                end
                obj.F_ = F;
            end
            
            if(isempty(G) == false)
                if(size(G) ~= size(obj.G_))
                    error('G��ά�ȴ���');
                end
                obj.G_ = G;
            end
            
            if(isempty(H) == false)
                if(size(H) ~= size(obj.H_))
                    error('H��ά�ȴ���');
                end
                obj.H_ = H;
            end
            
            if(isempty(L) == false)
                if(size(L) ~= size(obj.L_))
                    error('L��ά�ȴ���');
                end
                obj.L_ = L;
            end   
        end
        
        function Initialization(obj,X)
            [X_m,X_n] = size(X);
            if (X_m == obj.n_)&&(X_n == 1)
                obj.X_ = X;
            else
                error('��ֵ���ô���');
            end
            
            %�������߼�������
            Off_lineComputation = load('+Filter/Filter_Hinf_Off_lineComputation');%In Windows, use '\'
            obj.R_e_j_Queue_ = Off_lineComputation.R_e_j_Queue;
            obj.P_k_k_Queue_ = Off_lineComputation.P_k_k_Queue;
            
        end
        
        function Off_lineComputation(obj,X,P_k_k,Measure_Number)
            %���ﴦ��Hinf�������߼���Ĳ���
            %X,P_k_k�� Ϊ���ڳ�ʼ���˲����ĳ�ֵ
            %Measure_Number�� һ����Ҫ���߼������������
            %�˲�����ʼ��
            [X_m,X_n] = size(X);
            
            if (X_m == obj.n_)&&(X_n == 1)
                obj.X_ = X;
                obj.S_ = obj.L_*X;
            else
                error('��ֵ���ô���');
            end
            
            %�������߼���Hinf�� R_e_j �� P_k_k ��������֤�����˲����̾�����ͬ��Gama.
            R_e_j_Queue = containers.Queue(Measure_Number);
            P_k_k_Queue = containers.Queue(Measure_Number);
            
            F = obj.F_;
            G = obj.G_;
            
            for i = 1:1:Measure_Number
                if(obj.TestOptimal(P_k_k))
                    [R_e_j,~,H_L_Block] = obj.R_e_j_Block(P_k_k);
                    R_e_j_Queue.enqueue({R_e_j});
                    %�����˲�����
                    P_k_k = F*P_k_k*(F') + G*(G') - F*P_k_k*(H_L_Block')*inv(R_e_j)*H_L_Block*P_k_k*(F');
                    P_k_k_Queue.enqueue({P_k_k});
                    disp(strcat('�� ',num2str(i),' ���߼�����ɣ�'));
                else
                    disp(strcat('At: ',num2str(i)));
                    disp(strcat('Gama= ',num2str(obj.Gama_)));
                    error('Gameֵ�����ʣ��������');
                end
            end
            disp(strcat('Gama= ',num2str(obj.Gama_)));
            save('+Filter/Filter_Hinf_Off_lineComputation','R_e_j_Queue','P_k_k_Queue');%For Windows,use '\'
        end
        
        function [Inov] = Innovation(obj,Y)
            %������Ϣ
            H = obj.H_;
            F = obj.F_;
            X = obj.X_;
            
            obj.Forecast_ = F*X;
            
            Inov = Y - H*obj.Forecast_;
            
            %�洢
            obj.Innovation_ = Inov;
        end
        
        function [R_e_j,Front_Block,H_L_Block] = R_e_j_Block(obj,P_k_k)
            %���㾭���õ���R_e_j�����,�����ʽ�ӣ�4.2.11��ǰ��Ĳ���Front_Block
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
            %�����˲�����
            K = P_k_k*(H')*inv(eye(obj.p_)+H*P_k_k*(H'));
            %�����˲�״̬
            Inov = obj.Innovation(Y);
            X = obj.Forecast_ + K*Inov;

            %�����˲����
            obj.X_ = X;
            obj.S_ = obj.L_*X;
        end
        
%         function [Answer] = TestOptimal(obj,R_e_j_Block)
%             %������������Ե������Ƿ�����
%             Answer = false;
%             Eigenvalues = eig(R_e_j_Block);
%             %������ָ���ĸ���
%             [PositiveNumber,~] = size(find(Eigenvalues>0));
%             [NegativeNumber,~] = size(find(Eigenvalues<0));
%             if( PositiveNumber == obj.p_)
%                 if(NegativeNumber == obj.q_)
%                     Answer = true;
%                 end
%             end
%         end
%          function [Answer] = TestOptimal(obj)
%             %ʹ��P90��Corollary 4.3.1����������
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
            %ʹ��P85��ʽ�� 4.2.9����������
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

