classdef  StatisticalData < handle
    %StatisticalData ��������ͳ������
    %   �˴���ʾ��ϸ˵��
    
    properties

    end
    
    methods
        function obj = StatisticalData(x,X_truth)
            [X_truth_m,X_truth_n] = size(X_truth);
            n = X_truth_m*X_truth_n;
            x = reshape(x,n,1);
            X_truth = reshape(X_truth,n,1);
            
            RMSE = obj.RMSE_Fun(X_truth,x,n);
            disp('RMSE = ');
            disp(num2str(RMSE,12));

            disp('BIAS = ');
            BIAS  = obj.Bias_Fun(X_truth,x,n);
            disp(num2str(BIAS,12));

            disp('SD = ');
            SD = obj.StandardDeviation_Fun(X_truth,x,n);
            disp(num2str(SD,12));
        end
        
    end
    
    methods(Static)
        function [ RMSE ] = RMSE_Fun( realData,Data,n )
            %������������RMSE�Ĺ�ʽ
            %   
            Diff = Data - realData;
            Diff = Diff.^2;
            Diff = sum(Diff);
            Diff = Diff/n;

            RMSE = sqrt(Diff);
        end
         
        function [ BIAS ] = Bias_Fun( realData,Data,n )
        %���������������Ĺ�ʽ
        %   
            Diff = Data - realData;
            Diff = sum(Diff);
            BIAS = Diff/n;
        end
        
        function [ SD ] = StandardDeviation_Fun( realData,Data,n )
        %�������������׼��Ĺ�ʽ
        %   
            Diff = Data - realData;
            Diff = Diff.^2;
            Diff = sum(Diff);
            Diff = Diff/(n-1);

            SD = sqrt(Diff);
        end
    end
    
end

