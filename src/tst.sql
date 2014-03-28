set serveroutput on size unlimited
declare
    --get instance of logger
    l Logger := logmanager.getlogger();
    
procedure mydolog is
procedure dolog is
begin
    l.entry;
    l.trace('hello world trace');
    L.debug('hello world debug');
    l.INFO('hello world info');
    l.WARN('hello world warn');
    l.error('hello world error');
    l.FATAL('hello world fatal');
    L.DEBUG('hello world debug');
    l.exit;
end;
begin
print_call_stack;
dolog;
end;

BEGIN
--  dolog;
  mydolog;
end;
/
/*
DECLARE
      cs utl_call_stack.callstack;
    --Depth pls_integer := UTL_Call_Stack.Dynamic_Depth();
  BEGIN
  dbms_output.put_line(dbms_utility.format_call_stack);  
 --dbms_output.put_line('depth:'||Depth);  
    cs := utl_call_stack.getcallstack;
       FOR j IN  cs.FIRST..cs.LAST loop
         DBMS_Output.Put_Line( utl_lms.format_message('%s - %s - %s - %s', cs(j).handle , to_char(cs(j).line), cs(j).caller_type, cs(j).object_name ) );
      
       end loop;
end;

*/
