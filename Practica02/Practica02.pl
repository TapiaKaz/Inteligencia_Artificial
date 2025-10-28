/*************************************
 *  SISTEMA DE CÁLCULO DE SECUENTES  *
 *  Con generación de árbol en LaTeX *
*************************************/

%--------------------------------------
% DEFINICIÓN DE OPERADORES LÓGICOS
%--------------------------------------
:- op(1, fx, neg).
:- op(2, xfx, or).
:- op(2, xfx, and).
:- op(2, xfx, imp).
:- op(2, xfx, dimp).


%--------------------------------------
% PREDICADO PRINCIPAL CON LATEX
%--------------------------------------
checkExpressionLatex(Formula) :-
    lpk_latex([], [Formula], [], [], Tree),
    write('\\documentclass{article}\n'),
    write('\\usepackage{bussproofs}\n'),
    write('\\usepackage{amsmath}\n'),
    write('\\usepackage{amssymb}\n'),
    write('\\begin{document}\n\n'),
    write('\\begin{prooftree}\n'),
    print_tree(Tree),
    write('\\end{prooftree}\n\n'),
    write('\\end{document}\n').

% Versión original sin LaTeX
checkExpression(Formula) :-
    lpk([], [Formula], [], []).


%--------------------------------------
% MOTOR CON GENERACIÓN DE ÁRBOL
%--------------------------------------
lpk_latex([], [], [Var | RestoIzq], VarsDer, Tree) :-
    (member(Var, VarsDer) ->
        Tree = axiom([], [Var], 'Axioma')
    ;
        lpk_latex([], [], RestoIzq, VarsDer, Tree)
    ).

lpk_latex([Atom | RestoIzq], LadoDer, VarsIzq, VarsDer, Tree) :-
    atom(Atom),
    append([Atom], VarsIzq, NuevasVarsIzq),
    lpk_latex(RestoIzq, LadoDer, NuevasVarsIzq, VarsDer, Tree).

lpk_latex(LadoIzq, [Atom | RestoDer], VarsIzq, VarsDer, Tree) :-
    atom(Atom),
    append([Atom], VarsDer, NuevasVarsDer),
    lpk_latex(LadoIzq, RestoDer, VarsIzq, NuevasVarsDer, Tree).

% Negación izquierda
lpk_latex([neg F | RestoIzq], LadoDer, VarsIzq, VarsDer, rule(SubTree, RestoIzq, [F|LadoDer], 'neg L')) :-
    append([F], LadoDer, NuevoDer),
    lpk_latex(RestoIzq, NuevoDer, VarsIzq, VarsDer, SubTree).

% Negación derecha
lpk_latex(LadoIzq, [neg F | RestoDer], VarsIzq, VarsDer, rule(SubTree, [F|LadoIzq], RestoDer, 'neg R')) :-
    append([F], LadoIzq, NuevoIzq),
    lpk_latex(NuevoIzq, RestoDer, VarsIzq, VarsDer, SubTree).

% Disyunción izquierda
lpk_latex([F1 or F2 | RestoIzq], LadoDer, VarsIzq, VarsDer, rule2(SubTree1, SubTree2, RestoIzq, LadoDer, 'or L')) :-
    append([F1], RestoIzq, Caso1),
    append([F2], RestoIzq, Caso2),
    lpk_latex(Caso1, LadoDer, VarsIzq, VarsDer, SubTree1),
    lpk_latex(Caso2, LadoDer, VarsIzq, VarsDer, SubTree2).

% Disyunción derecha
lpk_latex(LadoIzq, [F1 or F2 | RestoDer], VarsIzq, VarsDer, rule(SubTree, LadoIzq, [F1,F2|RestoDer], 'or R')) :-
    append([F1, F2], RestoDer, NuevoDer),
    lpk_latex(LadoIzq, NuevoDer, VarsIzq, VarsDer, SubTree).

% Conjunción izquierda
lpk_latex([F1 and F2 | RestoIzq], LadoDer, VarsIzq, VarsDer, rule(SubTree, [F1,F2|RestoIzq], LadoDer, 'and L')) :-
    append([F1, F2], RestoIzq, NuevoIzq),
    lpk_latex(NuevoIzq, LadoDer, VarsIzq, VarsDer, SubTree).

% Conjunción derecha
lpk_latex(LadoIzq, [F1 and F2 | RestoDer], VarsIzq, VarsDer, rule2(SubTree1, SubTree2, LadoIzq, RestoDer, 'and R')) :-
    append([F1], RestoDer, Der1),
    append([F2], RestoDer, Der2),
    lpk_latex(LadoIzq, Der1, VarsIzq, VarsDer, SubTree1),
    lpk_latex(LadoIzq, Der2, VarsIzq, VarsDer, SubTree2).

% Implicación izquierda
lpk_latex([F1 imp F2 | RestoIzq], LadoDer, VarsIzq, VarsDer, rule2(SubTree1, SubTree2, RestoIzq, LadoDer, 'imp L')) :-
    append([F1], LadoDer, NuevoDer),
    append([F2], RestoIzq, NuevoIzq),
    lpk_latex(RestoIzq, NuevoDer, VarsIzq, VarsDer, SubTree1),
    lpk_latex(NuevoIzq, LadoDer, VarsIzq, VarsDer, SubTree2).

% Implicación derecha
lpk_latex(LadoIzq, [F1 imp F2 | RestoDer], VarsIzq, VarsDer, rule(SubTree, [F1|LadoIzq], [F2|RestoDer], 'imp R')) :-
    append([F1], LadoIzq, NuevoIzq),
    append([F2], RestoDer, NuevoDer),
    lpk_latex(NuevoIzq, NuevoDer, VarsIzq, VarsDer, SubTree).

% Doble implicación izquierda
lpk_latex([F1 dimp F2 | RestoIzq], LadoDer, VarsIzq, VarsDer, rule2(SubTree1, SubTree2, RestoIzq, LadoDer, 'dimp L')) :-
    append([F1, F2], LadoDer, NuevoDer),
    append([F1, F2], RestoIzq, NuevoIzq),
    lpk_latex(RestoIzq, NuevoDer, VarsIzq, VarsDer, SubTree1),
    lpk_latex(NuevoIzq, LadoDer, VarsIzq, VarsDer, SubTree2).

% Doble implicación derecha
lpk_latex(LadoIzq, [F1 dimp F2 | RestoDer], VarsIzq, VarsDer, rule2(SubTree1, SubTree2, LadoIzq, RestoDer, 'dimp R')) :-
    append([F1], LadoIzq, Izq1),
    append([F2], RestoDer, Der1),
    append([F2], LadoIzq, Izq2),
    append([F1], RestoDer, Der2),
    lpk_latex(Izq1, Der1, VarsIzq, VarsDer, SubTree1),
    lpk_latex(Izq2, Der2, VarsIzq, VarsDer, SubTree2).


%--------------------------------------
% IMPRESIÓN DEL ÁRBOL EN LATEX
%--------------------------------------
print_tree(axiom(Left, Right, Label)) :-
    format('\\AxiomC{$'),
    print_sequent(Left, Right),
    format('$}\\RightLabel{\\scriptsize ~w}\n', [Label]).

print_tree(rule(SubTree, Left, Right, Label)) :-
    print_tree(SubTree),
    format('\\UnaryInfC{$'),
    print_sequent(Left, Right),
    format('$}\\RightLabel{\\scriptsize ~w}\n', [Label]).

print_tree(rule2(SubTree1, SubTree2, Left, Right, Label)) :-
    print_tree(SubTree1),
    print_tree(SubTree2),
    format('\\BinaryInfC{$'),
    print_sequent(Left, Right),
    format('$}\\RightLabel{\\scriptsize ~w}\n', [Label]).

print_sequent(Left, Right) :-
    print_formulas(Left),
    write(' \\vdash '),
    print_formulas(Right).

print_formulas([]) :- write('\\varnothing').
print_formulas([F]) :- !, print_formula(F).
print_formulas([F|Rest]) :-
    print_formula(F),
    write(', '),
    print_formulas(Rest).

print_formula(neg F) :-
    write('\\neg '),
    print_formula_paren(F).
print_formula(F1 and F2) :-
    print_formula_paren(F1),
    write(' \\land '),
    print_formula_paren(F2).
print_formula(F1 or F2) :-
    print_formula_paren(F1),
    write(' \\lor '),
    print_formula_paren(F2).
print_formula(F1 imp F2) :-
    print_formula_paren(F1),
    write(' \\rightarrow '),
    print_formula_paren(F2).
print_formula(F1 dimp F2) :-
    print_formula_paren(F1),
    write(' \\leftrightarrow '),
    print_formula_paren(F2).
print_formula(Atom) :- atom(Atom), write(Atom).

print_formula_paren(F) :-
    (compound(F) -> (write('('), print_formula(F), write(')')) ; print_formula(F)).


%--------------------------------------
% MOTOR ORIGINAL (sin LaTeX)
%--------------------------------------
lpk([], [], [Var | RestoIzq], VarsDer) :-
    member(Var, VarsDer);
    lpk([], [], RestoIzq, VarsDer).

lpk([Atom | RestoIzq], LadoDer, VarsIzq, VarsDer) :-
    atom(Atom),
    append([Atom], VarsIzq, NuevasVarsIzq),
    lpk(RestoIzq, LadoDer, NuevasVarsIzq, VarsDer).

lpk(LadoIzq, [Atom | RestoDer], VarsIzq, VarsDer) :-
    atom(Atom),
    append([Atom], VarsDer, NuevasVarsDer),
    lpk(LadoIzq, RestoDer, VarsIzq, NuevasVarsDer).

lpk([neg F | RestoIzq], LadoDer, VarsIzq, VarsDer) :-
    append([F], LadoDer, NuevoDer),
    lpk(RestoIzq, NuevoDer, VarsIzq, VarsDer).

lpk(LadoIzq, [neg F | RestoDer], VarsIzq, VarsDer) :-
    append([F], LadoIzq, NuevoIzq),
    lpk(NuevoIzq, RestoDer, VarsIzq, VarsDer).

lpk([F1 or F2 | RestoIzq], LadoDer, VarsIzq, VarsDer) :-
    append([F1], RestoIzq, Caso1),
    append([F2], RestoIzq, Caso2),
    lpk(Caso1, LadoDer, VarsIzq, VarsDer),
    lpk(Caso2, LadoDer, VarsIzq, VarsDer).

lpk(LadoIzq, [F1 or F2 | RestoDer], VarsIzq, VarsDer) :-
    append([F1, F2], RestoDer, NuevoDer),
    lpk(LadoIzq, NuevoDer, VarsIzq, VarsDer).

lpk([F1 and F2 | RestoIzq], LadoDer, VarsIzq, VarsDer) :-
    append([F1, F2], RestoIzq, NuevoIzq),
    lpk(NuevoIzq, LadoDer, VarsIzq, VarsDer).

lpk(LadoIzq, [F1 and F2 | RestoDer], VarsIzq, VarsDer) :-
    append([F1], RestoDer, Der1),
    append([F2], RestoDer, Der2),
    lpk(LadoIzq, Der1, VarsIzq, VarsDer),
    lpk(LadoIzq, Der2, VarsIzq, VarsDer).

lpk([F1 imp F2 | RestoIzq], LadoDer, VarsIzq, VarsDer) :-
    append([F1], LadoDer, NuevoDer),
    append([F2], RestoIzq, NuevoIzq),
    lpk(RestoIzq, NuevoDer, VarsIzq, VarsDer),
    lpk(NuevoIzq, LadoDer, VarsIzq, VarsDer).

lpk(LadoIzq, [F1 imp F2 | RestoDer], VarsIzq, VarsDer) :-
    append([F1], LadoIzq, NuevoIzq),
    append([F2], RestoDer, NuevoDer),
    lpk(NuevoIzq, NuevoDer, VarsIzq, VarsDer).

lpk([F1 dimp F2 | RestoIzq], LadoDer, VarsIzq, VarsDer) :-
    append([F1, F2], LadoDer, NuevoDer),
    append([F1, F2], RestoIzq, NuevoIzq),
    lpk(RestoIzq, NuevoDer, VarsIzq, VarsDer),
    lpk(NuevoIzq, LadoDer, VarsIzq, VarsDer).

lpk(LadoIzq, [F1 dimp F2 | RestoDer], VarsIzq, VarsDer) :-
    append([F1], LadoIzq, Izq1),
    append([F2], RestoDer, Der1),
    append([F2], LadoIzq, Izq2),
    append([F1], RestoDer, Der2),
    lpk(Izq1, Der1, VarsIzq, VarsDer),
    lpk(Izq2, Der2, VarsIzq, VarsDer).


/****************************************
 *        EJEMPLOS DE USO               *
 ****************************************/

/** <examples>
% Para verificar validez sin LaTeX:
?- checkExpression(((p imp q) and (q imp r)) imp (p imp r)).

% Para generar el árbol en LaTeX:
?- checkExpressionLatex(((p imp q) and (q imp r)) imp (p imp r)).

% El resultado se puede copiar y compilar con pdflatex
*/
