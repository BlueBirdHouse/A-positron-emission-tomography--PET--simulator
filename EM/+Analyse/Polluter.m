classdef Polluter < handle
    %Pulluter ��Ⱦ��
    %   �˴���ʾ��ϸ˵��
    
    properties
        %��������������洢��������������
        Pollute = makedist('Normal');
        %��¼�������Եķ�����
        Variances;
        %����Ⱦ�ߵ�ά��
        m;
        n;
    end
    
    methods
        function obj = Polluter(Variance_Matrix)
            [obj.m,obj.n] = size(Variance_Matrix);
            obj.Variances = Variance_Matrix;
            %����Ĳ����ٶ�̫����������
            %��ʼ����Ⱦ��
            %��������һ��
%             Temp = makedist('Normal');
%             Temp = repmat(Temp,obj.m,1);
%             obj.Pollute = repmat(Temp,1,obj.n);
%             for i = 1:1:(obj.m)
%                 for j = 1:1:(obj.n)
%                     disp(strcat('�������ɣ�',num2str(i),'__',num2str(j),' �������'));
%                     StandardDeviation = sqrt(Variance_Matrix(i,j));
%                     obj.Pollute(i,j) = makedist('Normal','mu',0,'sigma',StandardDeviation);
%                 end
%             end
        end
        
        function [RANDs] = random(obj)
            %% ��������һ����Ⱦʵ��
            %�������������������迼��
%             RANDs = zeros(obj.m,obj.n);
%             for i = 1:1:(obj.m)
%                 for j = 1:1:(obj.n)
%                     disp(strcat('������Ⱦ��',num2str(i),'__',num2str(j),' Ԫ�ء�'));
%                     RANDs(i,j) = obj.Pollute(i,j).random();
%                 end
%             end
            StandardDeviation_Matrix = sqrt(obj.Variances);
            RANDs = randn(obj.m,obj.n).*StandardDeviation_Matrix;
        end
    end
    
end

