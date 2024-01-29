
% COUPLED SYSTEM COSTABEL


function [uh, phih, uext] = solve_CVIE(m_Gamma, m_Omega, pts, k0, kx, a0, ax, grad_ax, typ, tol, theta)



Omega = dom(m_Omega, 3);
Gamma = dom(m_Gamma, 3);


Vh = fem(m_Omega, typ);

beta = @(X) kx(X).^2 - k0^2;
alpha = @(X) ax(X) - a0;

G = @(X, Y) femGreenKernel(X, Y, '[H0(kr)]', k0);


dxGxy{1} = @(X,Y) femGreenKernel(X, Y, 'gradx[H0(kr)]1', k0);
dxGxy{2} = @(X,Y) femGreenKernel(X, Y, 'gradx[H0(kr)]2', k0);
dxGxy{3} = @(X,Y) femGreenKernel(X, Y, 'gradx[H0(kr)]3', k0);


comm_dxGxy{1} = @(X,Y) (ax(Y) - ax(X)) .* femGreenKernel(X, Y, 'gradx[H0(kr)]1', k0);
comm_dxGxy{2} = @(X,Y) (ax(Y) - ax(X)) .* femGreenKernel(X, Y, 'gradx[H0(kr)]2', k0);
comm_dxGxy{3} = @(X,Y) (ax(Y) - ax(X)) .* femGreenKernel(X, Y, 'gradx[H0(kr)]3', k0);

uinc = @(X) exp(1i*k0*(cos(theta)*X(:,1) +sin(theta)*X(:,2)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Newton Potential Beta u

K = (1i/4) * integral(Omega, Omega,  Vh, G, Vh, tol);
Kreg = -(1/(2 * pi)) * regularize(Omega,Omega,Vh,'[log(r)]',Vh);

I = integral(Omega, Vh, Vh);

aI = integral(Omega, Vh, ax, Vh);

F = integral(Omega, Vh, uinc);


dim = size(m_Omega.vtx, 1);
Beta = spdiags(beta(m_Omega.vtx), 0, dim, dim); 

Alpha = spdiags(alpha(m_Omega.vtx), 0, dim, dim);

DxAlpha = spdiags(grad_ax{1}(m_Omega.vtx), 0, dim, dim); 
DyAlpha = spdiags(grad_ax{2}(m_Omega.vtx), 0, dim, dim); 
DzAlpha = spdiags(grad_ax{3}(m_Omega.vtx), 0, dim, dim); 





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Divergence of Newton Potential (grad alpha) u
Mv = femLagrangePn(Vh, Omega);


[~,Pv] = Vh.unk;   

Mv = Mv * Pv;

[Xq, Wq, ~] = Omega.qud; 

Wq = spdiags(Wq, 0, size(Wq, 1), size(Wq, 1));

dyGxy{1} = @(X,Y) femGreenKernel(X, Y, 'grady[H0(kr)]1', k0);
dyGxy{2} = @(X,Y) femGreenKernel(X, Y, 'grady[H0(kr)]2', k0);
dyGxy{3} = @(X,Y) femGreenKernel(X, Y, 'grady[H0(kr)]3', k0);

divK = integral(Xq, Omega, dyGxy, Vh, tol);

divK{1} = (1i/4) * divK{1};
divK{2} = (1i/4) * divK{2};

reg{1} = -(1/(2 * pi)) * regularize(Xq, Omega, 'grady[log(r)]1',Vh);
reg{2} = -(1/(2 * pi)) * regularize(Xq, Omega, 'grady[log(r)]2',Vh);

divA = -Mv' * Wq * (divK{1} + reg{1}) * DxAlpha - Mv' * Wq * (divK{2} + reg{2}) * DyAlpha;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

A = -(K + Kreg) * Beta + ...
     k0^2 * (K + Kreg) * Alpha + ...
     divA;

    

[~, D] = build_potentials(m_Gamma, m_Omega, k0);
dim_gamma = size(m_Gamma.vtx, 1);
traceAlpha = spdiags(alpha(m_Gamma.vtx), 0, dim_gamma, dim_gamma);

Matrix = [aI+A -D*traceAlpha];



%%%%%%%%%%%%%%%%%%% Trace Equation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Vn = fem(m_Gamma, 'P0');
Ud = fem(m_Gamma, 'P1');

Mv = femLagrangePn(Vn, Gamma); 
Mu = femLagrangePn(Ud, Gamma); 

[~,Pv] = Vn.unk;   
[~,Pu] = Ud.unk;
Mv = Mv * Pv;  
Mu = Mu * Pu;  


[Xq, Wq, ~] = Gamma.qud; 

Wq = spdiags(Wq, 0, size(Wq, 1), size(Wq, 1));
% disp('Assembly of Dirichlet Trace');

K = (1i/4) * integral(Xq, Omega, G, Vh, tol);
Kreg = -(1/(2 * pi)) * regularize(Xq, Omega, '[log(r)]',Vh);


Kdir = -Mv' * Wq * (K + Kreg) * Beta + k0^2 * Mv' * Wq * (K + Kreg) * Alpha;



divKdir = integral(Xq, Omega, dyGxy, Vh, tol);

divKdir{1} = (1i/4) * divKdir{1};
divKdir{2} = (1i/4) * divKdir{2};

reg{1} = -(1/(2 * pi)) * regularize(Xq, Omega, 'grady[log(r)]1',Vh);
reg{2} = -(1/(2 * pi)) * regularize(Xq, Omega, 'grady[log(r)]2',Vh);

divKdir = -Mv' * Wq * (divKdir{1} + reg{1}) * DxAlpha - Mv' * Wq * (divKdir{2} + reg{2}) * DyAlpha;

Adir = divKdir + Kdir;





Vh = fem(m_Gamma, 'P0');
Uh = fem(m_Gamma, 'P1');

K = (1i/4) * integral(Gamma, Gamma, Vh, dyGxy, ntimes(Uh));
K = K - 1/(2*pi) * regularize(Gamma, Gamma, Vh,'grady[log(r)]',ntimes(Uh));
Kalpha = K * traceAlpha;


I = integral(Gamma, Vh, Uh);
aI = integral(Gamma, Vh, ax, Uh);


Matrix = [Matrix; 
         Adir 0.5*(I + aI)-Kalpha];
     

Fdir = integral(Gamma, Vh, uinc);

F = [F; Fdir];


sol = Matrix \ F;



uh = sol(1:dim); sol(1:dim) = [];
phih = sol;



% Evaluates using Representation formula

Vh = fem(m_Omega, typ);

K = (1i/4) * integral(pts.vtx, Omega, G, Vh);
Kreg = -(1/(2 * pi)) * regularize(pts.vtx, Omega, '[log(r)]',Vh);

aux = uinc(pts.vtx);


uext = aux + (K + Kreg)* (Beta*uh);


K = (1i / 4) * integral(pts.vtx, Omega, dxGxy, grad(Vh), tol);
commK = (1i / 4) * integral(pts.vtx, Omega, comm_dxGxy, grad(Vh), tol);


reg = - 1 / (2 * pi) * regularize(pts.vtx, Omega, 'grady[log(r)]', grad(Vh));

m = size(pts.vtx, 1);
Alpha = spdiags(alpha(pts.vtx),0,m,m);



uext = uext + (Alpha * (K - reg) + commK) * uh;

end
