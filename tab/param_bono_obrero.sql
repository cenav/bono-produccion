create table pevisa.param_bono_obrero (
  id               number(1),
  meses_antiguedad number(5)
)
  tablespace pevisad;


create unique index pevisa.idx_param_bono_obrero
  on pevisa.param_bono_obrero(id) tablespace pevisax;


create or replace public synonym param_bono_obrero for pevisa.param_bono_obrero;


alter table pevisa.param_bono_obrero
  add (
    constraint pk_param_bono_obrero
      primary key (id)
        using index pevisa.idx_param_bono_obrero
        enable validate
    );


grant delete, insert, select, update on pevisa.param_bono_obrero to sig_roles_invitado;
