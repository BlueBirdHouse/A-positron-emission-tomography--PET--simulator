classdef Filter_SDKF < Filter.Filter_Kalman
    %Filter_SDKF ִ��SD-Kalman�˲�
    %   SD-Kalman�˲��̳���һ�㿨�����˲�
    
    properties
        %Anscombe�任���Ƽ�ֵ��
        c_Anscombe = 3/8;
    end
    
    methods
        function obj = Filter_SDKF(n,m,p,q)
            obj = obj@Filter.Filter_Kalman(n,m,p,q);
            
        end
        
        function Set_Parameter(obj,Sino)
            %��д�����趨����
            
            %����A
            A = eye(obj.n_);
            
            %����C
            C = Sino.C;
            
            %����R
            %ʹ��׼ȷ��״̬����
            %Ey = (Sino.C * Sino.X + obj.c_Anscombe).^(1/2);
            %ʹ�ù۲��������
            Ey = (Sino.Y_Poisson + obj.c_Anscombe).^(1/2);
            
            Diag = Ey.^2 + 1/8;
            R = diag(Diag);
            
            %¼�����
            Set_Parameter@Filter.Filter_Kalman(obj,A,[],[],C,[],[],R);
        end
        
        function [X,P_k_k ] = Step(obj,Sino)
            %��д�˲�����
            
            %��Anscombe�任,Ȼ��ƽ�����ڼ�ȥ(c+1/4)�൱��
            Y_Poisson = Sino.Y_Poisson;
            y = Y_Poisson - 1/4;
            
            [X,P_k_k ] = Step@Filter.Filter_Kalman(obj,y,[]);
        end
    end
    
end

