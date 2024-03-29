%% Getting the hard coded reference shape functions for the FEM object

% IMPORTANT: The triangular reference element is different than the one
% used in Gypsilab.

%-------------------------------------------------------------------------%
% Ignacio:
% To Do  : Differential operators: grad(P1), Ned, RWG, div(RWG), etc.
% Example: fe.opr == 'grad[psi]'
%-------------------------------------------------------------------------%

function rsfs = femRSF(fe)
    % Getting the type of FE space
    typ = fe.typ;
    opr = fe.opr;
    mesh = fe.msh;
    
    elt_type = size(mesh.elt,2);
    
    if elt_type == 2
        switch typ
            case 'P0'
                rsfs = cell(1,1);
                rsfs{1} = @(X) 1;
            case 'P1'
                rsfs = cell(2,1);
                rsfs{1} = @(X) 0.5 * (1+X); % support at 1
                rsfs{2} = @(X) 0.5 * (1-X); % support at -1
        end
       
    % Triangle
    elseif elt_type == 3
       switch typ
            case 'P0'
                rsfs = cell(1,1);
                rsfs{1} = @(X) 1;
            case 'P1'
                
                switch opr
                   
                    case '[psi]'
                        rsfs = cell(3,1);
                        rsfs{1} = @(X) 1 - X(:,1) - X(:,2);
                        rsfs{2} = @(X) X(:,1);
                        rsfs{3} = @(X) X(:,2);
%                         rsfs{1} = @(X) 1 - X(:,1); % support at 0,0 or A
%                         rsfs{2} = @(X) X(:,1) - X(:,2); % support at 1,0 or B
%                         rsfs{3} = @(X) X(:,2); % support at 1,1 or C
                        
                    case 'n*[psi]'
                        rsfs = cell(3,1);
                        rsfs{1} = @(X) 1 - X(:,1) - X(:,2) ; 
                        rsfs{2} = @(X) X(:,1); 
                        rsfs{3} = @(X) X(:,2); 
                        
                    case 'grad[psi]'
                        
                        rsfs = cell(3,1);
                        
                        rsfs{1} = cell(2, 1);
                        rsfs{2} = cell(2, 1);
                        rsfs{3} = cell(2, 1);
                        
                        rsfs{1}{1} = @(X) -1;
                        rsfs{1}{2} = @(X) -1;
                        
                        
                        rsfs{2}{1} = @(X) 1;
                        rsfs{2}{2} = @(X) 0;
                        
                        
                        rsfs{3}{1} = @(X) 0;
                        rsfs{3}{2} = @(X) 1;
                        
                    case 'nxgrad[psi]'
                        
                        rsfs = cell(3,1);
                        
                        rsfs{1} = cell(2, 1);
                        rsfs{2} = cell(2, 1);
                        rsfs{3} = cell(2, 1);
                        
                        rsfs{1}{1} = @(X) -1;
                        rsfs{1}{2} = @(X) -1;
                        
                        
                        rsfs{2}{1} = @(X) 1;
                        rsfs{2}{2} = @(X) 0;
                        
                        
                        rsfs{3}{1} = @(X) 0;
                        rsfs{3}{2} = @(X) 1;
                        
                
                end
                
           case 'P2'
               switch opr
                   
                   case '[psi]'
                       rsfs = cell(6, 1);
                       
                       rsfs{1} = @(X) (1 - X(:,1) - X(:,2)) .* (1 - 2*X(:,1) - 2*X(:,2));
                       rsfs{2} = @(X) X(:,1) .* (2*X(:, 1) -1);
                       rsfs{3} = @(X) X(:,2) .* (2*X(:, 2) -1);
                       rsfs{4} = @(X) 4 * X(:, 1) .* X(:, 2);
                       rsfs{5} = @(X) 4 * X(:, 2) .* (1 - X(:,1) - X(:,2));
                       rsfs{6} = @(X) 4 * X(:, 1) .* (1 - X(:,1) - X(:,2));
               end
           case 'RWG'
               
               switch opr
                   case '[psi]'
                       
                       
                        rsfs = cell(3,1);
                        
                        rsfs{1} = cell(2, 1);
                        rsfs{2} = cell(2, 1);
                        rsfs{3} = cell(2, 1);
                        
                        rsfs{1}{1} = @(X) X(:, 1);
                        rsfs{1}{2} = @(X) X(:, 2);
                        
                        
                        rsfs{2}{1} = @(X) X(:, 1) - 1;
                        rsfs{2}{2} = @(X) X(:, 2);
                        
                        
                        rsfs{3}{1} = @(X) X(:, 1) - 1;
                        rsfs{3}{2} = @(X) X(:, 2) - 1;
                       
                       
                   case 'div[psi]'
                   
               end
       end
    
    % Tetrahedron
    elseif elt_type == 4
        switch typ
            case 'P0'
                rsfs = cell(1,1);
                rsfs{1} = @(X) 1;
                
            case 'P1'
                
                
                switch opr
                    
                    case '[psi]'

                        
                    rsfs = cell(4,1);
                    rsfs{1} = @(X) 1 - X(:,1) - X(:,2) - X(:,3);% (0,0,0)     
                    rsfs{2} = @(X) X(:,1); % (1,0,0)
                    rsfs{3} = @(X) X(:,2); % (0,1,0)
                    rsfs{4} = @(X) X(:,3); % (0,0,1)
                    
%                     rsfs = cell(4,1);
%                     rsfs{1} = @(X) 1 - X(:,1);           % (0,0,0)     
%                     rsfs{2} = @(X) X(:,1) - X(:,2) - X(:,3); % (1,0,0)
%                     rsfs{3} = @(X) X(:,2);               % (1,1,0)
%                     rsfs{4} = @(X) X(:,3);               % (1,0,1)
                    
                    case 'grad[psi]'

                        
                    rsfs = cell(4,1);

                    rsfs{1} = cell(3, 1);
                    rsfs{2} = cell(3, 1);
                    rsfs{3} = cell(3, 1);
                    rsfs{4} = cell(3, 1);
                    
                    
                    rsfs{1}{1} = @(X) -1;
                    rsfs{1}{2} = @(X) -1;
                    rsfs{1}{3} = @(X) -1;


                    rsfs{2}{1} = @(X) 1;
                    rsfs{2}{2} = @(X) 0;
                    rsfs{2}{3} = @(X) 0;


                    rsfs{3}{1} = @(X) 0;
                    rsfs{3}{2} = @(X) 1;
                    rsfs{3}{3} = @(X) 0;
                    
                    
                    rsfs{4}{1} = @(X) 0;
                    rsfs{4}{2} = @(X) 0;
                    rsfs{4}{3} = @(X) 1;
% 
%                     rsfs{1}{1} = @(X) -1;
%                     rsfs{1}{2} = @(X) 0;
%                     rsfs{1}{3} = @(X) 0;
% 
% 
%                     rsfs{2}{1} = @(X) 1;
%                     rsfs{2}{2} = @(X) -1;
%                     rsfs{2}{3} = @(X) -1;
% 
% 
%                     rsfs{3}{1} = @(X) 0;
%                     rsfs{3}{2} = @(X) 1;
%                     rsfs{3}{3} = @(X) 0;
%                     
%                     
%                     rsfs{4}{1} = @(X) 0;
%                     rsfs{4}{2} = @(X) 0;
%                     rsfs{4}{3} = @(X) 1;
                end
                
            case 'P2'
                
                switch opr
                    
                    case '[psi]'
                        
                       rsfs = cell(10, 1);
                       
                       rsfs{1} = @(X) (1 - X(:,1) - X(:,2) - X(:, 3)) .* (1 - 2*X(:,1) - 2*X(:,2) - 2*X(:, 3));
                       rsfs{2} = @(X) X(:,1) .* (2*X(:, 1) -1);
                       rsfs{3} = @(X) X(:,2) .* (2*X(:, 2) -1);
                       rsfs{4} = @(X) X(:,3) .* (2*X(:, 3) -1);
                       rsfs{5} = @(X) 4 * X(:, 1) .* (1 - X(:,1) - X(:,2) - X(:, 3));
                       rsfs{6} = @(X) 4 * X(:, 1) .* X(:, 2);
                       rsfs{7} = @(X) 4 * X(:, 2) .* (1 - X(:,1) - X(:,2) - X(:, 3));
                       rsfs{8} = @(X) 4 * X(:, 1) .* X(:, 3);
                       rsfs{9} = @(X) 4 * X(:, 3) .* (1 - X(:,1) - X(:,2) - X(:, 3));
                       rsfs{10} = @(X) 4 * X(:, 2) .* X(:, 3);
                        
                end
                    
                
            case 'RWG'
                
                switch opr
                    case '[psi]'
                        
                                                

                    rsfs = cell(4,1);

                    rsfs{1} = cell(3, 1);
                    rsfs{2} = cell(3, 1);
                    rsfs{3} = cell(3, 1);
                    rsfs{4} = cell(3, 1);

                    rsfs{1}{1} = @(X) X(:, 1);
                    rsfs{1}{2} = @(X) X(:, 2);
                    rsfs{1}{3} = @(X) X(:, 3);


                    rsfs{2}{1} = @(X) X(:, 1) - 1;
                    rsfs{2}{2} = @(X) X(:, 2);
                    rsfs{2}{3} = @(X) X(:, 3);


                    rsfs{3}{1} = @(X) X(:, 1) - 1;
                    rsfs{3}{2} = @(X) X(:, 2) - 1;
                    rsfs{3}{3} = @(X) X(:, 3);
                    
                    
                    rsfs{4}{1} = @(X) X(:, 1) - 1;
                    rsfs{4}{2} = @(X) X(:, 2);
                    rsfs{4}{3} = @(X) X(:, 3) - 1;

                        
                    case 'div[psi]'
                        
                        
                end
        end
    end
end
