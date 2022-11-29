create or replace view vw_reparte_bono_personal as
select g.id_bono_obrero, p.c_cargo, p.c_codigo, p.apellido_paterno, p.nombres, g.factor
     , g.porc_total, g.orden_reporte, h.local
     , count(p.c_codigo) over (partition by g.id_bono_obrero,g.porc_total) as cant_pers
     , sum(g.factor) over (partition by g.id_bono_obrero,g.porc_total) as factor_tot
     , trunc(months_between(sysdate, f_ingreso)) as meses_antiguedad
  from planilla10.personal p
       left join planilla10.hr_personal h on p.c_codigo = h.c_codigo
       join bono_obrero_puesto g
            on p.c_cargo = g.id_puesto
              and (h.local = g.id_sede or g.id_sede is null)
       join param_bono_obrero a on a.id = 1
 where trunc(months_between(sysdate, f_ingreso)) > a.meses_antiguedad
   and p.situacion not in (
   select codigo
     from planilla10.t_situacion_cesado
   )
 order by id_bono_obrero, g.orden_reporte, p.c_cargo, p.apellido_paterno;