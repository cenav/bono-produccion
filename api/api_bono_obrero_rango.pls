create or replace package api_bono_obrero_rango as
  type aat is table of bono_obrero_rango%rowtype index by binary_integer;
  type ntt is table of bono_obrero_rango%rowtype;

  procedure ins(
    p_rec in bono_obrero_rango%rowtype
  );

  procedure ins(
    p_coll aat
  );

  procedure upd(
    p_rec in bono_obrero_rango%rowtype
  );

  procedure upd(
    p_coll aat
  );

  procedure del(
    p_id_bono_obrero in bono_obrero_rango.id_bono_obrero%type
  , p_id_item in        bono_obrero_rango.id_item%type
  );

  function
    onerow(
    p_id_bono_obrero in bono_obrero_rango.id_bono_obrero%type
  , p_id_item in        bono_obrero_rango.id_item%type
  ) return bono_obrero_rango%rowtype result_cache;

  function
    allrows return aat;

  function
    exist(
    p_id_bono_obrero in bono_obrero_rango.id_bono_obrero%type
  , p_id_item in        bono_obrero_rango.id_item%type
  ) return boolean;
end api_bono_obrero_rango;
/

create or replace package body api_bono_obrero_rango as
  forall_err exception;
  pragma exception_init (forall_err, -24381);

  procedure ins(
    p_rec in bono_obrero_rango%rowtype
  )
    is
  begin
    insert into bono_obrero_rango
    values p_rec;
  end;

  procedure ins(
    p_coll in aat
  )
    is
  begin
    forall
      i in 1 .. p_coll.count save exceptions
      insert into bono_obrero_rango values p_coll(i);
  exception
    when forall_err then
      for i in 1 .. sql%bulk_exceptions.COUNT loop
        logger.log('PK: ' || p_coll(sql%bulk_exceptions(i).error_index).id_bono_obrero ||
                   ' ^ ' || p_coll(sql%bulk_exceptions(i).error_index).id_item ||
                   ' Err: ' || sqlerrm(sql%bulk_exceptions(i).error_code * -1));

      end loop;
      raise;
  end;

  procedure upd(
    p_rec in bono_obrero_rango%rowtype
  )
    is
  begin
    update bono_obrero_rango t
       set row = p_rec
     where t.id_bono_obrero = p_rec.id_bono_obrero and t.id_item = p_rec.id_item;
  end;

  procedure upd(
    p_coll in aat
  )
    is
  begin
    forall
      i in 1 .. p_coll.count save exceptions
      update bono_obrero_rango
         set row = p_coll(i)
       where id_bono_obrero = p_coll(i).id_bono_obrero and id_item = p_coll(i).id_item;
  exception
    when forall_err then
      for i in 1 .. sql%bulk_exceptions.COUNT loop
        logger.log('PK: ' || p_coll(sql%bulk_exceptions(i).error_index).id_bono_obrero ||
                   ' ^ ' || p_coll(sql%bulk_exceptions(i).error_index).id_item ||
                   ' Err: ' || sqlerrm(sql%bulk_exceptions(i).error_code * -1));
      end loop;
      raise;
  end;

  procedure del(
    p_id_bono_obrero in bono_obrero_rango.id_bono_obrero%type
  , p_id_item in        bono_obrero_rango.id_item%type
  )
    is
  begin
    delete
      from bono_obrero_rango t
     where t.id_bono_obrero = p_id_bono_obrero and t.id_item = p_id_item;
  end;

  function
    onerow(
    p_id_bono_obrero in bono_obrero_rango.id_bono_obrero%type
  , p_id_item in        bono_obrero_rango.id_item%type
  ) return bono_obrero_rango%rowtype result_cache is
    rec bono_obrero_rango%rowtype;
  begin
    select *
      into rec
      from bono_obrero_rango t
     where t.id_bono_obrero = p_id_bono_obrero and t.id_item = p_id_item;

    return rec;
  exception
    when no_data_found then
      return null;
    when too_many_rows then
      raise;
  end;

  function
    allrows return aat is
    coll aat;
  begin
    select * bulk collect
      into coll
      from bono_obrero_rango;

    return coll;
  end;

  function
    exist(
    p_id_bono_obrero in bono_obrero_rango.id_bono_obrero%type
  , p_id_item in        bono_obrero_rango.id_item%type
  ) return boolean is
    dummy pls_integer;
  begin
    select 1
      into dummy
      from bono_obrero_rango t
     where t.id_bono_obrero = p_id_bono_obrero and t.id_item = p_id_item;

    return true;
  exception
    when no_data_found then
      return false;
    when too_many_rows then
      return true;
  end;
end api_bono_obrero_rango;

create or replace public synonym api_bono_obrero_rango for api_bono_obrero_rango;
