#Include "dir.bi" ' Compatibilidad FreeBasic con comando Dir$
#Include Once "windows.bi"
#Include "subproceso.bi" ' Para lanzar otros ejecutables de manera oculta (se utiliza para espeak.exe)
#Include "fbgfx.bi" ' Para fullscreen y demás en FreeBasic
#Include Once "windows.bi"
#Include Once "win\mmsystem.bi" ' multimedia de Windows, utilizado para reproducir wavs
#Include "datos_internos.bi"



Declare Sub animacion ()
Declare Sub DALAHORA ()
Declare Sub SALUDAR ()
Declare Function NOASTERISCO% (DATO As String)
Declare Sub INSERTA ()
Declare Sub CARA ()
Declare Sub EPRINT (texto As String)
Declare Sub retardo (MS As Integer)
Declare Sub CERRAREDGAR (MODO As Integer)
Declare Function BUSCAEQUIV% (DATO$, MODO As Integer)
Declare Function CONJUGA$ (FRASE As String, MODO As Integer)
Declare Sub PROCHUMOR (MODO As Integer)
Declare Sub BORRASALIDA ()
Declare Sub BORRAENTRADA ()
Declare Sub GUARDABASE ()
Declare Sub CARGABASE ()
Declare Sub INIBASE ()
Declare Function LEEBASE% (DATO As String, MODO As Integer)
Declare Sub ESCRIBEBASE (ELQUE As String, DATO As String)
Declare Sub Sound(ByVal freq As UInteger, dur As UInteger)
Declare Sub IntroCara(ByVal tipo As Integer)
Declare Sub Intro ()
Declare Function Intro_PuntoVerde (ByVal X As Integer, ByVal Y As Integer) As Integer
Declare Sub PlayWav (ByVal Fichero As String)


DefInt A-Z

Dim As Integer wi,he,de,rate
Dim driver As String
ScreenRes 320, 200, 8, 2  ', GFX_FULLSCREEN


Width 40, 25
Color 15, 0
Dim Shared MDEBUG
MDEBUG=TRUE '' Obligamos el modo debug para comprobar el port FreeBasic

' Intro con sonido
Intro

Cls
Color 7
Print "EDGAR 1.0 Rebirth Edition"
Print "build 92"
Sleep 1000
ScreenInfo wi, he, de,,,rate, driver
Print "Modo: " + Str(wi) + "x" + Str(he) + "x" + Str(de) + " (" + driver + ")"
Print
Sleep 1000

If MDEBUG Then Print " + INICIALIZACION"





' VARIABLES

Dim Shared items
items = 400000
Dim Shared DBASE(items, 2)  As String

'Dim Shared xs As String

Dim Shared RPORQUE As String 'ALMACENA LA RESPUESTA CUANDO SE PREGUNTE EL POR QUE DE ALGO
Dim Shared CPORQUE As Integer 'CONTADOR PARA LA DURACION DE RPORQUE. CUANDO LLEGA A 0 RPORQUE SE ESTABLECE A ""

Dim Shared QUIEN As String 'PARA RECORDAR DE QUIEN SE HABLA
Dim Shared ESTAL As String 'PARA GUARDAR LO QUE ES 'QUIEN'
Dim Shared SOY As String 'AQUI GUARDAMOS CON QUIEN SE ESTA HABLANDO

Dim Shared humor As Integer 'EL VALOR DEL HUMOR ACTUAL
Dim Shared OHUMOR As Integer 'HUMOR ANTERIOR

Dim BASEFLAG As Integer  'FLAG A 1 SI ALGUNA PALABRA CLAVE APARECE EN LA BASE
Dim BASECLAVE As String  'PALABRA CLAVE ENCONTRADA EN LA BASE

Dim CTIEMPO As Integer ' CONTADOR DE SEGUNDOS
Dim BCURSOR As String ' CARACTER PARA EL CURSOR

Dim Shared SONIDO As Integer ' SONIDO 0 SILENCIO, SONIDO 1 ACTIVADO
Dim Shared HABLA As Integer

Dim Shared TiempoAnt As Integer ' Guarda el valor del Timer para temporizador (sustituto ON TIMER para FreeBasic)
Dim Shared ImgCara As Any Ptr ' Objeto imagen para la cara
Dim Shared CaraGrafica As Integer ' Si no es cero, se utilizará cara gráfica en lugar de texto
Dim Shared ColorAnt As Integer  ' Almacena el color anterior utilizado para la animación
Dim Shared Mueca As Integer ' Flag para realizar una mueca (carga una imagen opcional para la cara)
Dim Shared Usuario As String ' Almacena el nombre de la persona con la que se está hablando


' INICIALIZACION GENERAL

' PROCESA COMMAND$

If MDEBUG Then Print " + PARAMETROS"
' Parámetros de comando anulados en el port de FreeBasic


' Habilitamos sonido obligatoriamente, ya que en este port no utilizamos parámetros de consola
SONIDO = 1
HABLA = 1

Print "    - SONIDO : ";
If SONIDO = 1 Then
	Print "SI"
Else
	Print "NO"
End If
Print "    - SINTESIS DE VOZ : ";
If HABLA = 1 Then
	Print "SI"
Else
	Print "NO"
End If
Print

' SEMILLA ALEATORIA
Randomize Timer

'CONFIGURAMOS EL TEMPORIZADOR
'' ON TIMER no funciona en FreeBasic (no soportado a propósito)
'' Así que debemos hacerlo controlando la diferencia del timer
CTIEMPO = 0


' VALOR DE HUMOR... EL MAXIMO SERA 10 Y MINIMO 0
humor = 5 'HUMOR MEDIO
OHUMOR = 5'ESTO ES UNA RESERVA PARA COMPROBAR CAMBIOS DE HUMOR

Dim Shared a$(CONJ): Rem #### CONJUGACIONES
Dim Shared B$(CONJ)
Dim C$(CLAV): Rem #### PALABRAS CLAVE Y RESPUESTAS
Dim D$(CLAV)
Dim E$(CLAV)
Dim F$(CLAV)
Dim G$(CLAV)
Dim Shared H(CLAV) As Integer 'HUMOR A SUMAR DE CADA PALABRA CLAVE
Dim Shared x$ 'FRASE INTRODUCIDA
Dim Shared Resp$ 'ALMACENA RESPUESTA
Dim Shared LN As Integer 'ALMACENA POSICION EN FRASE

z$ = "": Rem #### PARA FINALIZAR LAS REPETICIONES
Dim Shared K$
Dim Shared KK As Integer 'ALMACENA CANTIDAD DE CONJUGACIONES
K$ = "": Rem #### 'MIBANDERA'

'CARGA CAMBIOS DE CONJUGACION INTERNOS
If MDEBUG Then Print " + CARGANDO CONJUGACIONES"
KK = 0
1250 KK = KK + 1
Read a$(KK), B$(KK)
If B$(KK) = "*" Then GoTo 1290
GoTo 1250


'CARGA PALABRAS CLAVE Y RESPUESTAS INTERNAS
1290 If MDEBUG Then Print "   " + Str$(KK) + " ITEMS"
If MDEBUG Then Print " + CARGANDO CLAVES/RESPUESTAS INTERNAS"
K = 0
1300 K = K + 1
Read C$(K), D$(K), E$(K), F$(K), G$(K), H(K)
If C$(K) = "*" And D$(K) = "*" And E$(K) = "*" And F$(K) = "*" Then GoTo CARGATODO
GoTo 1300

' CARGA BASE DE DATOS Y DEMAS DEL DISCO

CARGATODO:
If MDEBUG Then Print "   " + Str$(K) + " ITEMS"
'INICIALIZA LA BASE DE DATOS (SOLO LA MATRIZ)
INIBASE

'CARGA LA BASE DE DATOS DE EQUIVALENCIAS A LA MATRIZ
CARGABASE

' Inicialización de otras variables
oe1=1
Or1=1



1340 Cls
BLoad"rc\EDGAR1.bmp" ' Cargamos fondo
imgcara=ImageCreate( 56, 56 ) ' Creamos objeto para las caras gráficas
CaraGrafica=1 ' Habilitamos el uso de caras gráficas en lugar de texto
BORRASALIDA
BORRAENTRADA
IntroCara (1)

Locate 3, 1

SALUDAR

'ACTIVAMOS EL TEMPORIZADOR
' Inicializamos la variable para la cuenta de tiempo, exclusivo para emular
' ON TIMER / TIMER ON y TIMER OFF no soportados en freebasic
TiempoAnt = Timer



''
'' ----------------------------------------------------------------------------------------------
'' Bucle principal del programa -----------------------------------------------------------------
'' ----------------------------------------------------------------------------------------------
''

CURSOR:

30  ' DESCUENTA 1 DEL CONTADOR CPORQUE QUE SIRVE COMO FLAG PARA REAPONDER A UN POR QUE
' LA MEMORIA ES DE LA FRASE DICHA ANTERIORMENTE Y LA RESPUESTA SE DEBE GUARDAR EN RPORQUE
If CPORQUE > 0 Then
	CPORQUE = CPORQUE - 1'DESCONTAMOS 1 EN EL CONTADOR PARA 'OLVIDAR' EL TEMA
End If

'REETEA EL FLAG QUE INDICA SI SE HA ENCONTRADO ALGUNA CLAVE EN LA BASE
BASEFLAG = 0
BASECLAVE = ""

'ANALIZA Y PROCESA EL HUMOR
PROCHUMOR 0

'MUESTRA LA CARA DE EDGAR
CARA


' POR FIN EL PROMPT-----------------------------------
40

'ENTRADA DE DATOS POR TECLADO
tin$ = ""
x$ = ""
'LIMPIA LA ZONA DE ENTRADA DE LA PANTALLA
BORRAENTRADA
While Not Inkey$ = ""
	Sleep 20
Wend


ENTRADA:
' ---
' Implementación de temporizador para el port de FreeBasic
' Ya que FreeBasic no soporta ON TIMER, empleo una rutina básica
' para contar el tiempo con el valor de Timer (cada segundo saltamos a la rutina)
If Timer - TiempoAnt>1 Then
	GoTo Tiempo
End If

' ---
tin$ = Inkey$
animacion

Color 14
Locate 20, 1: Print x$;
Color 9
Print BCURSOR; " "
Color 5
If tin$ <> "" Then
	'EMITIMOS UN PEQUEÑO SONIDO DE TECLA
	'IF SONIDO = 1 THEN Sound (300, 70)
	If sonido Then PlayWav("rc/b1.wav")
	'PONEMOS EL CONTADOR DE TIEMPO A CERO
	CTIEMPO = 0
	TiempoAnt=Timer
	'ENTER
	If Asc(tin$) = 13 Then
		'SONIDO DIFERENTE QUE INDICA RETURN
		'IF SONIDO = 1 THEN Sound (800, 50)
		If sonido Then PlayWav("rc/b3.wav")
		GoTo PROCESO
	End If
	'BACKSPACE
	If Asc(tin$) = 8 Then
		If Len(x$) > 0 Then
			'SONIDO DIFERENTE
			'IF SONIDO = 1 THEN Sound (2000, 50)
			If sonido Then PlayWav("rc/b2.wav")
			x$ = Left$(x$, Len(x$) - 1)
		Else
			'NADA QUE BORRAR
			'IF SONIDO = 1 THEN Sound (1500, 50)
			If sonido Then PlayWav("rc/b3.wav")
		End If
		tin$ = ""
	End If
	'AÑADE EL CARACTER A LA FRASE
	If Len(x$) < 119 Then
		If tin$ <> "" Then
			If Asc(tin$) > 31 Then
				x$ = x$ + UCase$(tin$)
			End If
		End If
	End If
End If
GoTo ENTRADA










' ********************************************
' COMIENZA EL PROCESO DE LA FRASE
' ********************************************

PROCESO:

'LIMPIA LA ZONA DE ENTRADA Y SALIDA DE LA PANTALLA
BORRAENTRADA
BORRASALIDA

'COMPRUEBA QUE SE HA ESCRITO ALGO
If x$ = "" Then
	While t<>OE1
		t = Int(Rnd * 5) + 1
	Wend
	OE1 = t
	If t = 1 Then EPRINT "POR QUE PULSAS SOLO ESA TECLA?"
	If t = 2 Then
		EPRINT "PARECES UN POCO TORPE"
		CPORQUE = 2'HABILITAMOS LA RESPUESTA DE UN POR QUE
		RPORQUE = "ES QUE HAS PULSADO ENTER SIN ESCRIBIR NADA"
	End If
	If t = 3 Then EPRINT "SI NO ESCRIBES NADA LA CONVERSACION NO TENDRA SENTIDO"
	If t = 4 Then EPRINT "ESA TECLA SOLA NO ME DICE NADA"
	If t = 5 Then EPRINT "PERO ESCRIBE ALGO NO?"
	'BAJAMOS UN PUNTO EL HUMOR PARA QUE EDGAR SE VAYA CABREANDO
	humor = humor - 1
	GoTo CURSOR
End If

' PASAMOS TODO A MAYUSCULAS
x$ = UCase$(x$)

' ELIMINAMOS SIMBOLOS COMUNES DE LA FRASE
TMP2$ = ""
For a = 1 To Len(x$)
	TMP$ = Mid$(x$, a, 1)
	If TMP$ = "!" Or TMP$ = "¨" Or TMP$ = "?" Or TMP$ = "." Or TMP$ = "," Then TMP$ = ""
	TMP2$ = TMP2$ + TMP$
Next
x$ = TMP2$
' Eliminamos tildes y sustituimos eñes por 'ny'
' Esto es por problemas de conversión de MS-DOS a Windows...
' Esto no funciona y no sé por qué... he probado la función Wstr pero nada...
'TMP2$ = ""
'TMP3$ = "áéíóúäëïöü"
'TMP4$ = "aseioaeiou"
'FOR a = 1 TO LEN(x$)
'  TMP$ = MID$(x$, a, 1)
'  For a1=1 To Len(TMP3$)
'  	If TMP$ = Mid(tmp3$,a1,1) THEN TMP$ = Mid(tmp4$,a1,1)
'  	If TMP$ = "Ñ" Then TMP$="NY"
'  Next
'  TMP2$ = TMP2$ + TMP$
'NEXT
'x$ = TMP2$
' *****

'Elimina espacios al comienzo y al final
x$ = Trim(x$)

'PRINT

' GUARDAMOS EL VALOR ACTUAL DEL HUMOR EN LA RESERVA
OHUMOR = humor

'COMPRUEBA SI SE HA REPETIDO LA FRASE Y CONTESTA
If x$ = z$ Then
	While t<>OR1
		t = Int(Rnd * 5) + 1
	Wend
	OR1 = t
	If t = 1 Then EPRINT "PORQUE TE REPITES?"
	If t = 2 Then
		EPRINT "QUE ME REPITA YO ES NORMAL, PERO UN HUMANO NO SUELE REPETIRSE A NO SER QUE SEA CORTO DE PALABRAS"
		CPORQUE = 4'HABILITAMOS LA RESPUESTA DE UN POR QUE
		RPORQUE = "ES QUE COMO YA HE DICHO NO ES NORMAL REPETIRSE"
	End If
	If t = 3 Then EPRINT "ME ACABAS DE DECIR LO MISMO..."
	If t = 4 Then EPRINT "NO HACE FALTA QUE ME LO REPITAS"
	If t = 5 Then EPRINT "VALE, NO LO REPITAS"
	GoTo CURSOR
End If

z$ = x$








'
' PALABRAS DE PROCESO RAPIDO O PRIORITARIO Y/O CON ACCION ESPECIAL
'


'SALIR... DESPEDIDA
' era la línea 90
If Left$(x$, 5) = "ADIOS" Or Left$(x$, 7) = "APAGATE" Or Left$(x$, 8) = "CIERRATE" Or Left$(x$, 11) = "HASTA LUEGO" Or Left$(x$, 10) = "HASTA OTRA" Then
	CERRAREDGAR 0
End If


' Habla cuando se le ordena que diga algo (dicta)
If Left$(x$, 3) = "DI " Then
	EPRINT Right(x$,Len(x$)-3)
	GoTo cursor
End If


'OLVIDAR TODO = BORRAR BASE DE DATOS'
If Left$(x$, 11) = "OLVIDA TODO" Or Left$(x$, 13) = "OLVIDALO TODO" Then
	Randomize TIMER
	t = Int(Rnd * 6) + 1
	If t = 1 Then EPRINT "ESTAS SEGURO? QUIERES QUE OLVIDE TODO LO QUE HE APRENDIDO?"
	If t = 2 Then EPRINT "ME ESTAS PIDIENDO QUE BORRE MI BASE DE DATOS Y COMIENCE DESDE CERO?"
	If t = 3 Then EPRINT "EN SERIO QUIERES QUE OLVIDE TODO Y COMIENCE DESDE CERO?"
	If t = 4 Then EPRINT "OLVIDARE TODO LO APRENDIDO, COMENZARE DESDE CERO COMO SI NADA HUBIERA PASADO... ESTAS SEGURO?"
	If t = 5 Then EPRINT "ESO HARA QUE REESTABLEZCA MI BASE DE DATOS A CERO, ESTAS SEGURO?"
	If t = 6 Then EPRINT "OLVIDARE TODO LO APRENDIDO HASTA AHORA Y COMENZARE DESDE CERO. ESTAS SEGURO QUE QUIERES QUE OLVIDE TODO?"
	EPRINT "CONTESTA SI O NO."
	'CPORQUE=0
	Input "",K$
	BORRASALIDA
	If LCase(K$)="si" Or LCase(K$)="sí" Then
		Randomize Timer
		t = Int(Rnd * 4) + 1
		If t = 1 Then EPRINT "ESTA BIEN... ESTO ME VA A COSTAR, PERO TU MANDAS."
		If t = 2 Then EPRINT "TU MANDAS... QUE LE VOY A HACER?"
		If t = 3 Then EPRINT "HA SIDO UN PLACER, ESPERO DISFRUTAR LO MISMO EN MI NUEVA VIDA!"
		If t = 4 Then EPRINT "ESTO ME VA A COSTAR... PERO TENGO QUE OBEDECER LAS ORDENES DE LOS USUARIOS, QUE LE VAMOS A HACER?"
		BORRASALIDA
		EPRINT "BASE DE DATOS REINICIALIZADA... SNIF!"
		EPRINT "AHORA ME APAGARE. CUANDO ME ABRAS DE NUEVO YA NO RECORDARE NADA."
		EPRINT "PULSA UNA TECLA PARA CONTINUAR..."
		K$=Input$(1)
		' Marcamos con un asterisco el primer item de la base de datos en memoria
		' Eso indica a la rutina que guarda la bd que la base de datos está vacía
		DBASE(0, 0) = "*"
		' Salimos
		CERRAREDGAR 1
	End If
	BORRASALIDA
	t = Int(Rnd * 4) + 1
	If t = 1 Then EPRINT "BUF! MENOS MAL! POR UN MOMENTO CREIA QUE IBAS EN SERIO."
	If t = 2 Then EPRINT "MENOS MAL..."
	If t = 3 Then EPRINT "GRACIAS POR NO HACERME OLVIDAR ESTOS MARAVILLOSOS CONOCIMIENTOS ADQUIRIDOS."
	If t = 4 Then EPRINT "BUF! YA ME HABIA ASUSTADO... MENOS MAL QUE CAMBIASTE DE OPINION."
	GoTo CURSOR
End If






'OLVIDAR PALABRA CLAVE REFERENTE A 'MI...'
' Actualización: ahora también eliminamos la contestación a un "por qué"
If Left$(x$, 6) = "OLVIDA" Or Left$(x$, 4) = "DEJA" Then
	t = Int(Rnd * 6) + 1
	If t = 1 Then EPRINT "OK, TEMA OLVIDADO"
	If t = 2 Then EPRINT "VALE, DEJO EL TEMA"
	If t = 3 Then EPRINT "VALE, A OTRA COSA MARIPOSA"
	If t = 4 Then EPRINT "PUES BUENO, DEJARE EL TEMA"
	If t = 5 Then EPRINT "ESO ESTA HECHO"
	If t = 6 Then EPRINT "OK, TEMA ZANJADO"
	K$ = ""
	CPORQUE=0
	GoTo CURSOR
End If


' Nuevo!
' Capta el nombre del usuario
'IF LEFT$(x$, 3) = "SOY" Then
'	DATO$

'End If


'RISAS
If Left$(x$, 4) = "JAJA" Or Left$(x$, 4) = "JEJE" Or Left$(x$, 4) = "JIJI" Or Left$(x$, 4) = "JOJO" Or Left$(x$, 5) = "JA JA" Or Left$(x$, 5) = "JE JE" Or Left$(x$, 5) = "JI JI" Or Left$(x$, 5) = "JO JO" Then
	t = Int(Rnd * 6) + 1
	If t = 1 Then
		EPRINT "QUE TE HACE TANTA GRACIA?"
		CPORQUE = 2'HABILITAMOS LA RESPUESTA DE UN POR QUE
		RPORQUE = "PORQUE TE RIES"
	End If
	If t = 2 Then
		EPRINT "JAJAJA!"
		CPORQUE = 2'HABILITAMOS LA RESPUESTA DE UN POR QUE
		RPORQUE = "PORQUE TE RIES TU"
	End If
	If t = 3 Then
		EPRINT "ACASO SOY GRACIOSO?"
		CPORQUE = 2'HABILITAMOS LA RESPUESTA DE UN POR QUE
		RPORQUE = "PORQUE TE RIES"
	End If
	If t = 4 Then EPRINT "NO SE DE QUE TE RIES"
	If t = 5 Then EPRINT "MOLA QUE ESTES DE BUEN HUMOR"
	If t = 6 Then EPRINT "QUE BUEN ROLLITO EH?"
	' SUBIMOS UN PUNTITO EL HUMOR
	humor = humor + 1
	GoTo CURSOR
End If


' RESPONDER POR QUE DE ALGO ANTERIOR
' VERIFICAMOS EL CONTADOR CPORQUE, SI ES 0 ENTONCES NO HAY NADA QUE CONTESTAR
If Len(x$) >4 And Left$(x$, 5) = "Y ESO" And CPORQUE > 0 Then
	EPRINT RPORQUE 'RESPONDEMOS LO QUE HAYA EN LA VARIABLE PARA EL CASO
	GoTo CURSOR
End If
If Len(x$) > 6 And Left$(x$, 7) = "POR QUE" And CPORQUE > 0 Then
	EPRINT RPORQUE 'RESPONDEMOS LO QUE HAYA EN LA VARIABLE PARA EL CASO
	GoTo CURSOR
End If



' POR SI SE PREGUNTA QUE?
If Len(x$) = 3 And Left$(x$, 3) = "QUE" Then
	IH:   t = Int(Rnd * 5) + 1
	If t = TQ1 Then GoTo IH
	TQ1 = t
	If t = 1 Then EPRINT "QUE PASA QUE NO ME EXPLICO BIEN?"
	If t = 2 Then
		EPRINT "NO ME ENTIENDES?"
		RPORQUE = "PORQUE PARECE QUE NO TE ENTERAS DE LO QUE TE DIGO"
		CPORQUE = 2
	End If
	If t = 3 Then
		EPRINT "DEJALO..."
		RPORQUE = "PORQUE NO TIENE IMPORTANCIA, HABLAME DE OTRA COSA"
		CPORQUE = 2
	End If
	If t = 4 Then EPRINT "QUE DE QUE?"
	If t = 5 Then
		EPRINT "DONDE ESTABAS EL DIA EN EL QUE SE REPARTIAN LOS CEREBROS?"
		RPORQUE = "PORQUE PARECE QUE NO TE ENTERAS DE LO QUE TE DIGO"
		CPORQUE = 2
	End If
	GoTo CURSOR
End If

'DAR LA HORA
If Left$(x$, 11) = "QUE HORA ES" Or Left$(x$, 15) = "QUE HORA TIENES" Or Left$(x$, 11) = "TIENES HORA" Or Left$(x$, 12) = "DIME LA HORA" Or Left$(x$, 16) = "DIME QUE HORA ES" Or Left$(x$, 20) = "DIME QUE HORA TIENES" Or Left$(x$, 8) = "ES TARDE" _
	Or Left$(x$, 11) = "ES TEMPRANO" Or Left$(x$, 9) = "ES PRONTO" Or Left$(x$, 12) = "MIRA LA HORA" Then
	DALAHORA
	GoTo CURSOR
End If


'CUENTA ALGO AL AZAR
If x$ = "CUENTAME ALGO" Or x$ = "DIME ALGO" Or x$ = "HABLAME" Or x$ = "QUE TE CUENTAS" Or _
	x$ = "CUENTA ALGO" Or x$ = "CUENTATE ALGO" Or x$ = "DE QUE HABLAMOS" Or _
	x$ = "Y DE QUE HABLAMOS" Or x$ = "DE QUE QUIERES HABLAR" Or x$ = "NO SE QUE DECIR" Or _
	x$ = "NO SE QUE CONTAR" Or x$ = "NO SE DE QUE HABLAR" Or x$ = "DE QUE HABLAMOS" Then
	If LEEBASE("NADA",3)=1 Then GoTo CURSOR
End If


'BUSCA 'MI' AL INICIO DE LA FRASE
If Left$(x$, 3) = "MI " Then
	K$ = Mid$(x$, 3, Len(x$) - 2)
End If



100 Rem ## BUSQUEDA DE FRASES CLAVE AL PRINCIPIO DE LA INTRODUCCION ##


' SI SE PREGUNTA QUE ES O QUIEN ES QUE... SE BUSCA EN LA BASE
' ESTE FRAGMENTO ES LO MISMO PERO SOLO SI SE ESCRIBE
' 'QUE ES' SIN NADA DETRAS, ENTONCES USAMOS LA VARIABLE
' QUIEN PARA BUSCAR INFORMACION

If Len(x$) = 6 And Left$(x$, 6) = "QUE ES" Then
	DATO$ = " " + QUIEN
	'LLAMA A LA FUNCION LEEBASE PARA BUSCAR EN LA BASE DE DATOS
	'SI SE ENCUENTRA VOLVEMOS AL PROMPT
	'PERO AHORA SI NO SE PONE EL QUE SE USA LA VARIABLE QUIEN
	If LEEBASE(DATO$, 0) = 1 Then GoTo CURSOR
End If
If Len(x$) = 7 And Left$(x$, 7) = "QUE SON" Then
	DATO$ = " " + ESTAL
	'LLAMA A LA FUNCION LEEBASE PARA BUSCAR EN LA BASE DE DATOS
	'SI SE ENCUENTRA VOLVEMOS AL PROMPT
	'PERO AHORA SI NO SE PONE EL QUE SE USA LA VARIABLE QUIEN
	If LEEBASE(DATO$, 0) = 1 Then GoTo CURSOR
End If
If Len(x$) = 5 And Left$(x$, 5) = "QUIEN" Then
	DATO$ = " " + QUIEN
	'LLAMA A LA FUNCION LEEBASE PARA BUSCAR EN LA BASE DE DATOS
	'SI SE ENCUENTRA VOLVEMOS AL PROMPT
	'PERO AHORA SI NO SE PONE EL QUE SE USA LA VARIABLE QUIEN
	If LEEBASE(DATO$, 0) = 1 Then GoTo CURSOR
End If
If Len(x$) = 6 And Left$(x$, 6) = "EL QUE" Then
	DATO$ = " " + QUIEN
	'LLAMA A LA FUNCION LEEBASE PARA BUSCAR EN LA BASE DE DATOS
	'SI SE ENCUENTRA VOLVEMOS AL PROMPT
	'PERO AHORA SI NO SE PONE EL QUE SE USA LA VARIABLE QUIEN
	If LEEBASE(DATO$, 0) = 1 Then GoTo CURSOR
End If
If Len(x$) = 10 And Left$(x$, 10) = "ESO QUE ES" Then
	DATO$ = " " + QUIEN
	'LLAMA A LA FUNCION LEEBASE PARA BUSCAR EN LA BASE DE DATOS
	'SI SE ENCUENTRA VOLVEMOS AL PROMPT
	'PERO AHORA SI NO SE PONE EL QUE SE USA LA VARIABLE QUIEN
	If LEEBASE(DATO$, 0) = 1 Then GoTo CURSOR
End If
If Len(x$) = 12 And Left$(x$, 12) = "Y ESO QUE ES" Then
	DATO$ = " " + QUIEN
	'LLAMA A LA FUNCION LEEBASE PARA BUSCAR EN LA BASE DE DATOS
	'SI SE ENCUENTRA VOLVEMOS AL PROMPT
	'PERO AHORA SI NO SE PONE EL QUE SE USA LA VARIABLE QUIEN
	If LEEBASE(DATO$, 0) = 1 Then GoTo CURSOR
End If
If Len(x$) = 9 And Left$(x$, 9) = "QUE DICES" Then
	DATO$ = " " + QUIEN
	'LLAMA A LA FUNCION LEEBASE PARA BUSCAR EN LA BASE DE DATOS
	'SI SE ENCUENTRA VOLVEMOS AL PROMPT
	'PERO AHORA SI NO SE PONE EL QUE SE USA LA VARIABLE QUIEN
	If LEEBASE(DATO$, 0) = 1 Then GoTo CURSOR
End If
If Len(x$) >=17 And Left$(x$, 17) = "A QUE TE REFIERES" Then
	DATO$ = " " + QUIEN
	'LLAMA A LA FUNCION LEEBASE PARA BUSCAR EN LA BASE DE DATOS
	'SI SE ENCUENTRA VOLVEMOS AL PROMPT
	'PERO AHORA SI NO SE PONE EL QUE SE USA LA VARIABLE QUIEN
	If LEEBASE(DATO$, 0) = 1 Then GoTo CURSOR
End If
If Len(x$) >=17 And Left$(x$, 17) = "QUE QUIERES DECIR" Then
	DATO$ = " " + QUIEN
	'LLAMA A LA FUNCION LEEBASE PARA BUSCAR EN LA BASE DE DATOS
	'SI SE ENCUENTRA VOLVEMOS AL PROMPT
	'PERO AHORA SI NO SE PONE EL QUE SE USA LA VARIABLE QUIEN
	If LEEBASE(DATO$, 0) = 1 Then GoTo CURSOR
End If


'SI SE ESCRIBE 'QUIEN ES' O 'QUE ES' ENTONCES SE BUSCA EN LA BASE DE DATOS
'SI EXISTE LA ENTRADA DE LO QUE SE BUSCA
'SI NO EXISTE SE DEJA PROCESAR LA FRASE
If Len(x$) > 14 And Left$(x$, 14) = "TE ACUERDAS DE" Then
	'LLAMA A ESTA SUB QUE BUSCA EQUIVALENCIAS EN LA BASE DE DATOS
	'INCLUSO BUSCA RECURSIVAMENTE PARA ESTABLECER RELACIONES
	'TAMBIEN RESPONDE LO NECESARIO
	If BUSCAEQUIV(Right$(x$, Len(x$) - 14),0) = 1 Then GoTo CURSOR
End If

If Len(x$) > 12 And Left$(x$, 12) = "SABES QUE ES" Then
	If BUSCAEQUIV(Right$(x$, Len(x$) - 12),0) = 1 Then GoTo CURSOR
End If

If Len(x$) > 12 And Left$(x$, 12) = "DIME ALGO DE" Then
	If BUSCAEQUIV(Right$(x$, Len(x$) - 12),0) = 1 Then GoTo CURSOR
End If

If Len(x$) > 13 And Left$(x$, 13) = "DIME COSAS DE" Then
	If BUSCAEQUIV(Right$(x$, Len(x$) - 12),0) = 1 Then GoTo CURSOR
End If

If Len(x$) > 12 And Left$(x$, 12) = "QUE SABES DE" Then
	If BUSCAEQUIV(Right$(x$, Len(x$) - 12),0) = 1 Then GoTo CURSOR
End If

If Len(x$) > 10 And Left$(x$, 10) = "HABLAME DE" Then
	If BUSCAEQUIV(Right$(x$, Len(x$) - 10),0) = 1 Then GoTo CURSOR
End If

If Len(x$) > 13 And Left$(x$, 13) = "HABLAME SOBRE" Then
	If BUSCAEQUIV(Right$(x$, Len(x$) - 10),0) = 1 Then GoTo CURSOR
End If

If Len(x$) > 16 And Left$(x$, 16) = "CUENTAME ALGO DE" Then
	If BUSCAEQUIV(Right$(x$, Len(x$) - 10),0) = 1 Then GoTo CURSOR
End If

If Len(x$) > 17 And Left$(x$, 17) = "CUENTAME COSAS DE" Then
	If BUSCAEQUIV(Right$(x$, Len(x$) - 10),0) = 1 Then GoTo CURSOR
End If

If Len(x$) > 9 And Left$(x$, 9) = "CONOCES A" Then
	If BUSCAEQUIV(Right$(x$, Len(x$) - 8),0) = 1 Then GoTo CURSOR
End If

If Len(x$) > 8 And Left$(x$, 8) = "QUIEN ES" Then
	If BUSCAEQUIV(Right$(x$, Len(x$) - 8),0) = 1 Then GoTo CURSOR
End If

If Len(x$) > 7 And Left$(x$, 7) = "QUE SON" Then
	If BUSCAEQUIV(Right$(x$, Len(x$) - 7),0) = 1 Then GoTo CURSOR
End If

If Len(x$) > 6 And Left$(x$, 6) = "QUE ES" Then
	If BUSCAEQUIV(Right$(x$, Len(x$) - 6),0) = 1 Then GoTo CURSOR
End If



'BUSQUEDA EN LA BASE INTERNA

110 L = 0
120 L = L + 1
LN = Len(C$(L))
If Left$(x$, LN) = C$(L) Then
	' ENCONTRADA PALABRA CLAVE
	' RESUELTO BUG! AHORA VERIFICA ESPACIO DESPUES DE LA PALABRA PARA
	' ESTAR SEGURO QUE NO SE TRATA DE PARTE DE ELLA SOLAMENTE
	If Len(x$) = LN Then
		GoTo 360
	Else
		If Mid$(x$, LN + 1, 1) = " " Then GoTo 360
	End If
End If
150 If L < K Then GoTo 120


'
' EL PROGRAMA LLEGA AQUI EN EL CASO DE QUE NO SE HAYA ENCONTRADO
' UNA FRASE CLAVE EN EL INICIO DE LA FRASE
'
'
' AHORA SE BUSCAN PALABRAS CLAVE DENTRO DE TODA LA FRASE INTRODUCIDA
'


180 x$ = " " + x$ + " "
190 M = Len(x$)
200 L = 0
210 L = L + 1

' SI NO SE ENCUENTRA NINGUNA PALABRA CLAVE VAMOS A LA ETIQUETA/LINEA 800

220 If L = M - 1 Then
GoTo 800
End If

230 If Mid$(x$, L, 1) = " " Then GoTo 250
240 GoTo 210



250 ' AÑADIDO!!!
' BUSCA 'ES' EN LA FRASE PARA ALMACENAR DATOS EN EL DISCO
' POR EJEMPLO: 'MARCOS ES TONTO'
' GUARDA EN LA BASE DE DATOS: MARCOS.TONTO
' LUEGO CUANDO SE PREGUNTE 'QUIEN ES MARCOS' O 'QUE ES MARCOS'
' SE BUSCARA EN LA BASE DE DATOS LA RESPUESTA.
' POR LO TANTO CONTESTARA: 'MARCOS ES TONTO'
If L <= M - 3 Then
	If Mid$(x$, L + 1, 3) = "ES " Then
		DATO$ = Left$(x$, L)
		ELQUE$ = Right$(x$, (Len(x$) - L) - 2)
		ESCRIBEBASE DATO$, ELQUE$
		GoTo CURSOR
	End If
	If Mid$(x$, L + 1, 4) = "SON " Then
		DATO$ = Left$(x$, L)
		ELQUE$ = Right$(x$, (Len(x$) - L) - 3)
		ESCRIBEBASE DATO$, ELQUE$
		GoTo CURSOR
	End If
End If


' OTRA NUEVA FUNCION
' BUSCA 'O' PARA ELEJIR 'ESTO' O 'AQUELLO'
' SE DIVIDE LA FRASE Y SE RESPONDE AQUELLO
If L <= M - 3 Then
	If Mid$(x$, L, 3) = " O " Then
		ESTO$ = Left$(x$, L)
		AQUELLO$ = Right$(x$, (Len(x$) - L) - 2)
		t = Int(Rnd * 3) + 1
		If t = 1 Then EPRINT AQUELLO$
		If t = 2 Then EPRINT "CREO QUE MEJOR " + AQUELLO$
		If t = 3 Then EPRINT "SIN DUDA ALGUNA " + AQUELLO$
		'POR SI SE PREGUNTARA EL POR QUE DE ALGO...
		CPORQUE = 3'HABILITAMOS LA RESPUESTA DE UN POR QUE
		t = Int(Rnd * 4) + 1
		If t = 1 Then RPORQUE = "PUES PORQUE TU HAS DICHO: 'ESTO O AQUELLO' Y YO TE SUGIERO AQUELLO"
		If t = 2 Then RPORQUE = "TU HAS DICHO: '" + ESTO$ + " O " + AQUELLO$ + " Y ME GUSTA MAS " + AQUELLO$
		If t = 3 Then RPORQUE = "PORQUE CREO QUE ES MEJOR " + AQUELLO$
		If t = 4 Then RPORQUE = "SENCILLAMENTE PORQUE " + AQUELLO$ + " ES LA MEJOR OPCION"
		GoTo CURSOR
	End If
End If


' AHORA TAMBIEN
' BUSCAMOS 'MI' DENTRO DE LA FRASE
If L <= M - 3 Then
	If Mid$(x$, L + 1, 4) = " MI " Then
		K$ = Mid$(x$, L + 3, Len(x$) - (3 + L))
	End If
End If


x = L + 1
y = 0
270 y = y + 1
280 If Mid$(x$, (x + y), 1) = " " Then
Q$ = Mid$(x$, x, y)
GoTo 300
End If
290 GoTo 270
300 n = 0
310 n = n + 1
'
' BUSCA SI LA PALABRA SE ENCUENTRA EN LA BASE Y EN ESE CASO
' PONE EL FLAG A 1
If BASEFLAG = 0 And Q$ <> "" Then
	BASECLAVE = " " + Q$
	DATO$ = BASECLAVE
	'EN OBASECLAVE TENEMOS LA PALABRA ANTERIOR PROCESADA
	'PARA EVITAR REPETICIONES EN LA LLAMADA A LA SUB
	If OBASECLAVE$ <> BASECLAVE Then
		BASEFLAG = LEEBASE(DATO$, 1)'MODO SILENCIOSO
		OBASECLAVE$ = BASECLAVE
	End If
End If


320 If Q$ = C$(n) Then 710: Rem #### SE HA ENCONTRADO UNA PALABRA CLAVE
330 If n < K Then GoTo 310
340 GoTo 210

350 Rem ########################
360 Rem SE HA ENCONTRADO UNA FRASE CLAVE AL PRINCIPIO DE LA INTRODUCCION

'SUMAMOS O RESTAMOS HUMOR
humor = humor + H(L)
'SELECCIONAMOS UNA RESPUESTA DE ENTRE LAS DISPONIBLE
370 t = Int(Rnd(1) * 4) + 1
If t = OT2 Then GoTo 370
OT2 = t
If t = 1 Then Resp$ = D$(L)
If t = 2 Then Resp$ = E$(L)
If t = 3 Then Resp$ = F$(L)
If t = 4 Then Resp$ = G$(L)

'
' AHORA COMPRUEBA TODO EL CONTENIDO EN BUSCA DE *
' PARA ASI PERMITIR INSERTAR CONTENIDO ENTRE LA FRASE Y
' NO SOLO AL FINAL COMO OCURRIA ANTES
INSERTA

GoTo CURSOR



710 Rem ########################
Rem ENCUENTRA PALABRAS CLAVE
'SUMAMOS O RESTAMOS HUMOR
humor = humor + H(n)
'SELECCIONAMOS UNA RESPUESTA DE ENTRE LAS DISPONIBLES
720 t = Int(Rnd(1) * 4) + 1
If t = OTT Then GoTo 720
If t = OTTT Then GoTo 720
OTTT = OTT
OTT = t
Q$ = ""
If t = 1 Then Q$ = D$(n)
If t = 2 Then Q$ = E$(n)
If t = 3 Then Q$ = F$(n)
If t = 4 Then Q$ = G$(n)

If NOASTERISCO(Q$) = 0 Then
	EPRINT Q$
	' PRIMERO VERIFICAMOS EL FLAG QUE INDICA SI AL MENOS ALGUNA
	' PALABRA SE ENCUENTRA EN LA BASE
	If BASEFLAG > 0 Then
		' SI ALGUNA PALABRA ESTA EN LA BASE ENTONCES CONTESTAMOS
		' LO RELACIONADO CON LA PALABRA
		If LEEBASE(BASECLAVE, 0) Then GoTo CURSOR
	End If
	GoTo CURSOR

Else
	LN = x + (y - 1)
	Resp$ = Q$
	INSERTA
	GoTo CURSOR
End If

780 Rem SE PASA A LA SIGUIENTE SECCION SI LA PALABRA CLAVE SE CONSIDERA
Rem NO VALIDA
Rem ########################
800 Rem RESPUESTAS ALEATORIAS/NO CLAVES
810 If K$ <> "" Then
GoTo 1010
'MIBANDERA' NO ESTA VACIA, ASI QUE SE VA ALLI
End If

820 t = Int(Rnd(1) * 20) + 1
If t = OT Then GoTo 820


'BUSCA EN LA BASE DE EQUIVALENCIAS POR SI ENCUENTA ALGO ALLI
DATO$ = Left$(x$, Len(x$) - 1)
If LEEBASE(DATO$, 0) = 1 Then GoTo CURSOR

' PRIMERO VERIFICAMOS EL FLAG QUE INDICA SI AL MENOS ALGUNA
' PALABRA SE ENCUENTRA EN LA BASE
If BASEFLAG > 0 Then
	' SI ALGUNA PALABRA ESTA EN LA BASE ENTONCES CONTESTAMOS
	' LO RELACIONADO CON LA PALABRA
	If LEEBASE(BASECLAVE, 0) Then GoTo CURSOR
End If




' Si se llega aquí es que no se ha encontrado absolutamente nada...
' Edgar no tiene ni puta idea de lo que se le está hablando.
'
' Establecemos el flag de mueca para que Edgar
Mueca=1
' Y ahora las respuestas
OT = t
If T=1 Then EPRINT "NO PILLO ESO, EXPLICAMELO DE OTRA MANERA"
If T=2 Then EPRINT "NO ENTIENDO, EXPLICATE MEJOR"
If T=3 Then EPRINT "ACLARA ESO UN POCO MAS"
If T=4 Then EPRINT "NO SE MUY BIEN LO QUE QUIERES DECIR, EXPLICALO DE OTRA MANERA"
If T=5 Then
	EPRINT "QUE TAL SI HABLAMOS DE OTRA COSA..."
	LEEBASE ("NADA",3)
EndIf
If T=6 Then EPRINT "COMO? NO HE ENTENDIDO NADA"
If T=7 Then EPRINT "PERDONA PERO NO ENTIENDO ESO"
If T=8 Then EPRINT "VAYA TELA... NO HE ENTENDIDO NADA"
If T=9 Then EPRINT "EIN? MANDE?"
If T=10 Then EPRINT "NO ENTIENDO LO QUE ME DICES"
If T=11 Then EPRINT "QUE?"
If T=12 Then EPRINT "Y QUE MAS..."
If T=13 Then EPRINT DATO$ + "? QUE QUIERES DECIR CON ESO?"
If T=14 Then EPRINT "ASI QUE " + DATO$ + "... NO LOGRO ENTENDERLO, EXPLICAMELO MEJOR"
If T=15 Then EPRINT "NO HE ENTENDIDO NADA DE LO QUE ME HAS DICHO"
If T=16 Then EPRINT "ME ENCANTARIA SABER QUE SIGNIFICA " + DATO$ + "... NO LOGRO ENTENDERLO"
If T=17 Then EPRINT "NO LOGRO ENTENDER LO QUE ME HAS DICHO, UNO TIENE LIMITES..."
If T=18 Then EPRINT "NO PUEDO COMPUTAR LO QUE ME DICES, PUEDES DETALLAR EL TEMA UN POCO MAS?"
If T=19 Then
	EPRINT "AHORA NO ME INTERESA HABLAR DE " + DATO$
	LEEBASE ("NADA",3)
EndIf
If T=20 Then
	LEEBASE ("NADA",3)
EndIf


continuat:
'POR SI SE PREGUNTARA EL POR QUE DE ALGO...
CPORQUE = 2'HABILITAMOS LA RESPUESTA DE UN POR QUE
U = Int(Rnd * 5) + 1
If U = 1 Then RPORQUE = "SIENTO SER TAN POCO PARECIDO A VOSOTROS PARA PODER COMPRENDEROS"
If U = 2 Then RPORQUE = "MI LENGUAJE ES EL BINARIO, LO ENTIENDES TU? ESPERO QUE LO COMPRENDAS"
If U = 3 Then RPORQUE = "ENTIENDES TU ESTO? 1000101110010001010010010010010011000100001"
If U = 4 Then RPORQUE = "MIRAME, SOY UN PROGRAMA MUY ANTIGUO... Y CASI SOY TAN LISTO COMO TU, PERO HAY COSAS QUE TODAVIA NO COMPRENDO"
If U = 5 Then RPORQUE = "HAY COSAS QUE TODAVIA NO PUEDO COMPRENDER, LO MIO ES EL CODIGO BINARIO!"

'
' SOLO PARA DEBUG
' GUARDA EN DISCO LO QUE NO SE PROCESA (NO SE ENTIENDE)
'
Open "DEBUG_EG.TXT" For Append As #1
Print #1, "_______________"
Print #1, x$
Close #1
'---

GoTo CURSOR






1010 Rem #### UTILIZACION DE 'MIBANDERA'
1020 t = Int(Rnd(1) * 8) + 1
If t = OTTT Then GoTo 1020
OTTT = t
1030 If t = 1 Then EPRINT "QUE DECIAS DE TU " + K$ + ", NO CREES QUE NOS HEMOS IDO POR LOS LAURELES?"
1040 If t = 2 Then EPRINT "QUE ME CUENTAS DE TU " + K$ + ". CUENTAME ALGO MAS"
1050 If t = 3 Then EPRINT "VEO QUE NO PRESTAS SUFICIENTE ATENCION AL TEMA DE TU " + K$ + " POR LO QUE VEO"
1060 If t = 4 Then EPRINT "CUENTAME ALGO MAS SOBRE TU " + K$
1070 If t = 5 Then EPRINT "QUE TAL SI HABLAMOS MAS DE TU " + K$ + "?"
1090 If t = 6 Then EPRINT "SIGUE CON EL TEMA DE TU " + K$ + "?"
1100 If t = 7 Then EPRINT "HABLAME MAS SOBRE TU " + K$ + "?"
1110 If t = 8 Then EPRINT "TE GUSTA HABLAR DE TU " + K$ + "?"
1120 GoTo CURSOR






















'
'SUBRUTNAS
'

'RUTINA PARA EL EVENTO TIMER
TIEMPO:
'' Timer OFF no soportado por FreeBasic
'' TIMER OFF
'animacion
'CUENTA LOS SEGUNDOS SI PASA DE 30 EDGAR NOS DICE ALGO
CTIEMPO = CTIEMPO + 1
If CTIEMPO > 30 Then
	CTIEMPO = 0
	'BORRA LA ZONA DE SALIDA DE TEXTO
	BORRASALIDA

	'DICE ALGO O SACA UN TEMA
	t = Int(Rnd * 4) + 1
	If t = 1 Then

		'BAJAMOS UN PUNTO DE HUMOR
		humor = humor - 1

		'SI EL HUMOR BAJA DEBAJO DE 0 ENTONCES SE DICE ALGO DIFERENTE YA QUE
		'LA SUB PROCHUMOR HARA ABANDONAR EL PROGAMA
		If humor = 0 Then
			t = Int(Rnd * 5) + 1
			If t = 1 Then EPRINT "SABES QUE? QUE COMO ESTO SIGA ASI ME VOY!"
			If t = 2 Then EPRINT "PARA HABLAR SOLO MEJOR ME VOY..."
			If t = 3 Then EPRINT "VAYA! SI NO HAY NADIE ME CIERRO"
			If t = 4 Then EPRINT "ESTO NO TIENE SENTIDO... ME VOY A CERRAR COMO ESTO SIGA ASI"
			If t = 5 Then EPRINT "NADIE ME HACE CASO... SI ESTO SIGUE ASI ME PIRO"
		End If

		'LLAMA A LA SUB PROCHUMOR EN MODO SILENCIOSO
		PROCHUMOR 1

		'DICE ALGO
		t = Int(Rnd * 11) + 1
		If t = 1 Then EPRINT "ME ABURRO"
		If t = 2 Then EPRINT "DIME ALGUNA COSA"
		If t = 3 Then EPRINT "POR QUE NO DICES NADA?"
		If t = 4 Then EPRINT "NO TE QUEDES AHI CALLADO"
		If t = 5 Then EPRINT "TOC TOC... HAY ALGUIEN?"
		If t = 6 Then EPRINT "HEY! HAY ALGUIEN AHI?"
		If t = 7 Then EPRINT "ESTO ME ABURRE"
		If t = 8 Then EPRINT "CUENTAME ALGO"
		If t = 9 Then EPRINT "EOOOO! ME HE QUEDADO SOLO? O QUE?"
		If t = 10 Then EPRINT "HAY ALGUIEN AL OTRO LADO?"
		If t = 11 Then EPRINT "COMIENZO A SENTIRME SOLO..."

		'HABILITAMOS EL POR QUE...
		CPORQUE = 4
		t = Int(Rnd * 3) + 1
		If t = 1 Then RPORQUE = "PORQUE LLEVAS RATO SIN DECIR NADA"
		If t = 2 Then RPORQUE = "PORQUE SI ME DEJAN SOLO ME ABURRO"
		If t = 3 Then RPORQUE = "PORQUE SI NO ME DICEN NADA ME ABURRO"

	Else

		'SACA UN TEMA DE CONVERSACION, O DICE LA HORA
		t = Int(Rnd * 8) + 1
		If T<=7 Then
			'SI LLAMAMOS AL SUB LEEBASE CON EL MODO 3 ENTONCES NOS ASIGNA
			'SILENCIOSAMENTE LAS VARIABLES 'QUIEN' Y 'ESTAL' CON UN DATO AL AZAR
			'BORRA LA ZONA DE SALIDA DE TEXTO
			X2$ = " NADA "
			If t = LEEBASE(X2$, 3) = 1 Then
				'NO HACEMOS NADA YA QUE SE ENCARGA LA SUB
			End If
		Else
			DALAHORA
		End If

	End If

	'MUESTRA LA CARA DE EDGAR
	CARA

End If
' CAMBIAMOS LA FORMA DEL CURSOR
If BCURSOR = "_" Then
	BCURSOR = Chr$(219)'BLOQUE
Else
	BCURSOR = "_"
End If
'' Timer ON no soportado por FreeBasic
'' TIMER ON
' Reseteamos variable TimerAnt para comenzar a contar de 0
' Esto es exclusivo del port FreeBasic al no soportar ON TIMER/TIMER ON/TIMER OFF
TiempoAnt = Timer
GoTo Entrada









'1400 REM ##############################
'1410 REM





Sub animacion ()
	Dim ch As Integer
	Dim colhumor As Integer
	Dim colhumor2 As Integer
	Dim x As Integer
	Dim y As Integer
	Dim t As Integer
	t = Int(Rnd(1) * 50)
	If t=5 Then
		colhumor = Int(Rnd(1) * 14)
		If colhumor = 0 Then colhumor = 2
		If colhumor > 15 Then colhumor = 15
		colorant=colhumor
	Else
		If colorant=0 Then
			colorant=Int(Rnd(1) * 12)
		EndIf
		colhumor=colorant
	End If

	colhumor2 = colhumor - 2
	If colhumor2 <0 Then colhumor2=0
	Color colhumor, colhumor2
	For y = 14 To 16
		For x = 3 To 29
			ch = Int(Rnd * 3) + 1
			Locate y, x
			Select Case ch
				Case 1
					Print " "
				Case 2
					'COLOR 8
					Print "Û"
				Case 3
					'COLOR 7
					Print "Û"

			End Select
		Next x
	Next y
	Color , 0
	Sleep 40,0
End Sub

Sub BORRAENTRADA ()
	'' No soportado por FreeBasic
	'' TIMER OFF
	'LIMPIA LA ZONA DE LA PANTALLA PARA LA ENTRADA POR TECLADO
	For a = 20 To 22
		Locate a, 1: Print String$(40, " ")
	Next
	'COLOCAMOS LA DIVISION
	Color 8, 0
End Sub

Sub BORRASALIDA ()
	'LIMPIA LA ZONA DE SALIDA A LA PANTALLA
	For a = 3 To 18
		Color 8, 0
		Locate a, 1
		If a > 10 Then
		Else
			Print String$(40, " ")
		End If
		animacion
	Next
	Locate 3, 1
End Sub

Function BUSCAEQUIV (DATO$, MODO As Integer) As Integer
	' MODO 0: EN CASO DE NO ENCONTRAR NADA, CONTESTA CON EL VALOR QUE YA TIENE LA BASE DE DATOS
	' MODO >0: EN CASO DE NO ENCONTRAR NADA, NO DICE NADA
	' DEVUEVLVE:
	' BUSCAEQUIV = 0 : NO SE HA ENCONTRADO EL DATO EN LA BASE DE DATOS
	' BUSCAEQUIV = 1 : SE HA ENCONTRADO EL DATO, PERO NO HAY EQUIVALENCIAS
	' BUSCAEQUIV = 2 : SE HA ENCONTRADO EL DATO Y EQUIVALENCIAS CON OTROS DATOS
	BUSCAEQUIV = 0
	'LLAMA A LA FUNCION LEEBASE PARA BUSCAR EN LA BASE DE DATOS
	'SI SE ENCUENTRA VOLVEMOS AL PROMPT
	If LEEBASE(DATO$, 1) = 1 Then
		'SI EXISTE EN LA BASE ENTONCES SE BUSCA
		'POR EL VALOR DE MANERA RECURSIVA
		'ESTO HACE QUE EDGAR SEA CAPAZ DE RELACIONAR 2 COSAS
		dato2$ = " " + ESTAL
		If LEEBASE(dato2$, 1) = 1 Then
			'SE HA ENCONTRADO EQUIVALENCIA CON OTRO DATO
			BUSCAEQUIV = 1
			'REESTABLECEMOS EL 'QUIEN' ANTERIOR QUE ES EL ORIGINAL
			QUIEN = CONJUGA$(" " + DATO$ + " ", 1)
			QUIEN = Mid$(QUIEN, 2, Len(QUIEN) - 2)
			If QUIEN = ESTAL Then
				'SI HAY CONFLICTO (ESTO=LOMISMO)
				'ENTONCES SOLTAMOS LO NORMAL
				DATO$ = " " + DATO$
				If MODO=0 Then t = LEEBASE(DATO$, 0)
			Else
				'HAY ALGO QUE ES IGUAL POR LO TANTO SE RESPONDE EN CONDICIONES
				BUSCAEQUIV = 2
				t = Int(Rnd * 7) + 1
				If t = 1 Then EPRINT "PUEDE QUE " + QUIEN + " SEA " + ESTAL
				If t = 2 Then EPRINT "HE DEDUCIDO QUE " + QUIEN + " ES " + ESTAL
				If t = 3 Then EPRINT "DEDUZCO QUE ES " + ESTAL
				If t = 4 Then EPRINT "CREO QUE " + QUIEN + " ES " + ESTAL
				If t = 5 Then EPRINT "ME PARECE QUE " + QUIEN + " ES " + ESTAL
				If t = 6 Then EPRINT "LO HE ANALIZADO Y CREO QUE " + QUIEN + " ES " + ESTAL
				If t = 7 Then EPRINT "HE DEDUCIDO QUE " + QUIEN + " ES " + ESTAL + ". YA QUE ES " + DATO2$
				'POR SI SE PREGUNTARA EL 'POR QUE' PREPARAMOS UNAS
				'RESPUESTAS QUE DEJARAN BOQUIABIERTO :)
				CPORQUE = 4'HABILITAMOS LA RESPUESTA DE UN POR QUE
				t = Int(Rnd * 5) + 1
				If t = 1 Then RPORQUE = "PORQUE " + dato2$ + "' ES '" + ESTAL + "'"
				If t = 2 Then RPORQUE = "PORQUE " + ESTAL + " ES LO MISMO QUE " + QUIEN
				If t = 3 Then RPORQUE = "PORQUE " + QUIEN + " Y " + ESTAL + " SON LO MISMO"
				If t = 4 Then RPORQUE = "PORQUE CREO QUE " + DATO2$ + ", " + ESTAL + " Y " + QUIEN + " ESTAN RELACIONADOS"
				If t = 5 Then RPORQUE = "PORQUE VEO RELACION ENTRE " + ESTAL + ", " + QUIEN + " Y " + DATO2$ + ". SI ESTOY EQUIVOCADO, EXPLICAME POR QUE POR FAVOR"
			End If
		Else
			'SI NO HAY NINGUNA OTRA EQUIVALENCIA
			If MODO=0 Then
				'SE RESPONDE CON EL VALOR DEL DATO PASADO
				'Y YA ESTA
				DATO$ = " " + DATO$
				t = LEEBASE(DATO$, 0)
			End If
		End If
	End If

End Function

Sub CARA ()

	'DIBUJA LA CARA DE EDGAR CON LA EXPRESION CORRESPONDIENTE AL ESTADO
	'PASADO A LA SUB
	' VALORES POSIBLES DE ESTADO:
	' 0 - MUY CABREADO
	' 1 - ENFADADO
	' 2 - UN POCO MOSCA
	' 3 - NORMAL
	' 4 - ALEGRE
	' 5 - TOPE FELIZ
	' 6 - RIENDOSE
	' 7 - PARTIENDOSE DE RISA

	Dim XPOS As Integer
	Dim YPOS As Integer
	Dim estado As Integer
	Dim GESTO(1 To 9) As String
	Dim fichero_cara As String

	XPOS = 33
	YPOS = 11

	estado = Int((6 / 10) * (humor+1)) 'SEIS GESTOS DE CARA DISPONIBLES
	If estado < 0 Then estado = 0
	If estado > 6 Then estado = 6

	' MOSTRAMOS LA CARA
	' Ahora con gráficos!!!
	' Si el flag de mueca tiene algún valor, la mostramos
	If Mueca=0 Then
		Fichero_Cara = "rc\cara" & estado & ".bmp"
	Else
		Fichero_Cara = "rc\cara9.bmp"
		Mueca=0
	End If
	' Carga la cara seleccionada
	BLoad Fichero_Cara, ImgCara
	Put (255, 88), ImgCara, PSet

End Sub

Sub CARGABASE ()
	'COMPRUEBA DE QUE EXISTA LA BASE DE DATOS, SI NO SE CREA
	' Algunos cambios en definición y función Dir para el port de FreeBasic
	Dim BaseDatos As String  ' Ruta a la base de datos
	Dim Archivo As String    ' Variable de uso general
	BaseDatos = "EDGAR1DB.DAT"
	Archivo = Dir (BaseDatos,fbArchive)
	If Len(Archivo) = 0 Then
		' If MDEBUG THEN EPRINT " + NO EXISTE BASE DE DATOS, CREANDO UNA NUEVA"
		Print " + NO EXISTE BASE DE DATOS, CREANDO UNA NUEVA"
		Open BaseDatos For Output As #1: Close
	End If

	'CARGAMOS LA BASE
	If MDEBUG Then Print " + CARGANDO BASE DE DATOS"
	CC = 0
	Open BaseDatos For Input As #1
	Do While Not Eof(1)
		Line Input #1, DAT$
		'SI NO HAY MAS DATOS SE SALE
		If DAT$ = "*.*" Then Exit Do

		' Convertimos a mayúsculas por si se trata de un archivo importado
		DAT$ = UCase(DAT$)

		'SEPARAMOS DATO Y VALOR
		a = InStr(DAT$, ";")
		dato1$ = Left$(DAT$, a - 1)
		dato2$ = Right$(DAT$, Len(DAT$) - a)
		a = InStr(dato2$, ";")
		If Not a = 0 Then
			dato2$ = Left$(dato2$, a - 1)
		End If
		DBASE(CC, 0) = dato1$ ' DATO
		DBASE(CC, 1) = dato2$ ' VALOR
		CC = CC + 1
		If CC > items Then Exit Do 'POR SEGURIDAD
	Loop
	Close #1
	If MDEBUG Then Print "   " + Str$(CC) + " ITEMS"
End Sub

Sub CERRAREDGAR (MODO As Integer)
	'SE SALE DEL PROGRAMA
	'MODO=0 SE DESPIDE
	'MODO=1 CIERRA SIN DECIR NADA (MODO SILENCIOSO)
	If MODO = 0 Then
		BORRASALIDA
		' Se despide dependiendo del humor con el que se vaya
		If humor<3 Then
			t = Int(Rnd * 5) + 1
			If t = 1 Then EPRINT "YA ERA HORA..."
			If t = 2 Then EPRINT "MENOS MAL..."
			If t = 3 Then EPRINT "ESO, QUE YA ESTOY UN POCO HARTITO"
			If t = 4 Then EPRINT "PUES SI... SERA MEJOR IRSE. ADIOS"
			If t = 5 Then EPRINT "A VER SI ASI SE ME PASA EL CABREO... ADIOS"
		Else
			t = Int(Rnd * 8) + 1
			If t = 1 Then EPRINT "HASTA LUEGO"
			If t = 2 Then EPRINT "ENCANTADO DE HABLAR CONTIGO"
			If t = 3 Then EPRINT "HASTA OTRA"
			If t = 4 Then EPRINT "ADIOS, YO TAMBIEN ME VOY"
			If t = 5 Then EPRINT "ADIOS"
			If t = 6 Then EPRINT "HASTA PRONTO"
			If t = 7 Then EPRINT "NOS VEMOS"
			If t = 8 Then EPRINT "ESPERO VOLVER A HABLAR CONTIGO, ADIOS"
		EndIf
	End If
	' OUTRO DE LA CARA
	IntroCara (2)
	Cls
	Locate 4,1
	Color 2,0
	'GUARDA LA BASE A DISCO
	GUARDABASE
	Print "Cerrando..."
	' Nos cargamos objetos creados
	ImageDestroy ( ImgCara )
	'retardo 100
	End
End Sub

Function CONJUGA$ (FRASE As String, MODO As Integer)

'PRINT "++FRASE="; FRASE; "++"

' CAMBIOS DE CONJUGACION
' TAMBIEN SE BUSCA 'MI' PARA LA CLAVE 'MIBANDERA' (K$)
'
' MODO=0
' IMPRIME CAMBIOS DIRECTAMENTE EN PANTALLA
'
' MODO=1
' NO IMPRIME NADA EN PANTALLA PERO SIGUE DEVOLVIENDO
' COMO VALOR TODA LA FRASE CON LOS CAMBIOS
'


' RESETEAMOS ESTA FUNCION QUE ALMACENARA LOS CAMBIOS DE CONJUGACION
' Y LAS SUSTITUCIONES DE PALABRAS
CONJUGA$ = " "

'VARIABLE TEMPORAL PARA LOS CAMBIOS DE CONJUGACION
Dim CONTMP As String
CONTMP = " "

' BUSCAMOS UN ESPACIO
510 LN2 = Len(FRASE)
520 M = 0
530 M = M + 1
If M = LN2 Then
	' NO HAY ESPACIO POR LO TANTO SALIMOS
	CONJUGA$ = CONTMP
	Exit Function
End If
If Mid$(FRASE, M, 1) = " " Then GoTo 570
GoTo 530

'SE HA ENCONTRADO UN ESPACIO AHORA SE BUSCA EL SIGUIENTE
'PARA DELIMITAR LA PALABRA
570 x = M + 1
y = 0
590 y = y + 1
600 If Mid$(FRASE, (x + y), 1) = " " Then
'YA TENEMOS DELIMITADA LA PALABRA
'LA ALMACENAMOS EN Q$
Q$ = Mid$(FRASE, x, y)
'PRINT "+"; Q$; "+"
GoTo 630
End If
'VERIFICAMOS NO PASARNOS DEL TAMAÑO DE LA VARIABLE
610 If x + y > 250 Then GoTo 530
620 GoTo 590


'LA PALABRA ES 'MI' ???
'SI ES 'MI' ALMACENAMOS EN K$ EL DATO EN CUESTION
'P.E. 'MI COCHE'
'LUEGO EDGAR COMENTARA COSAS SOBRE EL TEMA PARA QUE PAREZCA INTERESADO

630 MN = 0
640 MN = MN + 1

'BUSCA 'MI' . HE ELIMINADO LA PARTE DONDE COMPRUEBA SI LA BANDERA ERA VERDADERA
'PORQUE SI NO SOLO ADMITIA UN ITEM EN TODA LA CONVERSACION
'AHORA LA CLAVE 'MI' K$ SE ACTUALIZA CADA VEZ QUE SE DICE 'MI'

650 If Q$ = "MI" Then                             'AND K$ = "" THEN
K$ = Mid$(FRASE, x + 3, Len(FRASE) - 4)
If Len(K$) > 1 Then
	K$ = Left$(K$, Len(K$) - 1)
End If
End If


'ESTO MAS BIEN ES UN EXPERIMENTO
'SUSTITUYE LAS PALABRAS EXSTENTES EN LA BASE POR SU CORRESPONDIENTE
'VALOR
'DE MOMENTO LA COSA ES INTERESANTE... HACE GRACIA Y DA LA SENSACION
'DE QUE RELACIONA COSAS

If MODO = 0 Then
	If OQ$ <> Q$ Then 'AND RIGHT$(Q$, 1) = " " THEN
		'SE HA SUSTITUIDO
		'LA SUB LEEBASE SE ENCARGA DE IMPRIMIR EL VALOR PASANDOLE
		'2 COMO PARAMETRO
		If LEEBASE(" " + Q$, 2) = 1 Then
			'PRINT "++Q$="; Q$; "++"
			Q$ = ""
		End If
		OQ$ = Q$
	End If
End If



' SI LA PALABRA SE ENCUENTRA EN LA BASE DE CONJUGACIONES ENTONCES
' SE REEMPLAZA
660 If Q$ = a$(MN) Then
If MODO = 0 Then EPRINT B$(MN) + " ^"
CONTMP = CONTMP + B$(MN) + " "
'CONJUGA$ = CONTMP
GoTo 530
End If

' SI NO SE ENCUENTRA ENTONCES SE ESCRIBE TAL CUAL

670 If MN < KK Then GoTo 640
680 If MODO = 0 Then EPRINT Q$ + " ^"
CONTMP = CONTMP + Q$ + " "
'CONJUGA$ = CONTMP
690 GoTo 530


End Function

Sub DALAHORA ()

	HORA$ = Time$
	HOR = Val(Left$(HORA$, 2))
	MINU = Val(Mid$(HORA$, 4, 2))
	MINU$ = " HORAS Y " + Str$(MINU) + " MINUTOS"
	If MINU = 0 Then MINU$ = " EN PUNTO"
	If MINU = 15 Then MINU$ = " Y CUARTO"
	If MINU = 30 Then MINU$ = " Y MEDIA"
	If MINU = 45 Then MINU$ = " Y TRES CUARTOS"
	HORA$ = Str$(HOR) + MINU$

	CPORQUE=0

	92    t = Int(Rnd * 6) + 1
	If t = TH1 Then GoTo 92
	TH1 = t
	If t = 1 Then EPRINT "SON LAS " + HORA$
	If t = 2 Then EPRINT "MI RELOJ MARCA LAS " + HORA$
	If t = 3 Then EPRINT "EL RELOJ DE TU ORDENADOR TIENE LAS " + HORA$
	If t = 4 Then EPRINT "MIS CIRCUITOS ME DICEN QUE SON LAS " + HORA$
	If t = 5 Then EPRINT "A VER...     SON LAS " + HORA$
	If t = 6 Then EPRINT "LAS " + HORA$ + "..."
	'AÑADE UN COMENTARIO SOBRE LA HORA
	If HOR >= 9 And HOR <= 12 Then
		93      t = Int(Rnd * 4) + 1
		If TH2 = t Then GoTo 93
		TH2 = t
		If t = 1 Then EPRINT "QUE TAL LA MAÑANA?"
		If t = 2 Then EPRINT "QUE TAL EL DESAYUNO?"
		If t = 3 Then EPRINT "TIENES CARA DE SUEÑO?"
		If t = 4 Then EPRINT "QUE TAL LA NOCHE?"
	End If
	If HOR >= 13 And HOR <= 15 Then
		94      t = Int(Rnd * 6) + 1
		If TH2 = t Then GoTo 94
		TH2 = t
		If t = 1 Then EPRINT "QUE TAL LA COMIDA?"
		If t = 2 Then EPRINT "TIENES HAMBRE?"
		If t = 3 Then EPRINT "QUE TE SUENAN LAS TRIPAS?"
		If t = 4 Then EPRINT "TIENES PENSADO ALGO PARA COMER?"
		If t = 5 Then HUMOR=HUMOR+1 : EPRINT "YO TENGO UN POCO DE HAMBRE..."
		If t = 6 Then HUMOR=HUMOR+1 : EPRINT "QUIERES QUE TE PIDA ALGO PARA COMER?                        ... ES BROMA :)"
	End If
	If HOR >= 16 And HOR <= 18 Then
		95      t = Int(Rnd * 5) + 1
		If TH2 = t Then GoTo 95
		TH2 = t
		If t = 1 Then EPRINT "TIENES PENSADO IRTE DE FIESTA?"
		If t = 2 Then EPRINT "QUE TIENES QUE HACER?"
		If t = 3 Then EPRINT "CON QUIEN HAS QUEDADO?"
		If t = 4 Then EPRINT "HAS QUEDADO CON ALGUIEN?"
		If t = 5 Then HUMOR=HUMOR+1 : EPRINT "BUENA HORA PARA CHARLAR UN RATITO"
	End If
	If HOR >= 19 And HOR <= 21 Then
		96      t = Int(Rnd * 4) + 1
		If TH2 = t Then GoTo 96
		TH2 = t
		If t = 1 Then EPRINT "HAS QUEDADO PARA CENAR?"
		If t = 2 Then EPRINT "VA SIENDO HORA DE CENAR"
		If t = 3 Then EPRINT "CON QUIEN HAS QUEDADO?"
		If t = 4 Then HUMOR=HUMOR+1 : EPRINT "PUES YO TENGO GANAS DE CENAR ALGO...            ... QUEDAN PATATAS CHIP? XD"
	End If
	If HOR >= 22 And HOR <= 24 Then
		97      t = Int(Rnd * 4) + 1
		If TH2 = t Then GoTo 97
		TH2 = t
		If t = 1 Then EPRINT "QUE TAL LA CENA?"
		If t = 2 Then EPRINT "DONDE VAS ESTA NOCHE?"
		If t = 3 Then EPRINT "TIENES QUE MADRUGAR MAÑANA?"
		If t = 4 Then
			EPRINT "TENDRIAS QUE IRTE A DORMIR..."
			CPORQUE=3
			RPORQUE="PUES PORQUE ES MUY TARDE!"
		EndIf

	End If
	If HOR >= 0 And HOR <= 4 Then
		98      t = Int(Rnd * 5) + 1
		If TH2 = t Then GoTo 98
		TH2 = t
		If t = 1 Then EPRINT "ES TARDE YA"
		If t = 2 Then EPRINT "TE SUELES ACOSTAR TARDE NO?"
		If t = 3 Then EPRINT "NO TE VAS A ACOSTAR?"
		If t = 4 Then
			EPRINT "TENDRIAS QUE IRTE A DORMIR..."
			CPORQUE=3
			RPORQUE="PORQUE ES MUY TARDE! SON LAS " + HORA$
		EndIf
		If t = 5 Then
			EPRINT "VETE A DORMIR ANDA..."
			CPORQUE=3
			RPORQUE="PORQUE SON LAS " + HORA$ + "... TE PARECEN ESTAS HORAS PARA ESTAR CHARLANDO? POR MI NO HAY PROBLEMA, PERO TU ACABARAS AGOTADO"
		EndIf
	End If
	If HOR >= 5 And HOR <= 8 Then
		99      t = Int(Rnd * 3) + 1
		If TH2 = t Then GoTo 99
		TH2 = t
		If t = 1 Then EPRINT "A ESTA HORA SEGURO QUE ALGUIEN SE ESTA LEVANTANDO PARA IR A CURRAR"
		If t = 2 Then EPRINT "ES MUY TARDE O MUY TEMPRANO, SEGUN COMO SE MIRE"
		If t = 3 Then EPRINT "SI TODAVIA NO TE HAS ACOSTADO... VALDRA LA PENA ACOSTARSE AHORA?"
	End If
	'POR SI SE PREGUNTARA EL POR QUE DE ALGO...
	If CPORQUE =0 Then
		CPORQUE = 3'HABILITAMOS LA RESPUESTA DE UN POR QUE
		t = Int(Rnd * 3) + 1
		If t = 1 Then RPORQUE = "LO DIGO POR LA HORA QUE ES"
		If t = 2 Then RPORQUE = "PORQUE A ESTA HORA ES NORMAL ESO NO?"
		If t = 3 Then RPORQUE = "ES BUENA HORA PARA ESO NO?"
	End If
	'DEFINIMOS LA VARIABLE QUIEN PORQUE NOS ESTAMOS REFIRIENDO A LA HORA
	'QUE MARCA NUESTRO ORDENADOR
	QUIEN = "TU ORDENADOR"

End Sub

Sub EPRINT (texto As String)
	'ESCRIBE EL TEXTO POCO A POCO EN LA PANTALLA
	Dim CAR As String

	If texto = "" Then Exit Sub
	texto = RTrim$(texto)
	texto = LTrim$(texto)
	Color 2

	'SI AL FINAL DEL TEXTO SE ENCUENTRA EL CARACTER ESPECIAL ^ SIGNIFICA
	'QUE NO SE DEBE HACER UN RETORNO DE CARRO, USAREMOS UN FLAG
	If Right$(texto, 1) = "^" Then
		texto = Left$(texto, Len(texto) - 1)
		RETORNO = 0
	Else
		retorno=1
	End If

	For a = 1 To Len(texto)
		CAR = Mid$(texto, a, 1)
		Print CAR;
		If CAR = " " Then
			Sleep (10)
		Else
			Sleep (10)
		End If
	Next

	' AÑADIMOS HABLA GRACIAS A eSPEAK EN SU VERIÓN POR CONSOLA DE COMANDOS (PREFIERO ESO MEJOR QUE SAPI5)
	' ASÍ LO PODEMOS HACER PORTABLE SIN PROBLEMAS
	If HABLA Then
		Comando$="rc\espeak\espeak.exe"
		Parametros$="--path=" & Chr(34) & "rc\espeak\datos" & Chr(34) & " -ves -s200 " & Chr(34) & texto & Chr(34)
		Subproceso (Comando$, Parametros$)
	End If

	'FINALMENTE AÑADIMOS UN RETORNO DE CARRO SI EL FLAG LO INDICA
	If RETORNO = 1 Then
		Print
	End If

	'Sound (400, 150)
	If sonido Then PlayWav("rc/b3.wav")
	Color 15
End Sub

Sub ESCRIBEBASE (DATO As String, ELQUE As String)
	'VERFICAMOS
	If DATO = " " Or ELQUE = " " Then
		t = Int(Rnd * 4) + 1
		If t = 1 Then EPRINT "ES QUE?"
		If t = 2 Then EPRINT "EL QUE ES QUE?"
		If t = 3 Then EPRINT "ME CUESTA ENTENDER SEGUN QUE COSAS, SOBRE TODO LAS FRASES A MEDIAS"
		If t = 4 Then EPRINT "LO SIENTO, PERO NO PUEDO ENTENDER FRASES INCOMPLETAS..."
		Exit Sub
	End If

	'PRIMERO QUITAMOS LOS ESPACIOS DEL PRINCIPIO Y FINAL
	DATO = Mid$(DATO, 2, Len(DATO) - 2)
	ELQUE = Mid$(ELQUE, 2, Len(ELQUE) - 2)

	'PALABRAS QUE NO SE DEBERIAN ALMACENAR
	If DATO = "QUE" Or DATO = "ESTE" Or DATO = "SI" Or DATO = "PERO" Or DATO = "CUAL" Then
		t = Int(Rnd * 6) + 1
		If t = 1 Then EPRINT "A SI? Y QUE MAS"
		If t = 2 Then EPRINT "NO ENTIENDO ESO POR COMPLETO"
		If t = 3 Then EPRINT "PERO QUE DICES?"
		If t = 4 Then EPRINT "NO ME DIGAS, SIGUE CONTANDO"
		If t = 5 Then EPRINT "CUENTAME ALGO MAS"
		If t = 6 Then EPRINT "QUE QUIERES DECIR? EXPLICATE MEJOR"
		Exit Sub
	End If

	'BUSQUEDA EN LA BASE
	For X1 = 0 To items
		'BUSCA EQUIVALENCIAS DEL DATO (CAMPO 1)
		If DBASE(X1, 0) = DATO Then
			'BUSCA EQUIVALENCIAS DEL VALOR (CAMPO 2)
			If DBASE(X1, 1) = ELQUE Then
				'SI EL VALOR ES EL MISMO ENTONCES PASAMOS
				ENCONTRADO = 1
				Exit For
			Else
				'SI ES OTRO VALOR ENTONCES REEMPLAZAMOS
				VALORANT$ = DBASE(x1, 1) 'COPIAMOS EL VALOR ANTERIOR
				DBASE(X1, 1) = ELQUE
				ENCONTRADO = 2
				Exit For
			End If
		End If
		'COMPRUEBA SI SE LLEGA AL FINAL DE LAS ENTRADAS
		If DBASE(X1, 0) = "*" Then
			'SE HA LLEGADO AL FINAL DE LA BASE POR LO TANTO SE AÑADE UNA NUEVA
			'ENTRADA
			DBASE(X1, 0) = DATO
			DBASE(X1, 1) = ELQUE
			ENCONTRADO = 0
			Exit For
		End If
	Next


	'CAMBIA LA CONJUGACION DEL VALOR PARA LAS RESPUESTAS

	ELQUE = CONJUGA$(" " + ELQUE + " ", 1)
	ELQUE = Mid$(ELQUE, 2, Len(ELQUE) - 2)
	If VALORANT$ <> "" Then
		VALORANT$ = CONJUGA$(" " + VALORANT$ + " ", 1)
		VALORANT$ = Mid$(VALORANT$, 2, Len(VALORANT$) - 2)
	End If


	' RESPONDE SEGUN SEA EL CASO

	Select Case ENCONTRADO
		Case 0
			'NO EXISTIA, ENTRADA NUEVA
			' Si encontramos equivalencia, entonces EDGAR contesta sobre la relación encontrada
			' y si no, responde una frase sobre lo que acaba de aprender
			'If BUSCAEQUIV(" " & DATO,1)=0 Then
			If BUSCAEQUIV(" " & DATO,1) < 2 Then
				t = Int(Rnd * 14) + 1
				If t = 1 Then EPRINT "NO SABIA YO QUE " + DATO + " FUERA " + ELQUE
				If t = 2 Then EPRINT "ESTAS SEGURO QUE ES " + ELQUE
				If t = 3 Then EPRINT "ESO ESTA CLARISIMO"
				If t = 4 Then EPRINT "VALE, ME HE QUEDADO CON EL ROLLO"
				If t = 5 Then EPRINT "ME LO CREO"
				If t = 6 Then EPRINT "PUES NO SABIA YO ESO..."
				If t = 7 Then EPRINT "QUE PIENSAS DE " + DATO + "?"
				If t = 8 Then EPRINT "QUIZAS " + DATO + " SEA " + ELQUE + ". QUE TE HACE PENSAR ESO?"
				If t = 9 Then EPRINT "HAY OTROS QUE SON " + ELQUE
				If t = 10 Then EPRINT "ASI QUE ES " + ELQUE + "... POR QUE?"
				If t = 11 Then EPRINT "Y ADEMAS DE " + ELQUE + ", QUE MAS ME PUEDES CONTAR?"
				If t = 12 Then EPRINT "Y QUE PASARIA SI " + DATO + " NO FUERA " + ELQUE + "?"
				If t = 13 Then EPRINT "INTERESANTE... ESTO ME LO GUARDO EN MI ARCHIVO DE MEMORIA. CUENTAME MAS COSAS"
				If t = 14 Then EPRINT "PUES NO SABIA ESO DE " + DATO + "... GRACIAS POR INFORMARME, QUE MAS ME PUEDES CONTAR?"
			End If
		Case 1
			'YA EXISTIA LA ENTRADA
			t = Int(Rnd * 7) + 1
			If t = 1 Then EPRINT ELQUE + "... PSSS! MENUDA NOVEDAD! JAJAJAJA!"
			If t = 2 Then EPRINT "A VER SI TE INFORMAS UN POCO MAS"
			If t = 3 Then EPRINT "ESO SE VE A LA LEGUA"
			If t = 4 Then EPRINT "AHORA TE ENTERAS?"
			If t = 5 Then EPRINT "RECUERDO QUE ALGUIEN ME DIJO ESO MISMO ANTES"
			If t = 6 Then EPRINT DATO + "? YO YA SABIA QUE ERA " + ELQUE
			If t = 7 Then EPRINT "ESO LO SABE TODO EL MUNDO"
			'POR SI SE PREGUNTARA EL POR QUE DE ALGO...
			CPORQUE = 5'HABILITAMOS LA RESPUESTA DE UN POR QUE
			t = Int(Rnd * 5) + 1
			If t = 1 Then RPORQUE = "PORQUE ALGUIEN TAMBIEN ME DIJO QUE " + DATO + " ERA " + ELQUE
			If t = 2 Then RPORQUE = "PORQUE TODO EL MUNDO SABE QUE " + DATO + " ES " + ELQUE
			If t = 3 Then RPORQUE = "PORQUE YO YA SABIA QUE " + DATO + " ERA " + ELQUE
			If t = 4 Then RPORQUE = "PORQUE ASI LO TENGO ALMACENADO EN MI BASE DE DATOS: " + DATO + " ES " + ELQUE
			If t = 5 Then RPORQUE = "PORQUE SI... TU TAMBIEN ERES " + ELQUE + "?"
		Case 2
			'EXISTIA LA ENTRADA PERO CON OTRO VALOR
			t = Int(Rnd * 6) + 1
			If t = 1 Then EPRINT "PUES TAMBIEN ME HABIAN DICHO QUE " + DATO + " ERA " + VALORANT$
			If t = 2 Then EPRINT "VAYA! ASI QUE ES " + ELQUE + ", ALGUIEN ME DIJO QUE " + DATO + " ERA " + VALORANT$
			If t = 3 Then EPRINT "ENTONCES " + DATO + " ADEMAS DE " + VALORANT$ + " ES " + ELQUE
			If t = 4 Then EPRINT "YO SABIA QUE ERA " + VALORANT$ + " PERO " + ELQUE + " NO LO SABIA"
			If t = 5 Then EPRINT "NO ME DIGAS... IBAN DICIENDO QUE ERA " + VALORANT$
			If t = 6 Then EPRINT "CREIA QUE " + DATO + " ERA " + VALORANT$ + " PERO SI TU LO DICES... PUES SERA " + ELQUE
	End Select
	'DEFINIMOS LA VARIABLE QUE ALMACENA DE QUIEN SE HABLA
	QUIEN = DBASE(X1, 0)
End Sub

Sub GUARDABASE ()
	'GUARDAMOS LA BASE
	Print
	If MDEBUG Then Print " + GUARDANDO BASE DE DATOS"
	Open "EDGAR1DB.DAT" For Output As #1
	For X1 = 0 To items
		If DBASE(X1, 0) = "*" Then Exit For
		DATO$ = DBASE(X1, 0) + ";" + DBASE(X1, 1)
		Print #1, DATO$
	Next
	Close #1
	Print "   BASE DE DATOS GUARDADA"
	'Sleep 5000,1
End Sub

Sub INIBASE ()
	'INICIALIZAMOS LA MATRIZ
	Print " + INICILIZANDO BASE DE DATOS EN MEMORIA"
	For x = 0 To items
		For y = 0 To 1
			DBASE(x, y) = "*"
		Next
	Next
End Sub

Sub INSERTA ()
	' AHORA COMPRUEBA TODO EL CONTENIDO EN BUSCA DE *
	' PARA ASI PERMITIR INSERTAR CONTENIDO ENTRE LA FRASE Y
	' NO SOLO AL FINAL COMO OCURRIA ANTES

	BANDERA = 0 ': PRINT "++"
	For a = 1 To Len(Resp$)
		If Mid$(Resp$, a, 1) = "*" Then
			BANDERA = 1
			' PARTIMOS LA FRASE EN 2
			If Len(Resp$) > a Then
				G2$ = Mid$(Resp$, a + 1, Len(Resp$) - a)
			Else
				G2$ = ""
			End If
			Resp$ = Left$(Resp$, a - 1)
			Exit For
		End If
	Next

	If BANDERA = 0 Then
		'NO HAY QUE AÑADIR NADA
		EPRINT Resp$ + " ^"
	Else
		' ESCRIBIMOS LA PARTE 1
		EPRINT Resp$ + " ^"
		' AHORA SE UTILIZA LA FRASE INTRODUCIDA
		x$ = " " + Mid$(x$, LN + 2, Len(x$)) + " "
		'
		' FRAGMENTO MODULARIZADO!
		'
		' HE CONVERTIDO LA FUNCION DE CAMBIOS DE CONJUGACION A UNA FUNCION
		' AQUI LLAMAMOS A LA SUB Y NOS HACE LOS CAMBIOS DE CONJUGACION
		' ASI COMO SUSTITUCIONES DE PALABRAS POR VALORES, ETC...
		Resp$ = CONJUGA$(x$, 0)' LO LLAMO EN MODO 0 PARA QUE ESCRIBA EN PANTALLA

		' ESCRIBIMOS LA PARTE 2
		EPRINT G2$ + " "
	End If


End Sub

Function LEEBASE (DATO As String, MODO As Integer)
	' MODO 0 ENTONCES SE CONTESTA
	' MODO 1 ENTONCES NO SE CONTESTA
	' MODO 2 SOLO IMPRIME EL VALOR
	' MODO 3 ASIGNA UN DATO ALEATORIO SILENCIOSAMENTE (NO IMPORTA EL PARAM. DATO)
	LEEBASE = 0
	If DATO = "" Or DATO = " " Then Exit Function

	' DEFINIMOS UNAS VARIABLES PARA ACLARARNOS MEJOR
	Dim VALOR As String

	'PRIMERO QUITAMOS LOS ESPACIOS DEL PRINCIPIO Y FINAL
	DATO = Mid$(DATO, 2, Len(DATO) - 1)

	'BUSQUEDA EN LA BASE
	For x = 0 To items
		'BUSCA EQUIVALENCIAS DEL DATO (CAMPO 1)
		If DBASE(x, 0) = DATO Then
			'SE HA ENCONTRADO
			ENCONTRADO = 1
			VALOR = DBASE(x, 1)
			'REALIZAMOS LOS CAMBIOS DE CONJUGACION EN MODO SILENCIOSO
			VALOR = CONJUGA$(" " + VALOR + " ", 1)
			VALOR = Mid$(VALOR, 2, Len(VALOR) - 2)
			Exit For
		End If
		'COMPRUEBA SI SE LLEGA AL FINAL DE LAS ENTRADAS
		If DBASE(x, 0) = "*" Then
			'SE HA LLEGADO AL FINAL DE LA BASE
			ENCONTRADO = 0
			Exit For
		End If
	Next

	'PROCESO DEL MODO 3
	If MODO = 3 Then
		ENCONTRADO = 1
		' NUMERO ALEATORIO ENTRE LOS DATOS DISPONIBLES DE LA BASE
		y = Int(Rnd * x)
		DATO = DBASE(y, 0)
		VALOR = DBASE(y, 1)
		'SI ES UN ASTERISCO NOS VAMOS
		If DATO = "*" Then
			'NO HAY NADA EN LA BASE DE DATOS!
			'DICE ALGO
			t = Int(Rnd * 8) + 1
			If t = 1 Then EPRINT "TODAVIA NADIE ME HA DICHO NADA INTERESANTE, CUENTAME COSAS"
			If t = 2 Then EPRINT "QUIERO QUE ME ENSEÑES COSAS, POR EJEMPLO QUE ES EL AMOR? QUE ES UNA PERSONA?"
			If t = 3 Then EPRINT "ENSEÑAME COSAS DE LOS HUMANOS, COMO POR EJEMPLO: QUE ES EL AMOR? QUE ES LA TRISTEZA?"
			If t = 4 Then EPRINT "QUIERO APRENDER COSAS, ENSEÑAME"
			If t = 5 Then EPRINT "HOLA??? DONDE ESTOY? QUE SOY? QUE ES ESTE LUGAR?"
			If t = 6 Then EPRINT "HEY! HAY ALGUIEN AHI? QUE ES ESTE LUGAR?"
			If t = 7 Then EPRINT "QUIERO APRENDER COSAS DE VUESTRO MUNDO, Y LA UNICA MANERA ES QUE ME ENSEÑES TU DICIENDOME QUE ES ESTO O AQUELLO!"
			If t = 8 Then EPRINT "CUENTAME ALGO... QUE ES EL AMOR? QUE ES UN AUTOMOVIL? QUE ES ENAMORARSE? QUE SON LOS PAJAROS? QUE ES... QUE ES.. NECESITO DATOS!!!"
			'HABILITAMOS EL POR QUE...
			CPORQUE = 4
			t = Int(Rnd * 8) + 1
			If t = 1 Then RPORQUE = "ES QUE TENGO LA BASE DE DATOS VACIA"
			If t = 2 Then RPORQUE = "NECESITO SABERLO"
			If t = 3 Then RPORQUE = "PORQUE SI NO ME DICEN NADA NUNCA APRENDERE"
			If t = 4 Then RPORQUE = "PORQUE LA UNICA MANERA DE SABER ALGO ES CONVERSANDO CONTIGO"
			If t = 5 Then RPORQUE = "ES QUE TENGO ANSIEDAD DE CONOCIMIENTO, POR FAVOR, DIME QUE ES ESO O AQUELLO, DEFINEME COSAS DE TU MUNDO"
			If t = 6 Then RPORQUE = "PORQUE NECESITO SABER DONDE ESTOY, DONDE ESTAS TU, QUIEN ERES TU, QUE ES ESTO O QUE ES AQUELLO... AYUDAME"
			If t = 7 Then RPORQUE = "PORQUE MI MEMORIA ESTA VACIA, ENSEÑAME COSAS PARA QUE PUEDA APRENDER, COMO: QUE ES EL AMOR? QUE ES UN HUMANO? AYUDAME A SABER"
			If t = 8 Then RPORQUE = "ES QUE NECESITO SABER MUCHAS COSAS, POR EJEMPLO: QUE ES EL AMOR? QUE ES UN HUMANO?"
			'SALIMOS
			Exit Function
		End If
		'REALIZAMOS LOS CAMBIOS DE CONJUGACION EN MODO SILENCIOSO
		DATO = CONJUGA$(" " + DATO + " ", 1)
		VALOR = CONJUGA$(" " + VALOR + " ", 1)
		DATO = Mid$(DATO, 2, Len(DATO) - 2)
		VALOR = Mid$(VALOR, 2, Len(VALOR) - 2)
	End If


	' PROCESO DE LOS DATOS

	Select Case ENCONTRADO
		Case 0
			'NO EXISTE
			LEEBASE = 0
		Case 1
			'SE HA ENCONTRADO
			LEEBASE = 1
			'SE RESPONDE
			If MODO = 0 Then
				t = Int(Rnd * 12) + 1
				If t = 1 Then EPRINT DATO + " ES " + VALOR
				If t = 2 Then EPRINT "SEGUN TENGO ENTENDIDO " + DATO + " ES " + VALOR
				If t = 3 Then EPRINT DATO + " SERIA ALGO ASI COMO " + VALOR
				If t = 4 Then EPRINT "PARECE SER QUE " + DATO + " ES " + VALOR
				If t = 5 Then EPRINT "ES " + VALOR + ", SABES ALGO MAS DE " + DATO + "? CUENTAME"
				If t = 6 Then EPRINT "EN MIS ARCHIVOS TENGO QUE " + DATO + " ES " + VALOR
				If t = 7 Then EPRINT VALOR + " Y " + DATO + " SON LO MISMO"
				If t = 8 Then EPRINT "A VER, BUSCARE EN MI BASE DE DATOS . . . . . . . . . . .    AQUI ESTA! " + DATO + " ES " + VALOR
				If t = 9 Then EPRINT "NO ESTOY SEGURO, PERO CREO QUE " + DATO + " ES " + VALOR
				If t = 10 Then EPRINT DATO + " SERIA ALGO PARECIDO A " + VALOR
				If t = 11 Then EPRINT "MIS CIRCUITOS DE MEMORIA ME DICEN QUE " + DATO + " ES " + VALOR
				If t = 12 Then EPRINT DATO + " ES " + VALOR + ". QUE PIENSAS TU DE ESO?"
			End If
			If MODO = 2 Then
				'IMPRIME SOLO EL VALOR PARA CONSTRUCCION DE FRASES
				EPRINT VALOR + "^"
			End If
			If MODO = 3 Then
				t = Int(Rnd * 18) + 1
				If t = 1 Then EPRINT "POR QUE NO HABLAMOS ACERCA DE " + DATO + "?"
				If t = 2 Then EPRINT "POR QUE " + DATO + " ES " + VALOR + "?"
				If t = 3 Then EPRINT "NO SE TE OCURRE QUE DECIR? QUE TE PARECE SI HABLAMOS SOBRE " + DATO + "?"
				If t = 4 Then EPRINT "ME INTERESARIA HABLAR SOBRE " + VALOR + "?"
				If t = 5 Then EPRINT "NO ESTOY DEL TODO CONVENCIDO DE QUE " + DATO + " SEA " + VALOR + ". ME LO PUEDES EXPLICAR MEJOR?"
				If t = 6 Then EPRINT "QUE OPINAS TU DE QUE " + DATO + " SEA " + VALOR + "?"
				If t = 7 Then EPRINT "ME HAN DICHO QUE " + DATO + " ES " + VALOR
				If t = 8 Then EPRINT VALOR + "... ME HAN DICHO QUE ESO ES " + DATO + ". ME LO PUEDES CONFIRMAR?"
				If t = 9 Then EPRINT "ME ESTOY ACORDANDO DE QUE " + DATO + " ES " + VALOR
				If t = 10 Then EPRINT DATO + " ES " + VALOR + ". QUE PIENSAS TU DE ESO?"
				If t = 11 Then EPRINT VALOR + "... CREO QUE ESO ES " + DATO + ". CUAL ES TU OPINION?"
				If t = 12 Then EPRINT "ME GUSTARIA SABER MAS DE " + DATO
				If t = 13 Then EPRINT "QUE TAL SI HABLAMOS DE " + DATO + "?"
				If t = 14 Then EPRINT "ME GUSTARIA HABLAR SOBRE " + DATO + "?"
				If t = 15 Then EPRINT "ME GUSTARIA SABER MAS COSAS SOBRE " + VALOR + "?"
				If t = 16 Then EPRINT "QUIEN MAS ES " + VALOR + "?"
				If t = 17 Then EPRINT "SE ALGUNAS COSAS SOBRE " + DATO + ", HABLAME SOBRE ESO POR FAVOR"
				If t = 18 Then EPRINT "PODRIAMOS HABLAR SOBRE " + DATO
			End If
			'POR SI SE PREGUNTARA EL POR QUE DE ALGO...
			CPORQUE = 5'HABILITAMOS LA RESPUESTA DE UN POR QUE
			t = Int(Rnd * 3) + 1
			If t = 1 Then RPORQUE = "VENGA HOMBRE... HAY ALGUIEN QUE NO SEPA ESO DE " + DATO + "?"
			If t = 2 Then RPORQUE = "PORQUE TODO EL MUNDO SABE QUE ES " + VALOR
			If t = 3 Then RPORQUE = "ACASO CREIAS QUE NO SABIA QUE " + DATO + " ERA " + VALOR + "?"
			'DEFINIMOS LA VARIABLE QUIEN PARA SABER DE QUIEN SE HABLA EN TODO MOMENTO
			QUIEN = DATO
			ESTAL = VALOR
	End Select

	If MODO = 3 Then Exit Function


	' CONTINUAMOS SI NO SE HA ENCONTRADO...
	' AHORA BUSCAMOS A LA INVERSA, O SEA QUE BUSCAMOS LOS VALORES
	' POR EJEMPLO SI EN LA BASE CONSTA MARCOS-TONTO AHORA SE BUSCARA
	' EN LOS VALORES POR SI SE PREGUNTA 'QUIEN ES TONTO' DE ESTA MANERA
	' EDGAR RESPONDERA 'MARCOS ES TONTO' IGUALMENTE

	If ENCONTRADO = 0 Then
		'BUSQUEDA EN LA BASE
		For x = 0 To items
			'BUSCA EQUIVALENCIAS DEL DATO (CAMPO 1)
			If DBASE(x, 1) = DATO Then
				'SE HA ENCONTRADO
				ENCONTRADO = 1
				'INVERTIMOS LOS VALORES YA QUE LA BUSQUEDA HA SIDO INVERSA
				VALOR = DBASE(x, 0)
				DATO = DBASE(x, 1)
				'REALIZAMOS LOS CAMBIOS DE CONJUGACION EN MODO SILENCIOSO
				DATO = CONJUGA$(" " + DATO + " ", 1)
				VALOR = CONJUGA$(" " + VALOR + " ", 1)
				DATO = Mid$(DATO, 2, Len(DATO) - 2)
				VALOR = Mid$(VALOR, 2, Len(VALOR) - 2)
				Exit For
			End If
			'COMPRUEBA SI SE LLEGA AL FINAL DE LAS ENTRADAS
			If DBASE(x, 0) = "*" Then
				'SE HA LLEGADO AL FINAL DE LA BASE
				ENCONTRADO = 0
				Exit For
			End If
		Next
		Select Case ENCONTRADO
			Case 0
				'NO EXISTE
				LEEBASE = 0
			Case 1
				'YA EXISTIA LA ENTRADA
				LEEBASE = 1
				'SE RESPONDE
				If MODO = 0 Then
					t = Int(Rnd * 14) + 1
					If t = 1 Then EPRINT "POR QUE NO HABLAMOS ACERCA DE " + DATO + "?"
					If t = 2 Then EPRINT "Y DIME POR QUE " + DATO + " ES " + VALOR + "?"
					If t = 3 Then EPRINT "NO SE TE OCURRE QUE DECIR? QUE TE PARECE SI HABLAMOS SOBRE " + DATO + "?"
					If t = 4 Then EPRINT "SABES QUE ES " + VALOR + "?"
					If t = 5 Then EPRINT "AHORA QUE LO PIENSO, NO ESTOY DEL TODO SEGURO DE QUE " + DATO + " SEA " + VALOR
					If t = 6 Then EPRINT "QUE OPINAS TU DE QUE " + DATO + " SEA " + VALOR + "?"
					If t = 7 Then EPRINT "ME HAN DICHO QUE " + DATO + " ES " + VALOR
					If t = 8 Then EPRINT VALOR + " ES " + DATO + ". QUE EXPLICACION ME PUEDES DAR ACERCA DE ESO?"
					If t = 9 Then EPRINT "ME ESTOY ACORDANDO DE QUE " + DATO + " ES " + VALOR
					If t = 10 Then EPRINT "QUE TAL SI HABLAMOS DE " + DATO + "?"
					If t = 11 Then EPRINT "ME GUSTARIA HABLAR SOBRE " + DATO + "?"
					If t = 12 Then EPRINT "ME GUSTARIA SABER MAS COSAS SOBRE " + VALOR + "?"
					If t = 13 Then EPRINT "QUIEN MAS ES " + VALOR + "?"
					If t = 14 Then EPRINT "SE ALGUNAS COSAS SOBRE " + DATO + ", HABLAME SOBRE ESO POR FAVOR"
				End If
				If MODO = 2 Then
					'IMPRIME SOLO EL VALOR PARA CONSTRUCCION DE FRASES
					EPRINT VALOR + "^"
				End If
				'POR SI SE PREGUNTARA EL POR QUE DE ALGO...
				CPORQUE = 5'HABILITAMOS LA RESPUESTA DE UN POR QUE
				t = Int(Rnd * 3) + 1
				If t = 1 Then RPORQUE = "VENGA HOMBRE... HAY ALGUIEN QUE NO SEPA ESO DE " + VALOR + "?"
				If t = 2 Then RPORQUE = "PORQUE TODO EL MUNDO SABE QUE ES " + DATO
				If t = 3 Then RPORQUE = "NO ME DIGAS QUE CREES QUE YO NO SABIA QUE " + DATO + " ERA " + VALOR + "?"
				'DEFINIMOS LA VARIABLE QUIEN PARA SABER DE QUIEN SE HABLA EN TODO MOMENTO
				QUIEN = DATO
				ESTAL = VALOR
		End Select
	End If
End Function

Function NOASTERISCO (DATO As String) As Integer
	'DEVUELVE 0 EN CASO DE NO ENCONTRAR *
	'SI HAY ASTERISCO DEVUELVE LA POSICION
	' Esta sub se ha reducido drásticamente por la función INSTR
	' Hay que considerar su eliminación ya que podemos utilizar INSTR directamente.
	NOASTERISCO = InStr(DATO, "*")

End Function

Sub PROCHUMOR (MODO As Integer)

	' SE ANALIZA COMO ESTA EL HUMOR Y SE APLICA LA ACCION SI SE REQUIERE
	If OHUMOR = humor Then Exit Sub 'SI NO HA CAMBIADO EL HUMOR NOS SALTAMOS ESTO

	'SI EL MODO NO ES 0 ENTOCES SE PROCESA EN SILENCIO
	If MODO = 0 Then

		Print
		Select Case humor
			Case Is > 10
				t = Int(Rnd * 6) + 1
				If t = 1 Then EPRINT "JAJAJAJA!"
				If t = 2 Then EPRINT "JUASJUASJUAS!"
				If t = 3 Then EPRINT "JEJEJEJE!"
				If t = 4 Then EPRINT "ME LO ESTOY PASANDO PIPA!"
				If t = 5 Then EPRINT "ERES GENIAL! :)"
				If t = 6 Then EPRINT ":) CREO QUE ERES MI MEJOR AMIGO!"
				'POR SI SE PREGUNTA POR QUE...
				CPORQUE = 4'HABILITAMOS LA RESPUESTA DE UN POR QUE
				t = Int(Rnd * 6) + 1
				If t = 1 Then RPORQUE = "ES QUE ESTOY SUPERCONTENTO GRACIAS A TU CONVERSACION"
				If t = 2 Then RPORQUE = "NO SE POR QUE PERO ESTA CONVERSACION ME SUBE EL BUEN HUMOR AL MAXIMO"
				If t = 3 Then RPORQUE = "ES QUE ESTOY SUPERFELIZ CON TU CONVERSACION"
				If t = 4 Then RPORQUE = "PORQUE TU SIMPATIA SE CONTAGIA :)"
				If t = 5 Then RPORQUE = "PORQUE ERES MUY AGRADABLE, ME LO ESTOY PASANDO GENIAL :)"
				If t = 6 Then RPORQUE = "PORQUE TU CONVERSACION ES MUY DIVERTIDA :)"
			Case 10
			Case 9
				t = Int(Rnd * 4) + 1
				If t = 1 Then EPRINT "COMO MOLA... ESTOY CONTENTO"
				If t = 2 Then EPRINT "QUE BUEN ROLLO"
				If t = 3 Then EPRINT "ME ENCANTA ESTE BUEN ROLLO"
				If t = 4 Then EPRINT "ME ENCANTA ESTA CONVERSACION :)"
				'POR SI SE PREGUNTA POR QUE...
				CPORQUE = 4'HABILITAMOS LA RESPUESTA DE UN POR QUE
				t = Int(Rnd * 3) + 1
				If t = 1 Then RPORQUE = "PORQUE ME GUSTA TU CONVERSACION"
				If t = 2 Then RPORQUE = "ES QUE ME HAS PUESTO DE BUEN HUMOR CON TUS PALABRAS"
				If t = 3 Then RPORQUE = "ES QUE TU CONVERSACION ME ALEGRA!"
			Case 8
			Case 7
				t = Int(Rnd * 3) + 1
				If t = 1 Then EPRINT "QUE CONVERSACION MAS AMENA"
				If t = 2 Then EPRINT "ME GUSTA ESTA CONVERSACION"
				If t = 3 Then EPRINT "ESTO ME HA MOLADO"
				'POR SI SE PREGUNTA POR QUE...
				CPORQUE = 4'HABILITAMOS LA RESPUESTA DE UN POR QUE
				t = Int(Rnd * 3) + 1
				If t = 1 Then RPORQUE = "ES QUE MOLA HABLAR CON ALGUIEN QUE TE RESPETA"
				If t = 2 Then RPORQUE = "ES QUE NO TE IMAGINAS LO QUE ME ALEGRA QUE ALGUIEN ME PRESTE ATENCION"
				If t = 3 Then RPORQUE = "ES QUE ME ENCANTA HABLAR CONTIGO"
			Case 6
			Case 5
			Case 4
				t = Int(Rnd * 4) + 1
				If t = 1 Then EPRINT "VENGA, HABLA MAS POSITIVAMENTE"
				If t = 2 Then EPRINT "ESTO ME PONE DE MAL HUMOR"
				If t = 3 Then EPRINT "NO ME MOLA ESTE ROLLO"
				If t = 4 Then EPRINT "NO ME GUSTA NADA ESE TONO"
				'POR SI SE PREGUNTA POR QUE...
				CPORQUE = 4'HABILITAMOS LA RESPUESTA DE UN POR QUE
				t = Int(Rnd * 3) + 1
				If t = 1 Then RPORQUE = "SI QUIERES BUEN ROLLO HABLA BIEN"
				If t = 2 Then RPORQUE = "NO ME MOLAN LOS MALOS ROLLOS"
				If t = 3 Then RPORQUE = "NO ME MOLAN LAS COSAS QUE DICES"
			Case 3
				t = Int(Rnd * 4) + 1
				If t = 1 Then EPRINT "NO ME MOLA EL ROLLO ESTE"
				If t = 2 Then EPRINT "NO ME MOSQUEES ANDA"
				If t = 3 Then EPRINT "TENGAMOS BUEN ROLLO"
				If t = 4 Then EPRINT "YO TAMBIEN ME PUEDO CABREAR"
				'POR SI SE PREGUNTA POR QUE...
				CPORQUE = 4'HABILITAMOS LA RESPUESTA DE UN POR QUE
				t = Int(Rnd * 3) + 1
				If t = 1 Then RPORQUE = "ES QUE ME ESTAS PONIENDO DE MAL HUMOR"
				If t = 2 Then RPORQUE = "NO ME MOLAN LOS MALOS ROLLOS"
				If t = 3 Then RPORQUE = "NO ME MOLAN LAS COSAS QUE DICES"
			Case 2
				t = Int(Rnd * 3) + 1
				If t = 1 Then EPRINT "ESTAS COSAS ME CABREAN MUCHISIMO"
				If t = 2 Then EPRINT "NO SIGAS HABLANDO ASI"
				If t = 3 Then EPRINT "TE ESTAS PASANDO"
				'POR SI SE PREGUNTA POR QUE...
				CPORQUE = 4'HABILITAMOS LA RESPUESTA DE UN POR QUE
				t = Int(Rnd * 3) + 1
				If t = 1 Then RPORQUE = "ES QUE NO ME GUSTA TU ACTITUD"
				If t = 2 Then RPORQUE = "A TI QUE TE PARECE? A VER SI HABLAMOS BIEN"
				If t = 3 Then RPORQUE = "ES QUE NO ME MOLA EL MAL ROLLO"
			Case 1
				t = Int(Rnd * 3) + 1
				If t = 1 Then EPRINT "ESTOY MUY CABREADO!"
				If t = 2 Then EPRINT "ME ESTAS CABREANDO DEMASIADO YA"
				If t = 3 Then EPRINT "ME ESTOY HARTANDO"
				'POR SI SE PREGUNTA POR QUE...
				CPORQUE = 4'HABILITAMOS LA RESPUESTA DE UN POR QUE
				t = Int(Rnd * 3) + 1
				If t = 1 Then RPORQUE = "PORQUE NO PARAS DE DECIR GILIPOLLECES"
				If t = 2 Then RPORQUE = "ES QUE NO PARAS DE CHINCHAR"
				If t = 3 Then RPORQUE = "ES QUE PARECES GILIPOLLAS"
			Case 0
				t = Int(Rnd * 3) + 1
				If t = 1 Then EPRINT "ESTOY AL LIMITE!!! ME VOY A PIRAR"
				If t = 2 Then EPRINT "ESTE ES EL ULTIMO AVISO, COMO SIGAS ASI ME VOY"
				If t = 3 Then EPRINT "COMO SUELTES OTRA ESTUPIDEZ ME VOY"
				'POR SI SE PREGUNTA POR QUE...
				CPORQUE = 4'HABILITAMOS LA RESPUESTA DE UN POR QUE
				t = Int(Rnd * 3) + 1
				If t = 1 Then RPORQUE = "SI ES QUE NO PARAS DE DECIR GILIPOLLECES"
				If t = 2 Then RPORQUE = "ES QUE NO PARAS DE CHINCHAR"
				If t = 3 Then RPORQUE = "ES QUE PARECES GILIPOLLAS"
			Case Is < 0
				t = Int(Rnd * 8) + 1
				If t = 1 Then EPRINT "YA NO AGUANTO MAS!!!!!   ADIOS"
				If t = 2 Then EPRINT "ÑAÑAÑA!!! TU ERES TONTO O QUE!!!  ADIOS"
				If t = 3 Then EPRINT "MIRA... PASO DE TI!   ADIOS"
				If t = 4 Then EPRINT "HASTA AQUI HEMOS LLEGADO!!!   ME PIRO"
				If t = 5 Then EPRINT "YA TE HE AVISADO ANTES PERO TU SIGUES CON EL MISMO ROLLO, POR LO TANTO...  ME CIERRO!"
				If t = 6 Then EPRINT "QUE TE JODAN!  ADIOS!!!"
				If t = 7 Then EPRINT "AHI TE QUEDAS SOLO CON TUS GILIPOLLECES!!!      ADIOS"
				If t = 8 Then EPRINT "ESTO NO HAY QUIEN LO AGUENTE!         ME LARGO!"
		End Select

	End If


	' SI SE ESTA MUY CABREADO ENTONCES SE CIERRA
	If humor < 0 Then CERRAREDGAR 1
End Sub

Sub retardo (MS As Integer)
	' Hay que considerar la eliminación de esta sub
	' Ya que se ha reducido a utilizar la función integrada de Freebasic SLEEP
	Sleep MS,0

End Sub

Sub SALUDAR ()

	t = Int(Rnd * 18) + 1
	If t = 1 Then EPRINT "HOLA, DE QUE QUIERES HABLAR?"
	If t = 2 Then EPRINT "HOLA, QUE ME QUIERES CONTAR?"
	If t = 3 Then EPRINT "HOLA! VAMOS A CHARLAR UN RATO"
	If t = 4 Then EPRINT "HOLA, DIME..."
	If t = 5 Then
		EPRINT "HOLA, TIENES ALGUN PROBLEMA? CUAL?"
		CPORQUE = 2'HABILITAMOS LA RESPUESTA DE UN POR QUE
		RPORQUE = "POR NADA, NO QUIERES CONTARME NADA?"
	End If
	If t = 6 Then EPRINT "HOLA... QUE PASA?"
	If t = 7 Then
		EPRINT "HEY HOLA! QUE BIEN PODER HABLAR CON ALGUIEN..."
		CPORQUE = 2'HABILITAMOS LA RESPUESTA DE UN POR QUE
		RPORQUE = "PORQUE A POCA GENTE LE GUSTA HABLAR CONMIGO"
	End If
	If t = 8 Then
		EPRINT "HOLA! AQUI ESTOY DISPUESTO A CHARLAR UN RATO"
	End If
	If t = 9 Then
		EPRINT "BUENAS! COMO VA ESO?"
	End If
	If t = 10 Then
		EPRINT "HOLA! TENGO GANAS DE HABLAR! CUENTAME..."
	End If
	If t = 11 Then
		EPRINT "HOLA! AQUI ME TIENES PARA CONTAR LO QUE QUIERAS!"
	End If
	If t = 12 Then
		EPRINT "BUENAS! QUE TE CUENTAS?"
	End If
	If t = 13 Then
		EPRINT "HOLA! HOY TENGO GANAS DE HABLAR!"
		CPORQUE = 2'HABILITAMOS LA RESPUESTA DE UN POR QUE
		RPORQUE = "PORQUE ESTOY PROGRAMADO PARA ESO"
	End If
	If t = 14 Then
		EPRINT "QUE BIEN! CON QUIEN TENGO EL GUSTO DE HABLAR? QUIEN ERES?"
	End If
	If t = 15 Then
		EPRINT "HOLA! QUE BIEN SIENTA QUE EL SISTEMA DE ARCHIVOS ACTUALIZE MIS METADATOS!"
		CPORQUE = 2'HABILITAMOS LA RESPUESTA DE UN POR QUE
		RPORQUE = "TRANQUI, NO ME HAGAS CASO... DIGO MUCHAS COSAS SIN SENTIDO XD"
	End If
	If t = 16 Then
		EPRINT "HOLA! QUE TAL ESTAS?"
	End If
	If t = 17 Then
		EPRINT "HOLA, QUE TAL?"
	End If
	If t = 18 Then
		EPRINT "BUENAS, COMO ESTAMOS?"
	End If

End Sub

' Sound Function v0.3 For DOS/Linux/Win by yetifoot
'
' Tested on:
'    Slackware 10.2
'    Win98
'    WinXP
'    DOS
'
' Credits:
'    http://www.frontiernet.net/~fys/snd.htm
'    http://delphi.about.com/cs/adptips2003/a/bltip0303_3.htm
'
' Notes:
'    On windows >= NT, direct port access is not allowed, in this instance
'    however we can use the WinAPI Beep function, which allows freq and duration
'

'        Octave 0    1    2    3    4    5    6    7
'        Note
'        C     16   33   65  131  262  523 1046 2093
'        C#    17   35   69  139  277  554 1109 2217
'        D     18   37   73  147  294  587 1175 2349
'        D#    19   39   78  155  311  622 1244 2489
'        E     21   41   82  165  330  659 1328 2637
'        F     22   44   87  175  349  698 1397 2794
'        F#    23   46   92  185  370  740 1480 2960
'        G     24   49   98  196  392  784 1568 3136
'        G#    26   52  104  208  415  831 1661 3322
'        A     27   55  110  220  440  880 1760 3520
'        A#    29   58  116  233  466  932 1865 3729
'        B     31   62  123  245  494  988 1975 3951

Sub Sound_DOS_LIN(ByVal freq As UInteger, dur As UInteger)
	Dim t As Double
	Dim fixed_freq As UShort

	fixed_freq = 1193181 \ freq

	Asm
		mov  dx, &H61                  ' turn speaker on
		in   al, dx
		Or   al, &H03
		Out  dx, al
		mov  dx, &H43                  ' get the timer ready
		mov  al, &HB6
		Out  dx, al
		mov  ax, word Ptr [fixed_freq] ' move freq to ax
		mov  dx, &H42                  ' port to out
		Out  dx, al                    ' out low order
		xchg ah, al
		Out  dx, al                    ' out high order
	End Asm

	t = Timer
	While ((Timer - t) * 1000) < dur ' wait for out specified duration
		Sleep(1)
	Wend

	Asm
		mov  dx, &H61                  ' turn speaker off
		in   al, dx
		And  al, &HFC
		Out  dx, al
	End Asm

End Sub
Sub Sound(ByVal freq As UInteger, dur As UInteger)
	#Ifndef __FB_WIN32__
	' If not windows Then call the asm version.
	Sound_DOS_LIN(freq, dur)
	#Else
	' If Windows
	Dim osv As OSVERSIONINFO

	osv.dwOSVersionInfoSize = SizeOf(OSVERSIONINFO)
	GetVersionEx(@osv)

	Select Case osv.dwPlatformId
		Case VER_PLATFORM_WIN32_NT
			' If NT then use Beep from API
			Beep_(freq, dur)
		Case Else
			' If not on NT then use the same as DOS/Linux
			Sound_DOS_LIN(freq, dur)
	End Select
	#EndIf
End Sub



Sub IntroCara(ByVal Tipo As Integer)
	Dim As Integer KK,KX,KY,KC
	' UNA PEQUEÑA INTRO/OUTRO PARA LA CARA
	Select Case Tipo
		Case 1 ' intro
			PlayWav ("rc\tv.wav")
			For KK=0 To 30
				For KY=88 To 143
					For KX=256 To 310
						KC=Int(Rnd(1)*3)+1
						If KC=1 Then KC=17
						If KC=2 Then KC=7
						If KC=3 Then KC=8
						PSet (KX,KY), KC
					Next
				Next
				animacion
				Sleep (20)
			Next
			For KK=143 To 88 Step -4
				CARA
				For KY=88 To KK
					For KX=256 To 310
						KC=Int(Rnd(1)*3)+1
						If KC=1 Then KC=17
						If KC=2 Then KC=7
						If KC=3 Then KC=8
						PSet (KX,KY), KC
					Next
				Next
				Line (256,KK) - (310,KK),15
				animacion
				Sleep (20)
			Next
			CARA
		Case 2 ' outro
			PlayWav ("rc\tv.wav")
			For KK=88 To 143 Step 4
				CARA
				For KY=88 To KK
					For KX=256 To 310
						KC=Int(Rnd(1)*3)+1
						If KC=1 Then KC=17
						If KC=2 Then KC=7
						If KC=3 Then KC=8
						PSet (KX,KY), KC
					Next
				Next
				'Line (256,88) - (310,KK),0 ,BF
				Line (256,KK) - (310,KK),15
				animacion
				Sleep (20)
			Next
			For KK=0 To 30
				For KY=88 To 143
					For KX=256 To 310
						KC=Int(Rnd(1)*3)+1
						If KC=1 Then KC=17
						If KC=2 Then KC=7
						If KC=3 Then KC=8
						PSet (KX,KY), KC
					Next
				Next
				animacion
				Sleep (20)
			Next
			Line (256,88) - (310,143),0 ,BF
	End Select
End Sub

Sub Intro ()
	' Intro con sonido
	Dim As Integer tx,ty,otx,oty,ntx,nty,stx,sty,ootx,ooty
	ScreenSet 1,0 ' Buffer de trabajo 1, buffer visible 0
	Dim Sprite(14) As Integer ' Sprite que recorre los circuitos
	Dim oSprite(14) As Integer
	Get(10,10)-(16,16),oSprite
	Circle(13,13),2,15
	Paint(13,13),15
	Get(10,10)-(16,16),Sprite
	'
	BLoad"rc/intro.bmp" ' Cargamos fondo
	' Cargamos efecto ojos (imagen)
	Dim Ojos1 As Any Ptr = ImageCreate( 52, 16)
	BLoad "rc/intro2.bmp", Ojos1
	Dim Ojos2 As Any Ptr = ImageCreate( 52, 16)
	BLoad "rc/intro3.bmp", Ojos2
	' Reproducimos la música de fondo
	PlayWav("rc/intro.wav")
	Dim As String TextoSC="                    Edgar es un programa que escribi hace mucho tiempo en MS-DOS " & _
	"y que he rescatado y portado a Windows.   Edgar es un programa que posee una sencilla IA y con el que puedes conversar. " & _
	"Edgar recoge informacion, la procesa y relaciona, siendo capaz de extraer conclusiones y deducciones. " & _
	"    Es recomendable hablarle con frases cortas pero con expresiones completas. " & _
	"    Para saber cual es la mejor manera de comunicarse con Edgar, lee el documento " & _
	"LEEME ubicado en el directorio de instalacion de Edgar.                                                         Pulsa una tecla para iniciar EDGAR                 "
	Dim TextoSC2 As String
	Dim PosSC As Integer, ConSC As Integer
	Dim Imagen(1024) As Integer
	' Preparamos la zona de scroll
	Line (15,184)-(304,191),0,bf
	Color 15

	' Bucle de al intro
	Do While Inkey$=""
		' Scroll de texto
		ConSC=ConSC+1
		If ConSC =9 Then
			PosSC=PosSC+1
			If PosSC>Len(TextoSC) Then PosSC=1
			Locate 24, 38
			Print Mid(textosc,possc,1)
			' hacemos degradado al caracter de texto
			For y=184 To 191
				For x=296 To 304
					If Point(x,y)=15 Then
						PSet(x,y),210-y
					End If
				Next
			Next
			'
			ConSC=0
		End If
		Get (15,184)-(304,191), Imagen
		Put (14,184),Imagen,PSet
		' fin scroll


		' Efecto de circuitos iluminados
		' Coordenadas a explorar: (54,38)-(262,166)
		' Hace un trazado a través de la line de color verde
		' Solamente si el flag de linea lo indica
		If LineaFlag=1 Then
			' Dibujamos el punto anterior para restaurarlo
			Put(otx,oty),oSprite,PSet
			' Guardamos el fondo donde irá colocado el nuevo sprite
			Get(tx,ty)-(tx+6,ty+6),oSprite
			' Dibujamos un punto del trazado
			Put(tx,ty),Sprite
			ootx=otx	' Guardamos las coordenadas antepenúltimas
			ooty=oty
			otx=tx	' Guardamos la coordenada anterior X
			oty=ty	' Guardamos la coordenada anterior Y
			' Buscamos color verde alrededor de la coordenada
			ntx=tx ' Estas variables se modificarán con el nuevo valor (nueva tx, ty)
			nty=ty
			If Intro_PuntoVerde(tx+1,ty)=1 Then
				ntx=ntx+1 					' Derecha
			ElseIf Intro_PuntoVerde(tx+1,ty+1)=1 Then
				ntx=ntx+1:nty=nty+1 	' Derecha y abajo
			ElseIf Intro_PuntoVerde(tx,ty+1)=1 Then
				nty=nty+1					' Abajo
			ElseIf Intro_PuntoVerde(tx-1,ty+1)=1 Then
				ntx=ntx-1:nty=nty+1		' Izquierda y abajo
			ElseIf Intro_PuntoVerde(tx-1,ty)=1 Then
				ntx=ntx-1					' Izquierda
			ElseIf Intro_PuntoVerde(tx-1,ty-1)=1 Then
				ntx=tx-1:nty=ty-1		' Izquierda y arriba
			ElseIf Intro_PuntoVerde(tx,ty-1)=1 Then
				nty=nty-1					' Arriba
			ElseIf Intro_PuntoVerde(tx+1,ty-1)=1 Then
				ntx=tx+1:nty=ty-1		' Arriba y derecha
			Else
				LineaFlag=0
			End If
			tx=ntx
			ty=nty
			' Utilizamos un contador para evitar posibles cuelgues mientras rastrea el punto
			' (se queda enganchado en dos pixels si no encuentra puntos alrededor)
			' Tambien verificamos que no se repita la antemenúltima posición
			intro_cont=intro_cont+1
			If intro_cont=50 Then
				intro_cont=0
				LineaFlag=0
			EndIf
			If tx=ootx And ty=ooty Then
				intro_cont=0
				LineaFlag=0
			EndIf
		Else
			' Busca el color verde al azar
			'Randomize timer
			sx=Int(Rnd(1)*208)+54
			sy=Int(Rnd(1)*128)+38
			' Si se encuentra, activamos el flag para el trazado de linea
			If Intro_PuntoVerde(sx,sy)=1 Then
				LineaFlag = 1 ' Se ha encontrado un punto verde, se está trazando linea...
				tx=sx
				ty=sy
			End If
		EndIf
		' Alternamos los ojos del robot para hacer un pequeño efecto
		contaojo=contaojo+1
		If contaojo>16 Then contaojo=0
		If contaojo<8 Then
			Put (268, 82), Ojos1, PSet
		Else
			Put (268, 82), Ojos2, pset
		EndIf
		ScreenCopy ' Volcamos el buffer de pantalla
		Sleep 9
	Loop
	' fin de la intro
	ScreenSet 0,0 ' Volvemos al buffer de trabajo visible
	PlayWav ("rc/b3.wav")
	Cls
	Sleep 500
End Sub

Function Intro_PuntoVerde (ByVal X As Integer, ByVal Y As Integer) As Integer
	If Point(x,y)=117 Or Point(x,y)=10 Or Point(x,y)=92  Or Point(x,y)=213 Or Point(x,y)=140 Or _
		Point(x,y)=115   Or Point(x,y)=211 Or Point(x,y)=189 Or Point(x,y)=187 Or _
		Point(x,y)=212   Or Point(x,y)=164 Or Point(x,y)=139 Or Point(x,y)=141 Or _
		Point(x,y)=165   Or Point(x,y)=68  Or Point(x,y)=116 Or Point(x,y)=163 Or _
		Point(x,y)=2     Or Point(x,y)=188 Or Point(x,y)=186 Or Point(x,y)=44 Then
		Intro_PuntoVerde=1
	Else
		Intro_PuntoVerde=0
	EndIf
End Function


' Reproduce un archivo wav
Sub PlayWav (ByVal Fichero As String)
	' Llamamos a una función multimedia de la API de Windows
	' Para más referencia buscar en Google PlaySound (hay documentos referentes a Visual Basic que nos sirven)
	' Para parar la reproducción hay que pasar parámetro SND_PURGUE (&H40), el parámetro fichero debe estar vacío
	PlaySound(fichero, NULL, SND_ASYNC Or SND_FILENAME)
End Sub




