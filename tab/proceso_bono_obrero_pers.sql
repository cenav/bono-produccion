create table pevisa.proceso_bono_obrero_pers (
  id_proceso  number(5),
  id_item     number(3),
  id_personal varchar2(8),
  id_puesto   varchar2(6),
  factor      number(5, 2),
  porc_total  number(5, 2),
  bono        number(15, 2)
)
  tablespace pevisad;


create unique index pevisa.idx_proceso_bono_obrero_pers
  on pevisa.proceso_bono_obrero_pers(id_proceso, id_item, id_personal)
  tablespace pevisax;


create or replace public synonym proceso_bono_obrero_pers for pevisa.proceso_bono_obrero_pers;


alter table pevisa.proceso_bono_obrero_pers
  add (
    constraint pk_proceso_bono_obrero_pers
      primary key (id_proceso, id_item, id_personal)
        using index pevisa.idx_proceso_bono_obrero_pers
        enable validate
    );

alter table pevisa.proceso_bono_obrero_pers
  add (
    constraint fk_proceso_bono_obrero_pers
      foreign key (id_proceso, id_item)
        references proceso_bono_obrero_det(id_proceso, id_item)
          on delete cascade
    );


grant delete, insert, select, update on pevisa.proceso_bono_obrero_pers to sig_roles_invitado;
