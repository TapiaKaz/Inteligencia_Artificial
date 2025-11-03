/*************************************
 *  SISTEMA DE CÁLCULO DE SECUENTES  *
 *  Generación de árboles en LaTeX   *
 *  CON CONTEXTOS COMPLETOS          *
*************************************/

%--------------------------------------
% DEFINICIÓN DE OPERADORES LÓGICOS
%--------------------------------------
:- op(1, fx, neg).    % Operador de negación (~)
:- op(2, xfx, or).    % Disyunción (∨)
:- op(2, xfx, and).   % Conjunción (∧)
:- op(2, xfx, imp).   % Implicación (→)
:- op(2, xfx, dimp).  % Doble implicación (↔)


%--------------------------------------
% PREDICADO PRINCIPAL
%--------------------------------------
checkExpression(Formula) :-
    write('\\documentclass{article}'), nl,
	write('\\usepackage{bussproofs}'), nl,
	write('\\usepackage{amsmath}'), nl,
    write('\\usepackage{amssymb}'), nl,
	write('\\usepackage[utf8]{inputenc}'), nl,
    write('\\usepackage{xcolor}'),nl,
	nl,
	write('% Definición de comandos para operadores lógicos'), nl,
	write('\\newcommand{\\NEG}{\\neg}'), nl,
	write('\\newcommand{\\AND}{\\land}'), nl,
	write('\\newcommand{\\OR}{\\lor}'), nl,
	write('\\newcommand{\\IMP}{\\rightarrow}'), nl,
	write('\\newcommand{\\DIMP}{\\leftrightarrow}'), nl,
	nl,
	write('\\begin{document}'), nl,
    write('\\begin{prooftree}'), nl,
    lpk([], [Formula], [], [], ArbolDerivacion),
    escribir_arbol(ArbolDerivacion),
    write('\\end{prooftree}'), nl,
	write('\\end{document}'), nl.

%--------------------------------------
% MOTOR DEL CÁLCULO DE SECUENTES
%--------------------------------------
% CAMBIO CLAVE: Ahora las estructuras incluyen VarsIzq y VarsDer

%--------------------------------------
% CASO BASE: Coincidencia entre ambos lados
%--------------------------------------
lpk([], [], [Var | RestoIzq], VarsDer, ArbolDerivacion) :-
    (member(Var, VarsDer) ->
        % CAMBIO: axioma ahora incluye los contextos completos
        ArbolDerivacion = axioma([Var], [Var], [Var], VarsDer)
    ;
        lpk([], [], RestoIzq, VarsDer, ArbolDerivacion)
    ).


%--------------------------------------
% VARIABLES ATÓMICAS
%--------------------------------------
lpk([Atom | RestoIzq], LadoDer, VarsIzq, VarsDer, ArbolDerivacion) :-
    atom(Atom),
    append([Atom], VarsIzq, NuevasVarsIzq),
    lpk(RestoIzq, LadoDer, NuevasVarsIzq, VarsDer, ArbolDerivacion).

lpk(LadoIzq, [Atom | RestoDer], VarsIzq, VarsDer, ArbolDerivacion) :-
    atom(Atom),
    append([Atom], VarsDer, NuevasVarsDer),
    lpk(LadoIzq, RestoDer, VarsIzq, NuevasVarsDer, ArbolDerivacion).


%--------------------------------------
% NEGACIÓN (¬)
%--------------------------------------
lpk([neg F | RestoIzq], LadoDer, VarsIzq, VarsDer, ArbolDerivacion) :-
    append([F], LadoDer, NuevoDer),
    lpk(RestoIzq, NuevoDer, VarsIzq, VarsDer, SubArbol),
    % CAMBIO: unaria ahora incluye los contextos
    ArbolDerivacion = unaria(SubArbol, [neg F | RestoIzq], LadoDer, VarsIzq, VarsDer, 'neg-izq').

lpk(LadoIzq, [neg F | RestoDer], VarsIzq, VarsDer, ArbolDerivacion) :-
    append([F], LadoIzq, NuevoIzq),
    lpk(NuevoIzq, RestoDer, VarsIzq, VarsDer, SubArbol),
    ArbolDerivacion = unaria(SubArbol, LadoIzq, [neg F | RestoDer], VarsIzq, VarsDer, 'neg-der').


%--------------------------------------
% DISYUNCIÓN (∨)
%--------------------------------------
lpk([F1 or F2 | RestoIzq], LadoDer, VarsIzq, VarsDer, ArbolDerivacion) :-
    append([F1], RestoIzq, Caso1),
    append([F2], RestoIzq, Caso2),
    lpk(Caso1, LadoDer, VarsIzq, VarsDer, SubArbol1),
    lpk(Caso2, LadoDer, VarsIzq, VarsDer, SubArbol2),
    % CAMBIO: binaria ahora incluye los contextos
    ArbolDerivacion = binaria(SubArbol1, SubArbol2, [F1 or F2 | RestoIzq], LadoDer, VarsIzq, VarsDer, 'or-izq').

lpk(LadoIzq, [F1 or F2 | RestoDer], VarsIzq, VarsDer, ArbolDerivacion) :-
    append([F1, F2], RestoDer, NuevoDer),
    lpk(LadoIzq, NuevoDer, VarsIzq, VarsDer, SubArbol),
    ArbolDerivacion = unaria(SubArbol, LadoIzq, [F1 or F2 | RestoDer], VarsIzq, VarsDer, 'or-der').


%--------------------------------------
% CONJUNCIÓN (∧)
%--------------------------------------
lpk([F1 and F2 | RestoIzq], LadoDer, VarsIzq, VarsDer, ArbolDerivacion) :-
    append([F1, F2], RestoIzq, NuevoIzq),
    lpk(NuevoIzq, LadoDer, VarsIzq, VarsDer, SubArbol),
    ArbolDerivacion = unaria(SubArbol, [F1 and F2 | RestoIzq], LadoDer, VarsIzq, VarsDer, 'and-izq').

lpk(LadoIzq, [F1 and F2 | RestoDer], VarsIzq, VarsDer, ArbolDerivacion) :-
    append([F1], RestoDer, Der1),
    append([F2], RestoDer, Der2),
    lpk(LadoIzq, Der1, VarsIzq, VarsDer, SubArbol1),
    lpk(LadoIzq, Der2, VarsIzq, VarsDer, SubArbol2),
    ArbolDerivacion = binaria(SubArbol1, SubArbol2, LadoIzq, [F1 and F2 | RestoDer], VarsIzq, VarsDer, 'and-der').


%--------------------------------------
% IMPLICACIÓN (→)
%--------------------------------------
lpk([F1 imp F2 | RestoIzq], LadoDer, VarsIzq, VarsDer, ArbolDerivacion) :-
    append([F1], LadoDer, NuevoDer),
    append([F2], RestoIzq, NuevoIzq),
    lpk(RestoIzq, NuevoDer, VarsIzq, VarsDer, SubArbol1),
    lpk(NuevoIzq, LadoDer, VarsIzq, VarsDer, SubArbol2),
    ArbolDerivacion = binaria(SubArbol1, SubArbol2, [F1 imp F2 | RestoIzq], LadoDer, VarsIzq, VarsDer, 'imp-izq').

lpk(LadoIzq, [F1 imp F2 | RestoDer], VarsIzq, VarsDer, ArbolDerivacion) :-
    append([F1], LadoIzq, NuevoIzq),
    append([F2], RestoDer, NuevoDer),
    lpk(NuevoIzq, NuevoDer, VarsIzq, VarsDer, SubArbol),
    ArbolDerivacion = unaria(SubArbol, LadoIzq, [F1 imp F2 | RestoDer], VarsIzq, VarsDer, 'imp-der').


%--------------------------------------
% DOBLE IMPLICACIÓN (↔)
%--------------------------------------
lpk([F1 dimp F2 | RestoIzq], LadoDer, VarsIzq, VarsDer, ArbolDerivacion) :-
    append([F1, F2], LadoDer, NuevoDer),
    append([F1, F2], RestoIzq, NuevoIzq),
    lpk(RestoIzq, NuevoDer, VarsIzq, VarsDer, SubArbol1),
    lpk(NuevoIzq, LadoDer, VarsIzq, VarsDer, SubArbol2),
    ArbolDerivacion = binaria(SubArbol1, SubArbol2, [F1 dimp F2 | RestoIzq], LadoDer, VarsIzq, VarsDer, 'dimp-izq').

lpk(LadoIzq, [F1 dimp F2 | RestoDer], VarsIzq, VarsDer, ArbolDerivacion) :-
    append([F1], LadoIzq, Izq1),
    append([F2], RestoDer, Der1),
    append([F2], LadoIzq, Izq2),
    append([F1], RestoDer, Der2),
    lpk(Izq1, Der1, VarsIzq, VarsDer, SubArbol1),
    lpk(Izq2, Der2, VarsIzq, VarsDer, SubArbol2),
    ArbolDerivacion = binaria(SubArbol1, SubArbol2, LadoIzq, [F1 dimp F2 | RestoDer], VarsIzq, VarsDer, 'dimp-der').


%--------------------------------------
% GENERACIÓN DEL CÓDIGO LATEX
%--------------------------------------

% CAMBIO PRINCIPAL: escribir_arbol ahora usa los contextos completos

% Caso: axioma
escribir_arbol(axioma(Izquierda, Derecha, VarsIzq, VarsDer)) :-
    write('    \\AxiomC{\\colorbox{yellow}{$'),
    escribir_secuente_con_contexto(Izquierda, Derecha, VarsIzq, VarsDer),
    write('$}}'), nl.

% Caso: inferencia unaria
escribir_arbol(unaria(SubArbol, Izquierda, Derecha, VarsIzq, VarsDer, _Regla)) :-
    escribir_arbol(SubArbol),
    write('    \\UnaryInfC{$'),
    escribir_secuente_con_contexto(Izquierda, Derecha, VarsIzq, VarsDer),
    write('$}'), nl.

% Caso: inferencia binaria
escribir_arbol(binaria(SubArbol1, SubArbol2, Izquierda, Derecha, VarsIzq, VarsDer, _Regla)) :-
    escribir_arbol(SubArbol1),
    escribir_arbol(SubArbol2),
    write('    \\BinaryInfC{$'),
    escribir_secuente_con_contexto(Izquierda, Derecha, VarsIzq, VarsDer),
    write('$}'), nl.


%--------------------------------------
% ESCRITURA DE SECUENTES CON CONTEXTO
%--------------------------------------

% NUEVA FUNCIÓN: Combina las fórmulas activas con el contexto acumulado
escribir_secuente_con_contexto(Izquierda, Derecha, VarsIzq, VarsDer) :-
    % Filtrar solo fórmulas compuestas (no átomos) para evitar duplicados
    filtrar_no_atomicas(Izquierda, IzqFormulas),
    filtrar_no_atomicas(Derecha, DerFormulas),
    % Combinar: fórmulas compuestas + contexto de variables
    append(IzqFormulas, VarsIzq, IzqCompleta),
    append(DerFormulas, VarsDer, DerCompleta),
    escribir_formulas(IzqCompleta),
    write(' \\vdash '),
    escribir_formulas(DerCompleta).

% Filtra solo fórmulas compuestas (elimina átomos simples)
filtrar_no_atomicas([], []).
filtrar_no_atomicas([F|Resto], [F|Resultado]) :-
    compound(F),
    !,
    filtrar_no_atomicas(Resto, Resultado).
filtrar_no_atomicas([_|Resto], Resultado) :-
    filtrar_no_atomicas(Resto, Resultado).


%--------------------------------------
% ESCRITURA DE LISTAS DE FÓRMULAS
%--------------------------------------
escribir_formulas([]) :- !.

escribir_formulas([Formula]) :-
    !,
    escribir_formula(Formula).

escribir_formulas([Formula | Resto]) :-
    escribir_formula(Formula),
    write(',\\ '),
    escribir_formulas(Resto).


%--------------------------------------
% ESCRITURA DE FÓRMULAS INDIVIDUALES
%--------------------------------------
escribir_formula(neg F) :-
    write('\\NEG '),
    (compound(F) ->
        write('('), escribir_formula(F), write(')')
    ;
        escribir_formula(F)
    ).

escribir_formula(F1 and F2) :-
    escribir_con_parentesis(F1),
    write(' \\AND '),
    escribir_con_parentesis(F2).

escribir_formula(F1 or F2) :-
    escribir_con_parentesis(F1),
    write(' \\OR '),
    escribir_con_parentesis(F2).

escribir_formula(F1 imp F2) :-
    escribir_con_parentesis(F1),
    write(' \\IMP '),
    escribir_con_parentesis(F2).

escribir_formula(F1 dimp F2) :-
    escribir_con_parentesis(F1),
    write(' \\DIMP '),
    escribir_con_parentesis(F2).

escribir_formula(Atom) :-
    atom(Atom),
    write(Atom).


%--------------------------------------
% MANEJO DE PARÉNTESIS
%--------------------------------------
escribir_con_parentesis(Formula) :-
    (compound(Formula), Formula \= neg(_) ->
        write('('), escribir_formula(Formula), write(')')
    ;
        escribir_formula(Formula)
    ).


/****************************************
 *        EJEMPLOS DE EJECUCIÓN         *
 ****************************************/

/** <examples>
?- checkExpression(((p imp q) and (q imp r)) imp (p imp r)), !.            % true
?- checkExpression(neg (p and q) dimp (neg p or neg q)), !.                % true
?- checkExpression(((p imp q) imp q) imp q), !.                            % false
?- checkExpression(((p imp q) imp p) imp q), !.                            % false
?- checkExpression((p or neg (q and r)) imp ((p dimp r) or q)), !.         % false
?- checkExpression((p and q) imp (p or r)), !.                             % true
?- checkExpression((p imp q) or (q imp p)), !.                             % true
?- checkExpression((p imp q) dimp (neg q imp p)), !.                       % false
?- checkExpression(((neg p imp q) and (neg p imp neg q)) imp p), !.        % true
?- checkExpression(((p imp q) imp q) imp p), !.                            % false
?- checkExpression(((q imp r) imp (p imp q)) imp (p imp q)), !.            % true
?- checkExpression(p imp (q imp (q imp p))), !.                            % true
?- checkExpression((p dimp q) dimp (p dimp (q dimp p))), !.                % false
?- checkExpression(neg (p imp q) imp p), !.                                % true
*/