create or replace package body pkg_bono_obreros is
  -- Variables globales
  g_ano pls_integer;
  g_mes pls_integer;
  g_id_proceso proceso_bono_obrero.id_proceso%type;
  g_item pls_integer := 1;

  cursor cr_personal(p_bono_id number) is
    select id_bono_obrero, c_cargo, c_codigo, apellido_paterno, nombres, factor, porc_total
         , orden_reporte, local, cant_pers, factor_tot
      from vw_reparte_bono_personal
     where id_bono_obrero = p_bono_id
--      where id_bono_obrero = 22
     order by orden_reporte, c_cargo, apellido_paterno;

  -- Fordward Declarations
  function get_id_proceso
    return proceso_bono_obrero.id_proceso%type;

  -- Inicializa variables globales
  procedure init(
    in_fecha_ini date
  , in_fecha_fin date
  ) is
  begin
    g_ano := to_number(to_char(in_fecha_fin, 'YYYY'));
    g_mes := to_number(to_char(in_fecha_fin, 'MM'));
    g_id_proceso := get_id_proceso();
  end init;

  -- Retorna el numero correlativo de los procesos de bonos.
  function get_id_proceso
    return proceso_bono_obrero.id_proceso%type is
    retval proceso_bono_obrero.id_proceso%type;
  begin
    select nvl(max(id_proceso), 0) + 1
      into retval
      from proceso_bono_obrero;

    return retval;
  end get_id_proceso;

  -- Cantidad total de ingreso a produccion en un rango de fechas.
  function get_total_ingreso(
    in_id_bono_obrero in bono_obrero.id_bono_obrero%type
  , p_fecha_ini          date
  , p_fecha_fin          date
  )
    return number is
    retval number;
  begin
    select nvl(sum(cantidad), 0)
      into retval
      from kardex_d
     where tp_transac = '18'
       and estado <> 9
       and fch_transac between p_fecha_ini and p_fecha_fin
       and cod_art in (
       select distinct a.cod_art
         from pr_grupos_lineas gl
            , articul a
        where gl.id_grupo in (
          select id_grupo
            from bono_obrero_grupo
           where id_bono_obrero = in_id_bono_obrero
          )
          and gl.tp_art like a.tp_art
          and gl.cod_fam like a.cod_fam
          and gl.cod_lin like a.cod_lin
       );

    return retval;
  end get_total_ingreso;

  function get_total_facturado(
    p_fecha_ini date
  , p_fecha_fin date
  )
    return number is
    retval           number := 0;
    l_venta_nacional number := 0;
    l_venta_expo     number := 0;
  begin
      with venta_nacional as
             (
               select decode(
                   v.ind_vta1
                 , '1000', '01-EMPAQUES'
                 , '2000', '02-COMERCIAL'
                 , '3000', '03-BATERIAS'
                 , '4000', '04-NEUMATICOS'
                 , '5000', '05-ILUMINACION'
                 , decode(v.ind_vta1, null,
                          decode(v.supervisor, '01', '01-EMPAQUES', '42', '03-BATERIAS',
                                 '01-EMPAQUES'), '05-ILUMINACION')
                 )
                 divi_grupo
                    , v.grupo
                    , v.des_grupo
                    , sum(v.dolares) as dolares
                 from view_vendedor_grupo v
                    , vendedores d
                where v.fecha between p_fecha_ini and p_fecha_fin
                  and v.cod_vende = d.cod_vendedor
                  and v.tipo = 'NACIONAL'
                group by decode(
                    v.ind_vta1
                  , '1000', '01-EMPAQUES'
                  , '2000', '02-COMERCIAL'
                  , '3000', '03-BATERIAS'
                  , '4000', '04-NEUMATICOS'
                  , '5000', '05-ILUMINACION'
                  , decode(v.ind_vta1, null,
                           decode(v.supervisor, '01', '01-EMPAQUES', '42', '03-BATERIAS',
                                  '01-EMPAQUES'), '05-ILUMINACION')
                  )
                       , v.grupo
                       , v.des_grupo
               )
    select sum(dolares)
      into l_venta_nacional
      from venta_nacional
     where divi_grupo = '01-EMPAQUES';

-- VENTA EXPO MODULO GERENCIAL
    select sum(x.total_expo)
      into l_venta_expo
      from (
             select to_char(fecha, 'yyyy') ano
                  , to_char(fecha, 'mm') mes
                  , (decode(moneda, 'D', imp_neto, round(imp_neto / import_cam, 2))) total
                  , (decode(origen, 'EXPO', 0, decode(moneda, 'D', imp_neto,
                                                      round(imp_neto / import_cam, 2)))) total_nac
                  , (decode(origen, 'EXPO',
                            decode(moneda, 'D', imp_neto, round(imp_neto / import_cam, 2)),
                            0)) total_expo
               ---   FROM docuvent      se modifico 02/08/2017---
               from v_docuvent
              where estado <> '9'
                and not (tipodoc = '01'
                and origen = 'EXPO')
                and fecha between p_fecha_ini and p_fecha_fin
              union all
             select to_char(f.fecha, 'YYYY') ano
                  , to_char(f.fecha, 'MM') mes
                  , (decode(nvl(d.merca, 0), 0, decode(nvl(d.fob, 0), 0, d.totlin, d.fob),
                            nvl(d.merca, 0))) total
                  , 0 total_nac
                  , (decode(nvl(d.merca, 0), 0, decode(nvl(d.fob, 0), 0, d.totlin, d.fob),
                            nvl(d.merca, 0))) total_xpo
               from exfacturas f
                  , exfactura_d d
              where f.estado <> '9'
                and d.numero = f.numero
                and f.fecha between p_fecha_ini and p_fecha_fin
                and d.canti > 0
             ) x;
    --GROUP BY x.ano, x.mes;
/*
    --VENTA CON NOTA DE CREDITO
    SELECT SUM(x.total_expo)
    INTO   l_venta_expo
    FROM   (SELECT (DECODE(origen, 'EXPO', DECODE(moneda, 'D', imp_neto, ROUND(imp_neto / import_cam, 2)), 0)) total_expo
            FROM   docuvent
            WHERE  estado <> '9'
            AND    NOT (tipodoc = '01'
            AND         origen = 'EXPO')
            AND    fecha BETWEEN g_fecha_ini AND g_fecha_fin
            UNION ALL
            SELECT (DECODE(NVL(d.merca, 0), 0, DECODE(NVL(d.fob, 0), 0, d.totlin, d.fob), NVL(d.merca, 0))) total_xpo
            FROM   exfacturas f
                 , exfactura_d d
            WHERE  f.estado <> '9'
            AND    d.numero = f.numero
            AND    d.canti > 0
            AND    f.fecha BETWEEN g_fecha_ini AND g_fecha_fin) x;

    --VENTA SIN NC
    SELECT NVL(SUM(pr_tmerca(e.numero)), 0) AS total_merca
    INTO   l_venta_expo
    FROM   exfacturas e
         , exclientes c
         , extablas_expo t
    WHERE  e.fecha BETWEEN g_fecha_ini AND g_fecha_fin
    AND    NVL(e.estado, '0') <> '9'
    AND    c.cod_cliente = e.cod_cliente
    AND    t.tipo = '13'
    AND    t.codigo(+) = NVL(e.zona, '00');
*/
    retval := l_venta_nacional + l_venta_expo;

    --        retval := l_venta_nacional;

    return retval;
  end get_total_facturado;

  function get_total_bono
    return number is
    retval number;
  begin
    select nvl(sum(r.importe_bono), 0)
      into retval
      from proceso_bono_obrero_det d
           join bono_obrero_rango r
                on (d.id_bono_obrero = r.id_bono_obrero
                  and d.id_rango_alcanzado = r.id_item)
     where d.id_proceso = g_id_proceso;

    return retval;
  end get_total_bono;

  procedure reparte_personal(
    p_proceso      number
  , p_item         number
  , p_bono_id      number
  , p_importe_bono number
  ) is
    l_proceso_pers proceso_bono_obrero_pers%rowtype;
    l_reparte      number;
    l_total_pers   number;
  begin
    for r in cr_personal(p_bono_id) loop
      begin
        l_reparte := (p_importe_bono * r.porc_total / 100) / r.factor_tot * r.factor;
      exception
        when zero_divide then l_proceso_pers.bono := 0;
      end;
      l_proceso_pers.id_proceso := p_proceso;
      l_proceso_pers.id_item := p_item;
      l_proceso_pers.id_personal := r.c_codigo;
      l_proceso_pers.id_puesto := r.c_cargo;
      l_proceso_pers.factor := r.factor;
      l_proceso_pers.porc_total := r.porc_total;
      l_proceso_pers.orden_reporte := r.orden_reporte;
      l_proceso_pers.bono := l_reparte;
      api_proceso_bono_obrero_pers.ins(l_proceso_pers);
    end loop;
  end;

  -- Calcula y guarda el rango que se llego a alcanzar en el bono
  procedure busca_rango_alcanzado(
    in_id_bono_obrero in    bono_obrero_rango.id_bono_obrero%type
  , in_id_tipo_indicador in bono_obrero.id_tipo_indicador%type
  , in_mes_cerrado in       bono_obrero.mes_cerrado%type
  ) is
    cursor cur_bono_rango is
      select *
        from bono_obrero_rango
       where id_bono_obrero = in_id_bono_obrero
       order by rango;

    l_total_indicador number := 0;
    l_fecha_ini       date;
    l_fecha_fin       date;
    l_importe_bono    number;
    l_rango           cur_bono_rango%rowtype;
    l_proceso_det     proceso_bono_obrero_det%rowtype;
  begin
    l_fecha_ini := pkg_comision.intervalo_fechas(g_ano, g_mes, in_mes_cerrado, 1).fecha_del;
    l_fecha_fin := pkg_comision.intervalo_fechas(g_ano, g_mes, in_mes_cerrado, 1).fecha_al;

    -- Pieza Ingresada.
    if (in_id_tipo_indicador = 'PI') then
      l_total_indicador := get_total_ingreso(in_id_bono_obrero, l_fecha_ini, l_fecha_fin);
      -- Monto Facturado.
    elsif (in_id_tipo_indicador = 'MF') then
      l_total_indicador := get_total_facturado(l_fecha_ini, l_fecha_fin);
    end if;

    -- Guarda la fila del bono que se alcanzo.
    for rec_rango in cur_bono_rango loop
      if (l_total_indicador >= rec_rango.rango) then
        l_rango := rec_rango;
      else
        exit;
      end if;
    end loop;

    -- LLena los campos de la tabla de detalle con la info del bono alcanzado.
    l_proceso_det.id_proceso := g_id_proceso;
    l_proceso_det.id_item := g_item;
    l_proceso_det.id_bono_obrero := l_rango.id_bono_obrero;
    l_proceso_det.id_rango_alcanzado := l_rango.id_item;
    l_proceso_det.cantidad_lograda := l_total_indicador;
    l_proceso_det.fecha_del := l_fecha_ini;
    l_proceso_det.fecha_al := l_fecha_fin;

    api_proceso_bono_obrero_det.ins(l_proceso_det);
    l_importe_bono :=
        api_bono_obrero_rango.onerow(l_rango.id_bono_obrero, l_rango.id_item).importe_bono;

    reparte_personal(
        l_proceso_det.id_proceso
      , l_proceso_det.id_item
      , in_id_bono_obrero
      , l_importe_bono
      );

    g_item := g_item + 1;
  end busca_rango_alcanzado;

  -- Calculo de bonos de los obreros de acuerdo a la cantidad de piezas ingresadas por produccion.
  procedure calcula(
    in_fecha_ini date
  , in_fecha_fin date
  ) is
    cursor cur_bono is
      select *
        from bono_obrero
       where estado = 1
       order by orden_reporte, id_bono_obrero;

    rec_proceso_bono_obrero proceso_bono_obrero%rowtype;
  begin
    init(in_fecha_ini, in_fecha_fin);

    for rec_bono in cur_bono loop
      busca_rango_alcanzado(
          rec_bono.id_bono_obrero
        , rec_bono.id_tipo_indicador
        , rec_bono.mes_cerrado
        );
    end loop;

    rec_proceso_bono_obrero.id_proceso := g_id_proceso;
    rec_proceso_bono_obrero.fecha_ini := in_fecha_ini;
    rec_proceso_bono_obrero.fecha_fin := in_fecha_fin;
    rec_proceso_bono_obrero.total_bono := get_total_bono();
    rec_proceso_bono_obrero.moneda := 'S';
    rec_proceso_bono_obrero.fecha_creacion := sysdate;
    rec_proceso_bono_obrero.usuario_creacion := user;

    api_proceso_bono_obrero.ins(rec_proceso_bono_obrero);

    commit;
  exception
    when others then
      pkg_error.record_log('bono obreros');
      --logger.log('bono obreros');
      rollback;
      raise;
  end calcula;

  procedure elimina(
    in_codigo number
  ) is
  begin
    api_proceso_bono_obrero.del(in_codigo);

    commit;
  end elimina;

  procedure envia_correo(
    in_codigo number
  ) is
  begin
    null;
  end envia_correo;
end pkg_bono_obreros;
/

