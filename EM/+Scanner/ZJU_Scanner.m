classdef ZJU_Scanner < handle
    %ZJU_Scanner ****大学扫描仪
    %   利用从****大学得到的有关数据做模拟的扫描
    
    properties
        %正弦图（扫描以后的结果）
        Sino;  
        % image dimension(像素尺寸)
        % image dimension (default: nx)
        nx = 0;
        ny = 0;
        
        %状态个数
        n;
        %观测个数
        q;
        
        %观测方差
        Variances = 1.26;
        
        %图像噪声产生对象
        NoiseSource;
    end
    
    methods
        function obj = ZJU_Scanner()
            obj.Sino = Scan_out.Sinogram();
            Image_truth = load('Scanner/cardiac_1_truth.mat');
            Image_truth = Image_truth.cardiac_1_truth;
            Image_truth = Image_truth';
            obj.Sino.True_Figure = Image_truth;
            %获取图像大小
            [obj.nx,obj.ny] = size(Image_truth);
            %生成状态的真值
            obj.Sino.X = reshape(Image_truth,obj.nx*obj.ny,1);
            
            %调入观测方程
            C = load('Scanner/G.mat');
            C = full(C.G);
            obj.Sino.C = C;
            [obj.q,obj.n] = size(C);
            
            obj.Sino.ytrue_ = C*obj.Sino.X;
            
            %初始化污染者
            Variance_List = ones(obj.q,1)*obj.Variances;
            obj.NoiseSource = Analyse.Polluter(Variance_List);
                
        end
        function [ScanSino] = MakeScan(obj)
            %注意，这里将Sino图的Y_Poisson属性用于输出有噪声的观测
            obj.Sino.Y_Poisson = obj.Sino.ytrue_ + obj.NoiseSource.random();
            ScanSino = obj.Sino;
        end
    end
    
    methods(Static)
        function ShowFigure(FigureToShow)
            %显示图像
%             FigureToShow = FigureToShow';
%             idisp(FigureToShow);
            im(FigureToShow);
        end
    end
end

