classdef Filter_EnKF < handle
    %Filter_EnKF ��׼�����Լ����˲���
    %   ����һ����׼������EnKF
    %   ���Ųο�
    % 1. ��J. Mandel, "A brief tutorial on the ensemble Kalman filter," arXiv preprint arXiv:0901.3725, 2009.��
    % 2. J. Mandel, Efficient implementation of the ensemble Kalman filter.
    % University of Colorado at Denver and Health Sciences Center, Center for Computational Mathematics, 2006.
    
    properties
        %���̲���
        A_;%ϵͳ����
        H_;%�۲����
        
        X_;%�洢���ӵľ���
        
        %����Э������
        Q_;
        R_;
        
        %ά����Ϣ
        n_;%�����Ƶ�״̬������ά��
        N_;%���Ӹ���
        m_;%�۲��ά��
        
        %������������Ϣ�����������㷨����ʹ�á�
    end
    
    properties(Dependent)
        Filter_X;
        Filter_P_k_k;
    end
    
    methods
        %�洢���ԵĻص�����
        function value = get.Filter_X(obj)
            value = mean(obj.X_,2);
        end
        function value = get.Filter_P_k_k(obj)
            value = cov((obj.X_)');
        end
    end
    
    methods
        function obj = Filter_EnKF(n,N,m)
            %n,m,p,q��Ӧ���������˲�����ʵʱӦ�á��ı��ά�ȡ�
            if(n == 0)
                error('״̬ά�ȴ���');
            else
                obj.A_ = zeros(n,n);
                obj.X_ = zeros(n,N);
            end
            
            if(m == 0)
                error('û�й۲⣡');
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
            %��Ҫͨ�������������ò����������������ȷ�Եò�����֤��
            if(isempty(A) == false)
                if(size(A) ~= size(obj.A_))
                    error('ϵͳ�����ά�ȴ���');
                end
                obj.A_ = A;
            end
            
            if(isempty(H) == false)
                if(size(H) ~= size(obj.H_))
                    error('�۲�����ά�ȴ���');
                end
                obj.H_ = H;
            end
            
            if(isempty(Q) == false)
                if(size(Q) ~= size(obj.Q_))
                    error('ϵͳ����Э�������');
                end
                obj.Q_ = Q;
            end
            
            if(isempty(R) == false)
                if(size(R) ~= size(obj.R_))
                    error('�۲��Э�������');
                end
                obj.R_ = R;
            end
           
        end
              
        function Initialization(obj,X,P_k_k)
            %�˲�����ʼ��
            obj.X_ = obj.RandomVector(X,P_k_k,obj.N_);
        end
        
        function [ ] = Step(obj,Y)
            %% �������˲��������к�����
            %���û�и����κβ�������ô�ͻ����ʹ����һ�εĲ���
            C = cov((obj.X_)');
            H = obj.H_;
            D = repmat(Y,1,obj.N_) + obj.RandomVector(zeros(obj.m_,1),obj.R_,obj.N_);
            obj.X_ = obj.X_ + C*(H')*inv(H*C*(H') + obj.R_)*(D - H*obj.X_);
            
        end
    end
    
    methods(Static)
        function [Vector] = RandomVector(mu,R,N)
            %����ָ��Э���������̬�������
            if(isempty(R))
                Vector = repmat(mu,1,N);
                return;
            end
            Vector = mvnrnd(mu',R,N);
            Vector = Vector';
        end
    end
    
end

