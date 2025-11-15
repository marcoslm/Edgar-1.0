
'process stdio redirect, bidirectional, need >= WinNT
' will NOT work on Win9x
' tested using fb v0.15,16,17,18 on XP Pro, 21 on Vista
#include once "windows.bi"
'
dim Shared As integer res,cexit
dim Shared As uinteger avail,bget,bread,bwrite
dim Shared As string buf,cs,fs
'
type tagIoParams
    pi as PROCESS_INFORMATION
    si as STARTUPINFO
    read_stdout as HANDLE
    write_stdin as HANDLE
end type
dim Shared IoParams as tagIoParams
declare function io_setup() as tagIoParams
Declare Sub Subproceso (Comando As String, Parametros As String)


Sub Subproceso(comando As String, parametros As String)
	'
	'handle setup
	IoParams=io_setup
	'
	'prog to execute
	fs=comando
	'prog paramters
	cs=parametros
	
	'
	cs=" " & cs 'need space to prefix command params
	'
	'start the child process, res=1 is good
	res=CreateProcess(strptr(fs),strptr(cs),NULL,NULL,TRUE,_
	                  NULL,NULL,NULL,@IoParams.si,@IoParams.pi)
	'
	if res<>1 then
	    print "No se puede iniciar el motor de sintesis de voz."
	    Print "Edgar se ha quedado colgado. Pulsa una tecla para salir."
	    sleep
	    end
	end if
	'
	'if cexit = 259 then process is alive and waiting..
	sleep 100
	res=GetExitCodeProcess(IoParams.pi.hProcess,@cexit)
	'
	if res=0 or cexit<>259 then
	    print "No se puede iniciar el motor de sintesis de voz."
	    Print "Edgar se ha quedado colgado. Pulsa una tecla para salir."
	    sleep
	    end
	end If
	
	
	
		'send whatever to the child process
	'buf="prueba de síntesis de voz." & chr(10)'need to terminate each line written
	'res=WriteFile(IoParams.write_stdin,strptr(buf),len(buf),@bwrite,NULL)
	'end sending whatever
	'
	CloseHandle(IoParams.write_stdin) 'tells client proc that
	'                                 'you are through writing
	'
	'wait for child proc to exit
	res=WaitForSingleObject(IoParams.pi.hProcess,20000)'Esperamos a que termine el proceso en 20 segundos max.
	if res<>0 then
	    print "El motor de sintesis de voz ha fallado. Edgar se ha colgado y debe cerrarse (olvidara lo aprendido en esta sesion)."
	    Print "Pulsa una tecla para salir."
	    sleep
	    end
	end If
	
End Sub


function io_setup() as tagIoParams
'
    dim res as integer
    dim IoParams as tagIoParams
    '
    dim as SECURITY_ATTRIBUTES sa
    sa.nLength = len(sa)
    sa.lpSecurityDescriptor = NULL
    sa.bInheritHandle = TRUE
    '
    dim as HANDLE newstdin,newstdout,hErrorWrite
    '
    res=CreatePipe(@newstdin,@IoParams.write_stdin,@sa,0)
    SetHandleInformation(IoParams.write_stdin,HANDLE_FLAG_INHERIT,0)
    '
    res=CreatePipe(@IoParams.read_stdout,@newstdout,@sa,0)
    SetHandleInformation(IoParams.read_stdout,HANDLE_FLAG_INHERIT,0)
    '
    res=DuplicateHandle(GetCurrentProcess(),newstdout,_
        GetCurrentProcess(),@hErrorWrite,0,_
        TRUE,DUPLICATE_SAME_ACCESS)
    '
    GetStartupInfo(@IoParams.si)
    IoParams.si.dwFlags = STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW
    IoParams.si.wShowWindow = SW_HIDE
    IoParams.si.hStdOutput  = newstdout
    IoParams.si.hStdError   = newstdout
    IoParams.si.hStdInput   = newstdin
    '
    return IoParams
'
end function
 