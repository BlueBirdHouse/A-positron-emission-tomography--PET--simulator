classdef Filter_Kalman < handle
    %Filter_Kalman ��׼�Ŀ������˲���
    %   ����һ����׼�Ŀ������˲���
    %   ���Ųο����������˲�����ʵʱӦ�á�
    
    properties
        %���̲���
        A_;
        B_;
        T_;
        C_;
        D_;
        
        %����Э������
        Q_;
        R_;
        
        %ά����Ϣ
        n_;
        m_;
        p_;
        q_;
        
        %�˲����
        X_;
        P_k_k_;
        
        %������������Ϣ�����������㷨����ʹ�á�
        %���μ���ʹ�õ�Ԥ����
        Forecast_;
    end
    
    methods
        function obj = Filter_Kalman(n,m,p,q)
            %n,m,p,q��Ӧ���������˲�����ʵʱӦ�á��ı��ά�ȡ�
            if(n == 0)
                error('״̬ά�ȴ���');
            else
                obj.A_ = zeros(n,n);
            end
            
            if(n < m)
                error('�����������״̬����');
            else
                obj.B_ = zeros(n,m);
            end
            
            obj.T_ = zeros(n,p);
            
            if(q == 0)
                error('û�й۲⣡');
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
            %��Ҫͨ�������������ò����������������ȷ�Եò�����֤��
            if(isempty(A) == false)
                if(size(A) ~= size(obj.A_))
                    error('A��ά�ȴ���');
                end
                obj.A_ = A;
            end
            
            if(isempty(B) == false)
                if(size(B) ~= size(obj.B_))
                    error('A��ά�ȴ���');
                end
                obj.B_ = B;
            end
            
            if(isempty(T) == false)
                if(size(T) ~= size(obj.T_))
                    error('A��ά�ȴ���');
                end
                obj.T_ = T;
            end
            
            if(isempty(C) == false)
                if(size(C) ~= size(obj.C_))
                    error('A��ά�ȴ���');
                end
                obj.C_ = C;
            end
            
            if(isempty(D) == false)
                if(size(D) ~= size(obj.D_))
                    error('A��ά�ȴ���');
                end
                obj.D_ = D;
            end
            
            if(isempty(Q) == false)
                if(size(Q) ~= size(obj.Q_))
                    error('A��ά�ȴ���');
                end
                obj.Q_ = Q;
            end
            
            if(isempty(R) == false)
                if(size(R) ~= size(obj.R_))
                    error('A��ά�ȴ���');
                end
                obj.R_ = R;
            end
           
        end
        
        function Initialization(obj,X,P_k_k)
            %�˲�����ʼ��
            [X_m,X_n] = size(X);
            [P_k_k_m,P_k_k_n] = size(P_k_k);
            
            if (X_m == obj.n_)&&(X_n == 1)
                obj.X_ = X;
            else
                error('��ֵ���ô���');
            end
            if((P_k_k_m == obj.n_)&&(P_k_k_n == obj.n_))
                obj.P_k_k_ = P_k_k;
            else
                error('��ֵ���ô���');
            end
            
        end
        
        function [X,P_k_k ] = Step(obj,Y,u)
            %% �������˲��������к�����
            %���û�и����κβ�������ô�ͻ����ʹ����һ�εĲ���
            A = obj.A_;
            B = obj.B_;
            T = obj.T_;
            C = obj.C_;
            D = obj.D_;
            
            Q = obj.Q_;
            R = obj.R_;
            
            X = obj.X_;
            P_k_k = obj.P_k_k_;
            
            %�������˲�����
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
            
            %�洢���
            obj.P_k_k_ = P_k_k;
            obj.X_ = X;
        end
    end
    
end

