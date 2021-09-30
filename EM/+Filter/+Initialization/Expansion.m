function [x_Exp,P_Exp] = Expansion(x,P,PETCT,Sino,Scale)
%function [x_Exp,P_Exp] = Expansion(Image_Info,Sino,Scale)
    %MapMatrix是一个与原图一样大，并且内部包含唯一编号的矩阵。
    %Image_Info.nx = 5;
    %Image_Info.ny = 3;
    
    MapMatrix = [1:(PETCT.nx * PETCT.ny)]';
    MapMatrix = reshape(MapMatrix,PETCT.nx,PETCT.ny);
    
    %生成放大以后的地图和放大以后的Mask
    MapMatrix_Big = imresize(MapMatrix, Scale,'nearest');
    nx_Big = PETCT.nx*2;
    ny_Big = PETCT.ny*2;
    Image_Info_Big = image_geom('nx', nx_Big, 'ny', ny_Big, 'dx', 500/64);
    Image_Info_Big.mask = Image_Info_Big.circ(PETCT.mx*2, PETCT.my*2) > 0;
    Sino_Info_Big = sino_geom('par', 'nb', nx_Big+2, 'na', ny_Big*3/2,'dr', 528 / (nx_Big+2));
    G_Big = Gtomo2_strip(Sino_Info_Big, Image_Info_Big, 'single', 1);
    Mask_Big = G_Big.arg.imask;
    %Mask_Big = imresize(Sino.G_.arg.imask, Scale,'nearest');
    
    %生成经过Mask以后的大小两个版本地图
    Mask_MapMatrix = Scan_out.Sinogram.fatrix2_masker(Sino.G_.arg.imask, [], MapMatrix);
    Mask_MapMatrix_Big = Scan_out.Sinogram.fatrix2_masker(Mask_Big, [], MapMatrix_Big);
    
    %根据Map生成放大以后的x和P
    n = size(Mask_MapMatrix_Big,1);
    x_Exp = zeros(n,1);
    for i = 1:1:n
        Printer = find(Mask_MapMatrix == Mask_MapMatrix_Big(i),1);
        if(isempty(Printer))
            x_Exp(i) = 0;
        else
            x_Exp(i) = x(Printer);
        end
    end
    P_Exp = zeros(n,n);
    for i = 1:1:n
        Printer_x = find(Mask_MapMatrix == Mask_MapMatrix_Big(i),1);
        for j = 1:1:i
            Printer_y = find(Mask_MapMatrix == Mask_MapMatrix_Big(j),1);
            if(isempty(Printer_x) || isempty(Printer_y))
                P_Exp(i,j) = 0;
            else
                P_Exp(i,j) = P(Printer_x,Printer_y);
            end
            
        end
        i
    end
    P_Exp = tril(P_Exp,-1)' + P_Exp;
end