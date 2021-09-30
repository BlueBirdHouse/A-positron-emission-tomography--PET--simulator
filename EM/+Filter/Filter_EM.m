classdef Filter_EM < handle
    %Filter_EM EM算法滤波
    %   使用IRT工具箱内置的EM算法滤波
    
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
            %由于参与滤波的状态是被Mask以后的状态，这里将这些状态还原为原来的图片
            x_Out = Image_Info.embed(x_In);
        end
    end
    
end

