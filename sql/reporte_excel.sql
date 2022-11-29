select b.descripcion as dsc_bono, d.fecha_del, d.fecha_al, p.id_personal, p.nombre
     , p.desc_cargo, p.bono
  from proceso_bono_obrero_det d
       join bono_obrero b on d.id_bono_obrero = b.id_bono_obrero
       join vw_proceso_bono_obrero_pers p
            on d.id_proceso = p.id_proceso
              and d.id_item = p.id_item
 order by b.orden_reporte, p.orden_reporte, p.nombre;
