classdef Filter_SDHinf < Filter.Filter_Hinf
    %Filter_SDKF ִ��SD-Kalman�˲�
    %   SD-Kalman�˲��̳���һ�㿨�����˲�
    
    properties
        %Anscombe�任���Ƽ�ֵ��
        c_Anscombe = 3/8;
    end
    
    methods
        function obj = Filter_SDHinf(n,m,p,q)
            obj = obj@Filter.Filter_Hinf(n,m,p,q);
            
        end
        
        function Set_Parameter(obj,Sino)
            %��д�����趨����
            
            %����A
            F = eye(obj.n_);
            
            %����C
            H = Sino.C;
            
            %����R
            %ʹ��׼ȷ��״̬����
            %Ey = (Sino.C * Sino.X + obj.c_Anscombe).^(1/2);
            %ʹ�ù۲��������
            %Ey = (Sino.Y_Poisson + obj.c_Anscombe).^(1/2);
            
            %Diag = Ey.^2 + 1/8;
            %R = diag(Diag);
            
            %¼�����
            L = eye(obj.n_);
            Set_Parameter@Filter.Filter_Hinf(obj,F,[],H,L);
        end
        
        function [X,P_k_k ] = Step(obj,Sino)
            %��д�˲�����
            
            %��Anscombe�任,Ȼ��ƽ�����ڼ�ȥ(c+1/4)�൱��
            Y_Poisson = Sino.Y_Poisson;
            y = Y_Poisson - 1/4;
            
            [X,P_k_k ] = Step@Filter.Filter_Hinf(obj,y);
        end
    end
    
end

