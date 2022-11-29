create or replace package api_proceso_bono_obrero_pers as
  type aat is table of proceso_bono_obrero_pers%rowtype index by binary_integer;
  type ntt is table of proceso_bono_obrero_pers%rowtype;

  procedure ins(
    p_rec in proceso_bono_obrero_pers%rowtype
  );

  procedure ins(
    p_coll aat
  );

  procedure upd(
    p_rec in proceso_bono_obrero_pers%rowtype
  );

  procedure upd(
    p_coll aat
  );

  procedure del(
    p_id_proceso in  proceso_bono_obrero_pers.id_proceso%type
  , p_id_item in     proceso_bono_obrero_pers.id_item%type
  , p_id_personal in proceso_bono_obrero_pers.id_personal%type
  );

  function
    onerow(
    p_id_proceso in  proceso_bono_obrero_pers.id_proceso%type
  , p_id_item in     proceso_bono_obrero_pers.id_item%type
  , p_id_personal in proceso_bono_obrero_pers.id_personal%type
  ) return proceso_bono_obrero_pers%rowtype result_cache;

  function
    allrows return aat;

  function
    exist(
    p_id_proceso in  proceso_bono_obrero_pers.id_proceso%type
  , p_id_item in     proceso_bono_obrero_pers.id_item%type
  , p_id_personal in proceso_bono_obrero_pers.id_personal%type
  ) return boolean;
end api_proceso_bono_obrero_pers;
/

create or replace package body api_proceso_bono_obrero_pers as
  forall_err exception;
  pragma exception_init (forall_err, -24381);

  procedure ins(
    p_rec in proceso_bono_obrero_pers%rowtype
  )
    is
  begin
    insert into proceso_bono_obrero_pers
    values p_rec;
  end;

  procedure ins(
    p_coll in aat
  )
    is
  begin
    forall
      i in 1 .. p_coll.count save exceptions
      insert into proceso_bono_obrero_pers values p_coll(i);
  exception
    when forall_err then
      for i in 1 .. sql%bulk_exceptions.COUNT loop
        logger.log('PK: ' || p_coll(sql%bulk_exceptions(i).error_index).id_proceso ||
                   ' ^ ' || p_coll(sql%bulk_exceptions(i).error_index).id_item ||
                   ' Err: ' || sqlerrm(sql%bulk_exceptions(i).error_code * -1));
        logger.log
          ('PK: ' || p_coll(sql%bulk_exceptions(i).error_index).id_proceso ||
           ' ^ ' || p_coll(sql%bulk_exceptions(i).error_index).id_item ||
           ' ^ ' || p_coll(sql%bulk_exceptions(i).error_index).id_personal ||
           ' Err: ' || sqlerrm(sql%bulk_exceptions(i).error_code * -1));

      end loop;
      raise;
  end;

  procedure upd(
    p_rec in proceso_bono_obrero_pers%rowtype
  )
    is
  begin
    update proceso_bono_obrero_pers t
       set row = p_rec
     where t.id_proceso = p_rec.id_proceso and t.id_item = p_rec.id_item
       and t.id_personal = p_rec.id_personal;
  end;

  procedure upd(
    p_coll in aat
  )
    is
  begin
    forall
      i in 1 .. p_coll.count save exceptions
      update proceso_bono_obrero_pers
         set row = p_coll(i)
       where id_proceso = p_coll(i).id_proceso and id_item = p_coll(i).id_item
         and id_personal = p_coll(i).id_personal;
  exception
    when forall_err then
      for i in 1 .. sql%bulk_exceptions.COUNT loop
        logger.log('PK: ' || p_coll(sql%bulk_exceptions(i).error_index).id_proceso ||
                   ' ^ ' || p_coll(sql%bulk_exceptions(i).error_index).id_item ||
                   ' Err: ' || sqlerrm(sql%bulk_exceptions(i).error_code * -1));
        logger.log
          ('PK: ' || p_coll(sql%bulk_exceptions(i).error_index).id_proceso ||
           ' ^ ' || p_coll(sql%bulk_exceptions(i).error_index).id_item ||
           ' ^ ' || p_coll(sql%bulk_exceptions(i).error_index).id_personal ||
           ' Err: ' || sqlerrm(sql%bulk_exceptions(i).error_code * -1));
      end loop;
      raise;
  end;

  procedure del(
    p_id_proceso in  proceso_bono_obrero_pers.id_proceso%type
  , p_id_item in     proceso_bono_obrero_pers.id_item%type
  , p_id_personal in proceso_bono_obrero_pers.id_personal%type
  )
    is
  begin
    delete
      from proceso_bono_obrero_pers t
     where t.id_proceso = p_id_proceso and t.id_item = p_id_item and t.id_personal = p_id_personal;
  end;

  function
    onerow(
    p_id_proceso in  proceso_bono_obrero_pers.id_proceso%type
  , p_id_item in     proceso_bono_obrero_pers.id_item%type
  , p_id_personal in proceso_bono_obrero_pers.id_personal%type
  ) return proceso_bono_obrero_pers%rowtype result_cache is
    rec proceso_bono_obrero_pers%rowtype;
  begin
    select *
      into rec
      from proceso_bono_obrero_pers t
     where t.id_proceso = p_id_proceso and t.id_item = p_id_item and t.id_personal = p_id_personal;

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
      from proceso_bono_obrero_pers;

    return coll;
  end;

  function
    exist(
    p_id_proceso in  proceso_bono_obrero_pers.id_proceso%type
  , p_id_item in     proceso_bono_obrero_pers.id_item%type
  , p_id_personal in proceso_bono_obrero_pers.id_personal%type
  ) return boolean is
    dummy pls_integer;
  begin
    select 1
      into dummy
      from proceso_bono_obrero_pers t
     where t.id_proceso = p_id_proceso and t.id_item = p_id_item and t.id_personal = p_id_personal;

    return true;
  exception
    when no_data_found then
      return false;
    when too_many_rows then
      return true;
  end;
end api_proceso_bono_obrero_pers;

create or replace public synonym api_proceso_bono_obrero_pers for api_proceso_bono_obrero_pers;
