classdef Filter_EM_Automatic < Filter.Filter_EM
    %Filter_EM_Automatic ʹ���Զ���ѧ�ƵĹ淶�ͷ������±�дEM�㷨
    %   ��д��������Ŀ����Ҫ��Ϊ�˼���EM����������Ƿ���ȷ��
    
    properties
        %EM������Ҫʹ�õ��ڲ�������
        %ע�⣬EM�����ǵ����������ڵ��������У����ܸı��ڲ�����
        Sino_;
        Asum;
        
        %�˲����Ĺ���
        X;
    end
    
    methods
        
        function obj = Filter_EM_Automatic(Sino)
            obj = obj@Filter.Filter_EM();
            obj.Sino_ = Sino;
            %��ʼ��״̬
            [X_m,X_n] = size(obj.Sino_.X);
            obj.X = ones(X_m,X_n);
            %����ϵͳ���̵��к�����
            obj.Asum = sum(Sino.C)';
        end
        
        function [x] = Step(obj)
            %��������ֱ���˳�������ɡ�
            G = obj.Sino_.C;
            
            ri = obj.Sino_.ri_;
            [ri_m,ri_n] = size(ri);
            ri = reshape(ri,ri_m * ri_n,1);
            
            yi = obj.Sino_.Y_Poisson;
            
            x = obj.X;
            
            yp = G * x + ri;
            eterm = G' * (yi ./ yp);
            x = x .* eterm ./ obj.Asum;
            
            obj.X = x;
        end
    end
    
end

