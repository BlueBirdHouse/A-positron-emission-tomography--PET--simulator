classdef Sinogram < handle
    %Sinogram ����ͼ
    %   PETCTɨ���Ժ󣬾ͻ����������
    
    properties
        %������ͼ��������Ĺ۲����(IRT������ԭ��).
        G_;
        %û�������Ĺ۲�(IRT������ԭ��).
        ytrue_;
        %�Բ��ɷֲ���ֵ�Ŷ��������
        ri_;
        %�������Ĺ۲�(IRT������ԭ��).
        yi_
        
        
        %������ԭʼͼ��
        True_Figure;
        
        %ͼ���˥��ģ��
        Mumap_Figure;
        
        %����ϵͳ����˲�������ʹ�õ�״̬
        %ע�⣬���״̬��Mask�Ժ��״̬��
        X;
        %����ϵͳ����˲�������ʹ�õĹ۲����
        C;
        %����ϵͳ����˲�������ʹ�õĹ۲����
        Y_Poisson;
        
        
    end
    
    methods
        function obj = Sinogram()

        end
        
        function [] = AdoptControl(obj,ci)
            %�������ɿ���ϵͳ������Ҫ��ϵͳ״̬X��
            obj.X = obj.fatrix2_masker(obj.G_.arg.imask, obj.G_.arg.idim, obj.True_Figure);
            
            %�������ɿ���ϵͳ������Ҫ�Ĺ۲����C��
            obj.C = obj.G_.arg.matrix;
            [ci_m,ci_n] = size(ci);
            ci = reshape(ci,ci_m*ci_n,1);
            obj.C = full(obj.C);
            obj.C = ci.* obj.C;
            
            %�������ɿ���ϵͳ������Ҫ���������Ĺ۲�Y��
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
            %���ڲ����˲���״̬�Ǳ�Mask�Ժ��״̬�����ｫ��Щ״̬��ԭΪԭ����ͼƬ
            x_Out = Image_Info.embed(x_In);
        end
    end
end
