create table pevisa.bono_obrero_puesto (
  id_bono_obrero number(5),
  id_puesto      varchar2(6),
  factor         number(5, 2),
  porc_total     number(5, 2)
)
  tablespace pevisad;


create unique index pevisa.idx_bono_obrero_puesto
  on pevisa.bono_obrero_puesto(id_bono_obrero, id_puesto) tablespace pevisax;


create or replace public synonym bono_obrero_puesto for pevisa.bono_obrero_puesto;


alter table pevisa.bono_obrero_puesto
  add (
    constraint pk_bono_obrero_puesto
      primary key (id_bono_obrero, id_puesto)
        using index pevisa.idx_bono_obrero_puesto
        enable validate
    );

alter table pevisa.bono_obrero_puesto
  add (
    constraint fk_bono_obrero_puesto
      foreign key (id_bono_obrero)
        references bono_obrero(id_bono_obrero)
          on delete cascade
    );

grant delete, insert, select, update on pevisa.bono_obrero_puesto to sig_roles_invitado;
