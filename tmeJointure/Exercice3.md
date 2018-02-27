
-- ordre1 : CFJ
explain plan for
    select /*+ use_nl(J,C,F)  ORDERED */ C.nom, F.budget 
    from C, F, J
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


-- ordre2 : CJF
explain plan for
    select /*+ use_nl(J,C,F) ORDERED */ C.nom, F.budget 
    from C, J, F
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


-- ordre3 : FCJ
explain plan for
    select /*+ use_nl(J,C,F) ORDERED */ C.nom, F.budget 
    from F, C, J
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


-- ordre4 : FJC
explain plan for
    select /*+ use_nl(J,C,F) ORDERED */ C.nom, F.budget 
    from F, J, C
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
--    where J.cnum = F.cnum and C.cnum = J.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


-- ordre5 : JCF
explain plan for
    select /*+  use_nl(J,C,F) ORDERED */ C.nom, F.budget 
    from J, C, F
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


-- ordre6 : JFC
explain plan for
    select /*+  use_nl(J,C,F) ORDERED */ C.nom, F.budget 
    from J, F, C
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4



-- SANS directive ORDERED
explain plan for
    select  /*+  use_nl(J,C,F) */ C.nom, F.budget 
    from J, C, F
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4




-- avec directive index(J I_J_salaire)

explain plan for
    select /*+ use_nl(J,C,F) index(J I_J_salaire) */  C.nom, F.budget 
    from J, C, F
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


-- avec directive  index(C I_C_division)

explain plan for
    select /*+  use_nl(J,C,F) index(C I_C_division) */  C.nom, F.budget 
    from J, C, F
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4

-- ordre1 : CFJ
explain plan for
    select /*+ use_nl(J,C,F)  ORDERED */ C.nom, F.budget 
    from C, F, J
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


-- ordre2 : CJF
explain plan for
    select /*+ use_nl(J,C,F) ORDERED */ C.nom, F.budget 
    from C, J, F
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


-- ordre3 : FCJ
explain plan for
    select /*+ use_nl(J,C,F) ORDERED */ C.nom, F.budget 
    from F, C, J
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


-- ordre4 : FJC
explain plan for
    select /*+ use_nl(J,C,F) ORDERED */ C.nom, F.budget 
    from F, J, C
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
--    where J.cnum = F.cnum and C.cnum = J.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


-- ordre5 : JCF
explain plan for
    select /*+  use_nl(J,C,F) ORDERED */ C.nom, F.budget 
    from J, C, F
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


-- ordre6 : JFC
explain plan for
    select /*+  use_nl(J,C,F) ORDERED */ C.nom, F.budget 
    from J, F, C
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4



-- SANS directive ORDERED
explain plan for
    select  /*+  use_nl(J,C,F) */ C.nom, F.budget 
    from J, C, F
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4




-- avec directive index(J I_J_salaire)

explain plan for
    select /*+ use_nl(J,C,F) index(J I_J_salaire) */  C.nom, F.budget 
    from J, C, F
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


-- avec directive  index(C I_C_division)

explain plan for
    select /*+  use_nl(J,C,F) index(C I_C_division) */  C.nom, F.budget 
    from J, C, F
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4
