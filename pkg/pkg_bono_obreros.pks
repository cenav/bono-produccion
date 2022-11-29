create package pkg_bono_obreros is
  -- Calculo de bonos de los obreros de acuerdo a la cantidad de piezas ingresadas por produccion.
  procedure calcula(
    in_fecha_ini date
  , in_fecha_fin date
  );

  -- Envia correo a los encargados de area.
  procedure envia_correo(
    in_codigo number
  );

  -- Elimina el proceso de bonos.
  procedure elimina(
    in_codigo number
  );
end pkg_bono_obreros;

/

