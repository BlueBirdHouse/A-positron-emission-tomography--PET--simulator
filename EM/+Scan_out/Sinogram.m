classdef Sinogram < handle
    %Sinogram 正弦图
    %   PETCT扫面以后，就会生成这个类
    
    properties
        %与正弦图伴随而生的观测矩阵(IRT工具箱原版).
        G_;
        %没有噪声的观测(IRT工具箱原版).
        ytrue_;
        %对泊松分布均值扰动的随机数
        ri_;
        %有噪声的观测(IRT工具箱原版).
        yi_
        
        
        %清晰的原始图像
        True_Figure;
        
        %图像的衰减模型
        Mumap_Figure;
        
        %控制系统相关滤波技术所使用的状态
        %注意，这个状态是Mask以后的状态。
        X;
        %控制系统相关滤波技术所使用的观测矩阵
        C;
        %控制系统相关滤波技术所使用的观测矩阵
        Y_Poisson;
        
        
    end
    
    methods
        function obj = Sinogram()

        end
        
        function [] = AdoptControl(obj,ci)
            %这里生成控制系统理论需要的系统状态X。
            obj.X = obj.fatrix2_masker(obj.G_.arg.imask, obj.G_.arg.idim, obj.True_Figure);
            
            %这里生成控制系统理论需要的观测矩阵C。
            obj.C = obj.G_.arg.matrix;
            [ci_m,ci_n] = size(ci);
            ci = reshape(ci,ci_m*ci_n,1);
            obj.C = full(obj.C);
            obj.C = ci.* obj.C;
            
            %这里生成控制系统理论需要的有噪声的观测Y。
            [yi_m,yi_n] = size(obj.yi_);
            obj.Y_Poisson = reshape(obj.yi_, yi_m*yi_n, 1);
        end
        

    end
    
    methods(Static)
        function z = fatrix2_masker(mask, dim, x)
            if isempty(mask)
                z = x(:);
            else
                z = x(mask);
            end
        end
        function [x_Out] = RemoveMask(x_In,Image_Info)
            %由于参与滤波的状态是被Mask以后的状态，这里将这些状态还原为原来的图片
            x_Out = Image_Info.embed(x_In);
        end
    end
end
