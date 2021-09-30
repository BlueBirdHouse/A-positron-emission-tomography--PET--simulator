classdef PlotPlayer < handle
    %PlotPlayer 可以将某个变量在一个Figure里面显示出来
    %   PlotPlayer 可以将某个变量在一个Figure里面显示出来
    
    properties
        %拥有图像句柄
        %FigureHandle;
        PlotHandle;
        
        %从外部接收的数据
        Data;
    end
    
    methods
        function obj = PlotPlayer()
            %构成函数什么都不需要
        end
        
        function Ploter(obj,X_In)
            %调用这个函数绘图
            %X_In一定要是列向量
            [m,n] = size(X_In);
            if(m ~= 1)
                error('输入的元素不是一个行向量!');
            end
            obj.Data = [obj.Data(:,:) ; X_In];
            
            obj.PlotHandle = plot(obj.Data);
            drawnow;
        end
    end
    
end

