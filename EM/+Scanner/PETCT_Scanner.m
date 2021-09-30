classdef PETCT_Scanner < handle
    %PETCT_Scanner 模拟一台真实的PET-CT机
    %   模拟一台真实的PET-CT机
    
    properties
        % image dimension(像素尺寸)
        % image dimension (default: nx)
        nx = 64;
        ny = 60;
        
        %mask的尺寸
        mx = 220;
        my = 180;
        
        % pixel size
        dx = 500/64;
        
        %图像相关数据的结构体
        Image_Info;
        %正弦图相关数据的结构体
        Sino_Info;
        %正弦图（扫描以后的结果）
        Sino;  
        
        %用来存储一些常量
        f = struct('count',1e5,'randpercent',1e-16);
        %形成对观测矩阵G的扰动作用。
        ci_
        %对泊松分布均值的扰动。
        ri_
        
        %调试用属性
        %proj;
        %li;
    end
    
    methods
        function obj = PETCT_Scanner(In_nx,In_ny,In_mx,In_my)
            %% 生成一个PET-CT机
            if(isempty(In_nx))
            else
                obj.nx = In_nx;
            end
            if(isempty(In_ny))
            else
                obj.ny = In_ny;
            end
            if(isempty(In_mx))
            else
                obj.mx = In_mx;
            end
            if(isempty(In_my))
            else
                obj.my = In_my;
            end
            
            obj.Image_Info = image_geom('nx', obj.nx, 'ny', obj.ny, 'dx', 500/64);
            obj.Sino = Scan_out.Sinogram();
            obj.Sino.Mumap_Figure = read_zubal_attn('nx', obj.Image_Info.nx, 'ny', obj.Image_Info.ny);
            obj.Image_Info.mask = obj.Image_Info.circ(obj.mx, obj.my) > 0;
            obj.Sino_Info = sino_geom('par', 'nb', obj.Image_Info.nx+2, 'na', obj.Image_Info.ny*3/2,'dr', 528 / (obj.Image_Info.nx+2));
            
        end
        
        function [ScanSino] = MakeScan(obj)
            %% 要求虚拟的CT机做一次扫描
            obj.Sino.True_Figure = read_zubal_emis('nx', obj.Image_Info.nx, 'ny', obj.Image_Info.ny);
            obj.Sino.G_ = Gtomo2_strip(obj.Sino_Info, obj.Image_Info, 'single', 1);
            %生成没有噪声的观测
            G = obj.Sino.G_;
            xtrue = obj.Sino.True_Figure;
            mumap = obj.Sino.Mumap_Figure;
            
            proj = G * xtrue;
            li = G * mumap;
            ci = exp(0.3 * randn(size(proj)));
            ci = ci .* exp(-li);
            ci = obj.f.count / sum(ci(:) .* proj(:)) * ci;
            obj.ci_ = ci;
            %这一句话可能没必要。
            %ci = dsingle(ci);
            ytrue = obj.ci_ .* proj;
            obj.Sino.ytrue_ = ytrue;
            
            %生成有噪声的观测
            ri = obj.f.randpercent / 100 * mean(ytrue(:)) * obj.Sino_Info.ones;
            obj.ri_ = ri;
            %当做某些不假设泊松分布均值的研究时，这个扰动真值可以还原真实的泊松分布均值。
            obj.Sino.ri_ = ri;
            %暂时使用工具箱的泊松分布函数，随后替换为Matlab的可靠版本。(已经替换)
            %yi = poisson(ytrue + obj.ri_);
            yi = poissrnd(ytrue + obj.ri_);
            obj.Sino.yi_ = yi;
            
            %生成控制系统滤波理论需要的参数。
            obj.Sino.AdoptControl(obj.ci_);
            %测试转换以后的可靠性
            obj.TestControlOutPut(obj.Sino.C,obj.Sino.X,obj.Sino.ytrue_,obj.Sino.yi_,obj.Sino.Y_Poisson);
            
            %输出
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
        
        function [] = TestControlOutPut(C,X,ytrue_,yi,Y_Poisson)
            %% 针对控制系统理论的转换方法并不可靠，这个函数用于在每一次
            %转换完成以后，核对转换的准确性并给出提示。
            y = C * X;
            [ytrue_m,ytrue_n] = size(ytrue_);
            y_Test = reshape(ytrue_,ytrue_m*ytrue_n,1);
            Residual = max(max(abs(y_Test-y)));
            if(Residual > 1e-6)
                Str = '为控制理论转换以后，真实输出参数误差过大！误差为：';
                warning(strcat(Str,num2str(Residual)));
            end
            
            Y_Poisson = reshape(Y_Poisson,ytrue_m,ytrue_n);
            Residual = max(max(abs(Y_Poisson-yi)));
            if(Residual > 1e-6)
                Str = '为控制理论转换以后，有噪声的输出参数误差过大！误差为：';
                warning(strcat(Str,num2str(Residual)));
            end
        end
    end
end

