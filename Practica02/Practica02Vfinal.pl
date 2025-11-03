/*************
 *  SISTEMA DE CÁLCULO DE SECUENTES  *
 *  Verificación de validez lógica   *
 *  con impresión del árbol          *
*************/

%--------------------------------------
% DEFINICIÓN DE OPERADORES LÓGICOS
%--------------------------------------
:- op(500, fx, neg).     % Negación
:- op(600, xfy, or).     % Disyunción
:- op(700, xfy, and).    % Conjunción
:- op(800, xfy, imp).    % Implicación
:- op(900, xfy, dimp).   % Doble implicación


%--------------------------------------
% PREDICADO PRINCIPAL
%--------------------------------------
checkExpression(Formula) :-
    format("\nComprobando validez de la fórmula: ~w\n", [Formula]),
    (   lpk([], [Formula], [], [], 0)
    ->  writeln('\n✅ La fórmula es lógicamente válida.\n')
    ;   writeln('\n❌ La fórmula NO es válida.\n')
    ).


%--------------------------------------
% MOTOR DEL CÁLCULO DE SECUENTES CON IMPRESIÓN
%--------------------------------------
% lpk(+LadoIzq, +LadoDer, +VarsIzq, +VarsDer, +Nivel)
%
% Nivel controla la indentación visual del árbol.

% Utilidad para imprimir con indentación
indent(N) :-
    Tab is N * 4,
    format('~*|', [Tab]).

% Imprime un nodo del árbol
print_node(Nivel, Izq, Der) :-
    indent(Nivel),
    format("Sequent: ~w ⊢ ~w\n", [Izq, Der]).

%--------------------------------------
% CASO BASE: Coincidencia de variables
%--------------------------------------
lpk(_, _, VarsIzq, VarsDer, Nivel) :-
    member(Var, VarsIzq),
    member(Var, VarsDer),
    indent(Nivel),
    format("✔ Coincidencia encontrada con la variable: ~w\n", [Var]), !.

%--------------------------------------
% VARIABLES ATÓMICAS
%--------------------------------------
lpk([Atom | RestoIzq], LadoDer, VarsIzq, VarsDer, Nivel) :-
    atom(Atom),
    append([Atom], VarsIzq, NuevasVarsIzq),
    lpk(RestoIzq, LadoDer, NuevasVarsIzq, VarsDer, Nivel).

lpk(LadoIzq, [Atom | RestoDer], VarsIzq, VarsDer, Nivel) :-
    atom(Atom),
    append([Atom], VarsDer, NuevasVarsDer),
    lpk(LadoIzq, RestoDer, VarsIzq, NuevasVarsDer, Nivel).


%--------------------------------------
% NEGACIÓN
%--------------------------------------
lpk([neg F | RestoIzq], LadoDer, VarsIzq, VarsDer, Nivel) :-
    print_node(Nivel, [neg F | RestoIzq], LadoDer),
    indent(Nivel), writeln("→ Negación a la izquierda"),
    append([F], LadoDer, NuevoDer),
    Nivel1 is Nivel + 1,
    lpk(RestoIzq, NuevoDer, VarsIzq, VarsDer, Nivel1).

lpk(LadoIzq, [neg F | RestoDer], VarsIzq, VarsDer, Nivel) :-
    print_node(Nivel, LadoIzq, [neg F | RestoDer]),
    indent(Nivel), writeln("→ Negación a la derecha"),
    append([F], LadoIzq, NuevoIzq),
    Nivel1 is Nivel + 1,
    lpk(NuevoIzq, RestoDer, VarsIzq, VarsDer, Nivel1).


%--------------------------------------
% DISYUNCIÓN
%--------------------------------------
lpk([F1 or F2 | RestoIzq], LadoDer, VarsIzq, VarsDer, Nivel) :-
    print_node(Nivel, [F1 or F2 | RestoIzq], LadoDer),
    indent(Nivel), writeln("→ Disyunción en el lado izquierdo (ramas separadas)"),
    Nivel1 is Nivel + 1,
    append([F1], RestoIzq, Caso1),
    append([F2], RestoIzq, Caso2),
    lpk(Caso1, LadoDer, VarsIzq, VarsDer, Nivel1),
    lpk(Caso2, LadoDer, VarsIzq, VarsDer, Nivel1).

lpk(LadoIzq, [F1 or F2 | RestoDer], VarsIzq, VarsDer, Nivel) :-
    print_node(Nivel, LadoIzq, [F1 or F2 | RestoDer]),
    indent(Nivel), writeln("→ Disyunción en el lado derecho"),
    append([F1, F2], RestoDer, NuevoDer),
    Nivel1 is Nivel + 1,
    lpk(LadoIzq, NuevoDer, VarsIzq, VarsDer, Nivel1).


%--------------------------------------
% CONJUNCIÓN
%--------------------------------------
lpk([F1 and F2 | RestoIzq], LadoDer, VarsIzq, VarsDer, Nivel) :-
    print_node(Nivel, [F1 and F2 | RestoIzq], LadoDer),
    indent(Nivel), writeln("→ Conjunción en el lado izquierdo"),
    append([F1, F2], RestoIzq, NuevoIzq),
    Nivel1 is Nivel + 1,
    lpk(NuevoIzq, LadoDer, VarsIzq, VarsDer, Nivel1).

lpk(LadoIzq, [F1 and F2 | RestoDer], VarsIzq, VarsDer, Nivel) :-
    print_node(Nivel, LadoIzq, [F1 and F2 | RestoDer]),
    indent(Nivel), writeln("→ Conjunción en el lado derecho (ramas separadas)"),
    Nivel1 is Nivel + 1,
    append([F1], RestoDer, Der1),
    append([F2], RestoDer, Der2),
    lpk(LadoIzq, Der1, VarsIzq, VarsDer, Nivel1),
    lpk(LadoIzq, Der2, VarsIzq, VarsDer, Nivel1).


%--------------------------------------
% IMPLICACIÓN
%--------------------------------------
lpk([F1 imp F2 | RestoIzq], LadoDer, VarsIzq, VarsDer, Nivel) :-
    print_node(Nivel, [F1 imp F2 | RestoIzq], LadoDer),
    indent(Nivel), writeln("→ Implicación en el lado izquierdo (dos ramas)"),
    Nivel1 is Nivel + 1,
    append([F1], LadoDer, NuevoDer),
    append([F2], RestoIzq, NuevoIzq),
    lpk(RestoIzq, NuevoDer, VarsIzq, VarsDer, Nivel1),
    lpk(NuevoIzq, LadoDer, VarsIzq, VarsDer, Nivel1).

lpk(LadoIzq, [F1 imp F2 | RestoDer], VarsIzq, VarsDer, Nivel) :-
    print_node(Nivel, LadoIzq, [F1 imp F2 | RestoDer]),
    indent(Nivel), writeln("→ Implicación en el lado derecho"),
    Nivel1 is Nivel + 1,
    append([F1], LadoIzq, NuevoIzq),
    append([F2], RestoDer, NuevoDer),
    lpk(NuevoIzq, NuevoDer, VarsIzq, VarsDer, Nivel1).


%--------------------------------------
% DOBLE IMPLICACIÓN
%--------------------------------------
lpk([F1 dimp F2 | RestoIzq], LadoDer, VarsIzq, VarsDer, Nivel) :-
    print_node(Nivel, [F1 dimp F2 | RestoIzq], LadoDer),
    indent(Nivel), writeln("→ Doble implicación en el lado izquierdo (ramas simétricas)"),
    Nivel1 is Nivel + 1,
    append([F1, F2], LadoDer, NuevoDer),
    append([F1, F2], RestoIzq, NuevoIzq),
    lpk(RestoIzq, NuevoDer, VarsIzq, VarsDer, Nivel1),
    lpk(NuevoIzq, LadoDer, VarsIzq, VarsDer, Nivel1).

lpk(LadoIzq, [F1 dimp F2 | RestoDer], VarsIzq, VarsDer, Nivel) :-
    print_node(Nivel, LadoIzq, [F1 dimp F2 | RestoDer]),
    indent(Nivel), writeln("→ Doble implicación en el lado derecho (ramas simétricas)"),
    Nivel1 is Nivel + 1,
    append([F1], LadoIzq, Izq1),
    append([F2], RestoDer, Der1),
    append([F2], LadoIzq, Izq2),
    append([F1], RestoDer, Der2),
    lpk(Izq1, Der1, VarsIzq, VarsDer, Nivel1),
    lpk(Izq2, Der2, VarsIzq, VarsDer, Nivel1).


/**************
 *        EJEMPLOS DE EJECUCIÓN         *
 **************/
/** <examples>
?- checkExpression(((p imp q) and (q imp r)) imp (p imp r)).
checkExpression(neg (p and q) dimp (neg p or neg q)).
checkExpression(neg (p imp q) imp p).
checkExpression((p imp q) or (q imp p)).
?- member(X, [cat, mouse]).
*/
