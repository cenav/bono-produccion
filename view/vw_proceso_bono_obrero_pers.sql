create or replace view vw_proceso_bono_obrero_pers as
select id_proceso, id_item, id_personal, p.nombre, id_puesto, p.desc_cargo, factor
     , porc_total, bono, b.orden_reporte
  from proceso_bono_obrero_pers b
       join vw_personal p on b.id_personal = p.c_codigo;

create public synonym vw_proceso_bono_obrero_pers for vw_proceso_bono_obrero_pers;