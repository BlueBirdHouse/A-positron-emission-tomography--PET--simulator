classdef PlotPlayer < handle
    %PlotPlayer ���Խ�ĳ��������һ��Figure������ʾ����
    %   PlotPlayer ���Խ�ĳ��������һ��Figure������ʾ����
    
    properties
        %ӵ��ͼ����
        %FigureHandle;
        PlotHandle;
        
        %���ⲿ���յ�����
        Data;
    end
    
    methods
        function obj = PlotPlayer()
            %���ɺ���ʲô������Ҫ
        end
        
        function Ploter(obj,X_In)
            %�������������ͼ
            %X_Inһ��Ҫ��������
            [m,n] = size(X_In);
            if(m ~= 1)
                error('�����Ԫ�ز���һ��������!');
            end
            obj.Data = [obj.Data(:,:) ; X_In];
            
            obj.PlotHandle = plot(obj.Data);
            drawnow;
        end
    end
    
end

