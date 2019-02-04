function []= showACF(handles)

%% Set parameters
Nlags = 15;

temporary = get(handles.table, 'data');
data.PixelTime = temporary(:,1) .* 10^(-6);
data.LineTime = temporary(:,2) .* 10^(-3);

data.SimTime = str2double(get(handles.SimTime,'string'));
data.Concentration = str2double(get(handles.Concentration,'string'));
data.PixelSize = str2double(get(handles.PixelSize,'string')) .* 10^(-3);

data.NX = str2double(get(handles.NX,'string'));
data.NY = str2double(get(handles.NY,'string'));

data.NImages = str2double(get(handles.NImages,'string'));
data.Brightness = str2double(get(handles.Brightness,'string')) .* 10^(3);
data.NRep = str2double(get(handles.NRep,'string'));
data.D = str2double(get(handles.D,'string'));
data.wr = str2double(get(handles.wr,'string')) .* 10^(-3);
data.wz = str2double(get(handles.wz,'string')) .* 10^(-3);
data.CovarianceTot = handles.CovarianceTot;


alpha = data.wz / data.wr; %ratio between axial and lateral waist

if alpha == Inf
    V = ( data.NX * data.PixelSize + 2 ) * ( data.NY * data.PixelSize + 2 );
    omega = pi*data.wr^2;
else
    V = ( data.NX * data.PixelSize + 2 ) * ( data.NY * data.PixelSize + 2 ) * ( (data.NX+data.NY)/2 * data.PixelSize );
    omega = pi^(3/2)*data.wr^3*alpha;
end

M = str2double(get(handles.NParticles,'string'));

%% Plotting section

plotflag = 1 + ( numel(data.PixelTime) >= 10 ); 
[ X, Y ] = meshgrid ( 0 : Nlags, 0 : Nlags );

switch plotflag
    
    case 1
        axes(handles.ax3)
        cla
        hold on
        axes(handles.ax4)
        cla
        hold on
        CM = jet(numel(data.PixelTime));
        
        for indtp = 1 : numel(data.PixelTime)
            
            Tp = data.PixelTime( indtp );
            Tl = data.LineTime( indtp );
            
            if alpha == Inf
                q = data.Brightness * Tp;
                m = M * omega / V;
            else
                beta = 1/alpha^2;
                tauc = data.wr^2/(4*data.D);
                fact = ( 1 + beta * Tp / tauc ) ^ 0.5;
                q = data.Brightness * 4 * tauc^2 * ( beta * ( 1 + Tp/tauc ) * atanh( (1-beta)^0.5 * ( fact - 1 ) / ( beta + fact - 1 ) ) - (1-beta)^0.5*( fact - 1 )  ) / ( Tp * beta * (1-beta)^0.5 );
                Mapp = M * data.Brightness * Tp / q;
                m = Mapp * omega / V;
            end
            
            

            Coeff = ones( Nlags+1, Nlags+1, 4 );
            Coeff(:,:,1) = - ( ( data.PixelSize*X' ).^2 + ( data.PixelSize*Y' ).^2 ) / data.wr^2;
            Coeff(:,:,2) = 4 * abs( Tp*X'  + Tl*Y' ) / data.wr^2;
            Coeff(:,:,3) = 4 * abs( Tp*X'  + Tl*Y' ) / data.wz^2;
            
            
            
            acfprova = RICS_CorrFun([data.D (1/m) 0], Coeff);
            axes(handles.ax3)
            h2=plot( 1:Nlags , acfprova( 2:end , 1 ), 'color', CM(indtp,:));
            axes(handles.ax4)
            h4=plot( 1:Nlags , acfprova( 1 , 2:end ), 'color', CM(indtp,:) );
            
            legendInfo{indtp} = [string(data.PixelTime(indtp)*10^6)];
            legendInfo1{indtp} = [string(data.LineTime(indtp)*10^3)];
            
        end
        
        m = M * omega / V;
        PSF = RICS_CorrFun([0 (1/m) 0], Coeff);
        axes(handles.ax3)
        h5=plot( 1:Nlags , PSF( 1 , 2:end ) , 'm');
        legendInfo{end+1} = ['PSF'];
        ylabel('G(\xi,0)','Color','White')
        xlabel('lag (number of pixel)','Color','White')
        hleg=legend(legendInfo);
        title(hleg,'\tau_p (\mus)')
        
        axes(handles.ax4)
        h5=plot( 1:Nlags , PSF( 1 , 2:end ) , 'm');
        ylabel('G(0,\psi)','Color','White')
        xlabel('lag (number of pixel)','Color','White')
        hleg=legend(legendInfo1);
        title(hleg,'\tau_l (ms)')
        
    case 2
        
        axes(handles.ax3)
        cla
        hold on
        axes(handles.ax4)
        cla
        hold on
        
        [~ , MSRE_minimizer] = min(handles.MSRE);
        
        Tp = data.PixelTime( MSRE_minimizer );
        Tl = data.LineTime( MSRE_minimizer );
        
        if alpha == Inf
            q = data.Brightness * Tp;
            m = M * omega / V;
        else
            beta = 1/alpha^2;
            tauc = data.wr^2/(4*data.D);
            fact = ( 1 + beta * Tp / tauc ) ^ 0.5;
            q = data.Brightness * 4 * tauc^2 * ( beta * ( 1 + Tp/tauc ) * atanh( (1-beta)^0.5 * ( fact - 1 ) / ( beta + fact - 1 ) ) - (1-beta)^0.5*( fact - 1 )  ) / ( Tp * beta * (1-beta)^0.5 );
            Mapp = M * data.Brightness * Tp / q;
            m = Mapp * omega / V;
        end
        
        Coeff = ones( Nlags+1, Nlags+1, 4 );
        Coeff(:,:,1) = - ( ( data.PixelSize*X' ).^2 + ( data.PixelSize*Y' ).^2 ) / data.wr^2;
        Coeff(:,:,2) = 4 * abs( Tp*X'  + Tl*Y' ) / data.wr^2;
        Coeff(:,:,3) = 4 * abs( Tp*X'  + Tl*Y' ) / data.wz^2;
        
        
        
        acfprova = RICS_CorrFun([data.D (1/m) 0], Coeff);
        axes(handles.ax3)
        h2=plot( 1:Nlags , acfprova( 2:end , 1 ), 'color', 'k');
        axes(handles.ax4)
        h4=plot( 1:Nlags , acfprova( 1 , 2:end ), 'color', 'k' );
        
        legendInfo{1} = [strcat('[',string(data.PixelTime(MSRE_minimizer)*10^6) ,',',string(data.LineTime(MSRE_minimizer)*10^3), ']' , ' (best)')];
        
        
        
        [~ , MSRE_maximizer] = max(handles.MSRE);
        
        Tp = data.PixelTime( MSRE_maximizer );
        Tl = data.LineTime( MSRE_maximizer );
        
        if alpha == Inf
            q = data.Brightness * Tp;
            m = M * omega / V;
        else
            beta = 1/alpha^2;
            tauc = data.wr^2/(4*data.D);
            fact = ( 1 + beta * Tp / tauc ) ^ 0.5;
            q = data.Brightness * 4 * tauc^2 * ( beta * ( 1 + Tp/tauc ) * atanh( (1-beta)^0.5 * ( fact - 1 ) / ( beta + fact - 1 ) ) - (1-beta)^0.5*( fact - 1 )  ) / ( Tp * beta * (1-beta)^0.5 );
            Mapp = M * data.Brightness * Tp / q;
            m = Mapp * omega / V;
        end
        
        Coeff = ones( Nlags+1, Nlags+1, 4 );
        Coeff(:,:,1) = - ( ( data.PixelSize*X' ).^2 + ( data.PixelSize*Y' ).^2 ) / data.wr^2;
        Coeff(:,:,2) = 4 * abs( Tp*X'  + Tl*Y' ) / data.wr^2;
        Coeff(:,:,3) = 4 * abs( Tp*X'  + Tl*Y' ) / data.wz^2;
        
        
        
        acfprova = RICS_CorrFun([data.D (1/m) 0], Coeff);
        axes(handles.ax3)
        h2=plot( 1:Nlags , acfprova( 2:end , 1 ), 'color', 'b');
        axes(handles.ax4)
        h4=plot( 1:Nlags , acfprova( 1 , 2:end ), 'color', 'b' );
        
        legendInfo{2} = [strcat('[',string(data.PixelTime(MSRE_maximizer)*10^6) ,',',string(data.LineTime(MSRE_maximizer)*10^3), ']' , ' (worst)')];
        
        m = M * omega / V;
        PSF = RICS_CorrFun([0 (1/m) 0], Coeff);
        axes(handles.ax3)
        h5=plot( 1:Nlags , PSF( 1 , 2:end ) , 'm');
        legendInfo{end+1} = ['PSF'];
        ylabel('G(\xi,0)','Color','White')
        xlabel('lag (number of pixel)','Color','White')
        hleg=legend(legendInfo);
        title(hleg,'[\tau_p,\tau_l]')
        
        axes(handles.ax4)
        h5=plot( 1:Nlags , PSF( 1 , 2:end ) , 'm');
        ylabel('G(0,\psi)','Color','White')
        xlabel('lag (number of pixel)','Color','White')
        hleg=legend(legendInfo);
        title(hleg,'[\tau_p,\tau_l]')
        
        
end