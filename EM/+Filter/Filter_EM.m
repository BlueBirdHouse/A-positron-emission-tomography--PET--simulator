classdef Filter_EM < handle
    %Filter_EM EM�㷨�˲�
    %   ʹ��IRT���������õ�EM�㷨�˲�
    
    properties
    end
    
    methods
        function obj = Filter_EM()
            
        end

    end
    
    methods(Static)
        function [xmat] = Step(Image_Info,Sino,ci,ri,Times)
            xinit = Image_Info.ones;
            %xmat = eml_em(xinit(Image_Info.mask), Sino.G_, Sino.yi_(:), ci(:), ri(:), [], 9);
            xmat = eml_em(xinit(Image_Info.mask), Sino.G_, Sino.yi_(:), ci(:), ri(:), [], Times);
            xmat = Image_Info.embed(xmat);
            
        end
        function [x_Out] = RemoveMask(x_In,Image_Info)
            %���ڲ����˲���״̬�Ǳ�Mask�Ժ��״̬�����ｫ��Щ״̬��ԭΪԭ����ͼƬ
            x_Out = Image_Info.embed(x_In);
        end
    end
    
end

