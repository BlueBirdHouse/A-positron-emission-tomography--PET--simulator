classdef ZJU_Scanner < handle
    %ZJU_Scanner ****��ѧɨ����
    %   ���ô�****��ѧ�õ����й�������ģ���ɨ��
    
    properties
        %����ͼ��ɨ���Ժ�Ľ����
        Sino;  
        % image dimension(���سߴ�)
        % image dimension (default: nx)
        nx = 0;
        ny = 0;
        
        %״̬����
        n;
        %�۲����
        q;
        
        %�۲ⷽ��
        Variances = 1.26;
        
        %ͼ��������������
        NoiseSource;
    end
    
    methods
        function obj = ZJU_Scanner()
            obj.Sino = Scan_out.Sinogram();
            Image_truth = load('Scanner/cardiac_1_truth.mat');
            Image_truth = Image_truth.cardiac_1_truth;
            Image_truth = Image_truth';
            obj.Sino.True_Figure = Image_truth;
            %��ȡͼ���С
            [obj.nx,obj.ny] = size(Image_truth);
            %����״̬����ֵ
            obj.Sino.X = reshape(Image_truth,obj.nx*obj.ny,1);
            
            %����۲ⷽ��
            C = load('Scanner/G.mat');
            C = full(C.G);
            obj.Sino.C = C;
            [obj.q,obj.n] = size(C);
            
            obj.Sino.ytrue_ = C*obj.Sino.X;
            
            %��ʼ����Ⱦ��
            Variance_List = ones(obj.q,1)*obj.Variances;
            obj.NoiseSource = Analyse.Polluter(Variance_List);
                
        end
        function [ScanSino] = MakeScan(obj)
            %ע�⣬���ｫSinoͼ��Y_Poisson������������������Ĺ۲�
            obj.Sino.Y_Poisson = obj.Sino.ytrue_ + obj.NoiseSource.random();
            ScanSino = obj.Sino;
        end
    end
    
    methods(Static)
        function ShowFigure(FigureToShow)
            %��ʾͼ��
%             FigureToShow = FigureToShow';
%             idisp(FigureToShow);
            im(FigureToShow);
        end
    end
end

