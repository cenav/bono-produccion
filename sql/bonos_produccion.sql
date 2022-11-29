select *
  from planilla10.t_cargo
 where descripcion like '%SURT%';

select *
  from planilla10.t_cargo
 where descripcion like '%DESP%';

select *
  from planilla10.t_cargo
 where descripcion like '%COORDINADOR%';

select *
  from planilla10.t_cargo
 where descripcion like '%ARMADO%';

select *
  from planilla10.t_cargo
 where descripcion like '%OPER%';

select *
  from planilla10.t_cargo
 where descripcion like '%INSPECTOR%';

select *
  from planilla10.t_cargo
 where c_cargo = 'COA';

select *
  from bono_obrero
 where estado = 1
 order by orden_reporte, id_bono_obrero;

select *
  from bono_obrero
 where estado = 0
 order by id_bono_obrero;

select *
  from bono_obrero_grupo
 where id_bono_obrero = 19;

-- capataz CPZP
-- coordinador surtimento COA
select *
  from planilla10.personal
 where c_cargo = 'COA'
   and situacion not in ('8', '9')
 order by apellido_paterno;

select *
  from planilla10.personal
 where c_codigo = 'E4458';

select * from proceso_bono_obrero order by id_proceso desc;

select * from proceso_bono_obrero_det where id_proceso = 14;

select * from proceso_bono_obrero_pers;

select * from bono_obrero;


select * from bono_obrero_grupo;

select * from bono_obrero_rango;

select *
  from bono_obrero_puesto
 where id_bono_obrero = 22
 order by orden_reporte, id_bono_obrero, id_puesto;

select *
  from planilla10.personal
 where c_cargo = 'COA'
   and situacion not in ('8', '9')
 order by apellido_paterno;

select sum(factor) as factor
  from bono_obrero_puesto
 where id_bono_obrero = 22
   and porc_total = 70
 group by id_bono_obrero, porc_total;

select id_proceso as pers_id_proceso
     , id_item as pers_id_item
     , id_personal as pers_id_personal
     , nombre as pers_nombre
     , id_puesto as pers_id_puesto
     , desc_cargo as pers_desc_cargo
     , factor as pers_factor
     , porc_total as pers_porc_total
     , bono as pers_bono
  from vw_proceso_bono_obrero_pers;

begin
  pkg_bono_obreros.elimina(77);
  pkg_bono_obreros.calcula(
      to_date('21/09/2022', 'dd/mm/yyyy')
    , to_date('20/10/2022', 'dd/mm/yyyy')
    );
end;

select * from error_log order by id_log desc;

select *
  from bono_obrero
 order by id_bono_obrero;

select descripcion, id from tipo_indicador_bono_obrero;

select local, descripcion
  from planilla10.pla_local
 order by 1;

select p.c_cargo, p.c_codigo, p.apellido_paterno, p.nombres, g.factor, g.porc_total
     , count(p.c_codigo) over (partition by p.c_cargo) as cant_pers, h.local, p.encargado
     , g.orden_reporte
  from planilla10.personal p
       left join planilla10.hr_personal h on p.c_codigo = h.c_codigo
       join bono_obrero_puesto g
            on p.c_cargo = g.id_puesto
              and (h.local = g.id_sede or g.id_sede is null)
 where p.situacion not in ('8', '9')
--        and g.id_bono_obrero = p_bono_id
   and g.id_bono_obrero = 22
 order by g.orden_reporte, p.c_cargo, p.apellido_paterno;

select *
  from planilla10.tar_encarga
 where codigo in ('046', '047', '048');

select *
  from planilla10.personal
 where encargado = '034'
   and c_cargo = 'OPAL'
 order by apellido_paterno;

select sum(factor)
  from vw_reparte_bono_personal
 where id_bono_obrero = 25
   and porc_total = 100;

select *
  from vw_reparte_bono_personal
 where id_bono_obrero = '22';

select nombre, codigo
  from planilla10.tar_encarga
 where estado = '1'
 order by nombre;

select e.nombre, b.id_jefatura
  from bono_obrero b
       join planilla10.tar_encarga e on b.id_jefatura = e.codigo
 group by e.nombre, b.id_jefatura
 order by nombre;

select id, descripcion
  from pr_grupos
 where id != '%'
   and estado != '9'
 order by lpad(id, 3, '0');

select id, lpad(id, 3, '0') as id_char from pr_grupos;

select c_codigo, apellido_paterno, nombres, f_ingreso
     , trunc(months_between(sysdate, f_ingreso)) as meses_antiguedad
  from planilla10.personal
 where c_codigo = 'E42813';

select * from param_bono_obrero;

select *
  from vw_reparte_bono_personal
 where c_codigo = 'E42813';
