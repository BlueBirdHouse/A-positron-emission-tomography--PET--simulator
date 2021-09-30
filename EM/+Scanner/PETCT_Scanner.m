classdef PETCT_Scanner < handle
    %PETCT_Scanner ģ��һ̨��ʵ��PET-CT��
    %   ģ��һ̨��ʵ��PET-CT��
    
    properties
        % image dimension(���سߴ�)
        % image dimension (default: nx)
        nx = 64;
        ny = 60;
        
        %mask�ĳߴ�
        mx = 220;
        my = 180;
        
        % pixel size
        dx = 500/64;
        
        %ͼ��������ݵĽṹ��
        Image_Info;
        %����ͼ������ݵĽṹ��
        Sino_Info;
        %����ͼ��ɨ���Ժ�Ľ����
        Sino;  
        
        %�����洢һЩ����
        f = struct('count',1e5,'randpercent',1e-16);
        %�γɶԹ۲����G���Ŷ����á�
        ci_
        %�Բ��ɷֲ���ֵ���Ŷ���
        ri_
        
        %����������
        %proj;
        %li;
    end
    
    methods
        function obj = PETCT_Scanner(In_nx,In_ny,In_mx,In_my)
            %% ����һ��PET-CT��
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
            %% Ҫ�������CT����һ��ɨ��
            obj.Sino.True_Figure = read_zubal_emis('nx', obj.Image_Info.nx, 'ny', obj.Image_Info.ny);
            obj.Sino.G_ = Gtomo2_strip(obj.Sino_Info, obj.Image_Info, 'single', 1);
            %����û�������Ĺ۲�
            G = obj.Sino.G_;
            xtrue = obj.Sino.True_Figure;
            mumap = obj.Sino.Mumap_Figure;
            
            proj = G * xtrue;
            li = G * mumap;
            ci = exp(0.3 * randn(size(proj)));
            ci = ci .* exp(-li);
            ci = obj.f.count / sum(ci(:) .* proj(:)) * ci;
            obj.ci_ = ci;
            %��һ�仰����û��Ҫ��
            %ci = dsingle(ci);
            ytrue = obj.ci_ .* proj;
            obj.Sino.ytrue_ = ytrue;
            
            %�����������Ĺ۲�
            ri = obj.f.randpercent / 100 * mean(ytrue(:)) * obj.Sino_Info.ones;
            obj.ri_ = ri;
            %����ĳЩ�����貴�ɷֲ���ֵ���о�ʱ������Ŷ���ֵ���Ի�ԭ��ʵ�Ĳ��ɷֲ���ֵ��
            obj.Sino.ri_ = ri;
            %��ʱʹ�ù�����Ĳ��ɷֲ�����������滻ΪMatlab�Ŀɿ��汾��(�Ѿ��滻)
            %yi = poisson(ytrue + obj.ri_);
            yi = poissrnd(ytrue + obj.ri_);
            obj.Sino.yi_ = yi;
            
            %���ɿ���ϵͳ�˲�������Ҫ�Ĳ�����
            obj.Sino.AdoptControl(obj.ci_);
            %����ת���Ժ�Ŀɿ���
            obj.TestControlOutPut(obj.Sino.C,obj.Sino.X,obj.Sino.ytrue_,obj.Sino.yi_,obj.Sino.Y_Poisson);
            
            %���
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
        
        function [] = TestControlOutPut(C,X,ytrue_,yi,Y_Poisson)
            %% ��Կ���ϵͳ���۵�ת�����������ɿ����������������ÿһ��
            %ת������Ժ󣬺˶�ת����׼ȷ�Բ�������ʾ��
            y = C * X;
            [ytrue_m,ytrue_n] = size(ytrue_);
            y_Test = reshape(ytrue_,ytrue_m*ytrue_n,1);
            Residual = max(max(abs(y_Test-y)));
            if(Residual > 1e-6)
                Str = 'Ϊ��������ת���Ժ���ʵ����������������Ϊ��';
                warning(strcat(Str,num2str(Residual)));
            end
            
            Y_Poisson = reshape(Y_Poisson,ytrue_m,ytrue_n);
            Residual = max(max(abs(Y_Poisson-yi)));
            if(Residual > 1e-6)
                Str = 'Ϊ��������ת���Ժ�������������������������Ϊ��';
                warning(strcat(Str,num2str(Residual)));
            end
        end
    end
end

