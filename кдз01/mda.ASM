format PE console

entry Start

include 'win32a.inc'

section '.data' data readable writable

        enterStr db "(1+x)^m",10,"enter x (-1<x<1) and m:",10,0
        ffStr db "%lf %lf",0
        ffnlStr db "sequence term = %.8lf, result = %.8lf",10,0
        inlStr db "iteration %d:",10,0
        nl db 10,0
        ; ����� ��������
        k dd 0
        ; �������� x
        x dq ?
        ; �������� m
        m dq ?
        ; ������� ���� ����
        term dq ?
        ; ������� ����� ����
        sum dq ?
        ; ��������� 1
        one dq 1.0
        ; �����������
        epsilon dq 0.0005
        ; ������� �����������
        epsilonSq dq ?


section '.code' code readable executable


; ��������������� ��� ������ ����� � ��������� �������
macro PrintFloat str, [args] {
    reverse
      push dword [args+4]
      push dword [args]
    common
      push str
      call [printf]
}



        Start:
                 ; finit

                ; ���� x � m
                cinvoke printf, enterStr
                cinvoke scanf, ffStr, x, m

                ; term = 1, sum = 1
                fld qword [one]
                fst qword [term]
                fstp qword [sum]

                ; epsilonSq = epsilon^2
                fld qword [epsilon]
                fmul qword [epsilon]
                fstp qword [epsilonSq]

                ; ������� ����
                MainLoop:
                        cmp [k], 1000000 ; �������� ��������
                        je PrintResult

                        ; ����� ������� term � sum
                        cinvoke printf, inlStr, [k]
                        PrintFloat ffnlStr, term, sum

                        fld qword [m]
                        fisub dword [k] ; st0 = m-k

                        fild dword [k]
                        fadd qword [one] ; st0 = k+1

                        fdivp st1, st0 ; st0 = (m-k)/(k+1)
                        fmul qword [x] ; st0 = (m-k)/(k+1)*x

                        fmul qword [term] ; st0 = st0*term
                        fst qword [term] ; term = (m-k)/(k+1)*x*term

                        fadd qword [sum] ; st0 = st0+sum
                        fstp qword [sum] ; sum = sum+term

                        inc [k] ; k++


                        ; ���� |term| <= epsilon^2 ����� break
                        ; (term <= epsilon^2 && -term >= epsilon^2)
                        fld qword [epsilonSq] ; epsilon^2
                        fld qword [term]
                        fcomi st1
                        jnbe Last ; ���� term > epsilon^2

                        ffree st0 ; st0 = null
                        ffree st1 ; st1 = null

                        fld qword [epsilonSq]
                        fsub qword [epsilonSq]
                        fsub qword [epsilonSq] ; -epsilon^2
                        fld qword [term]
                        fcomi st1
                        jb Last ; ��� ���� -term < epsilon^2

                        ffree st0 ; st0 = null
                        ffree st1 ; st1 = null

                        jmp PrintResult ; break

                        Last:
                        ffree st0 ; st0 = null
                        ffree st1 ; st1 = null
                jmp MainLoop


                PrintResult:
                        ; ����� ����������
                        cinvoke printf, inlStr, [k]
                        PrintFloat ffnlStr, term, sum



        Finish:
                cinvoke getch
                cinvoke ExitProcess, 0


section '.idata' import data readable

        library kernel32, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'

        import kernel32,\
               ExitProcess, 'ExitProcess',\
               HeapCreate, 'HeapCreate',\
               HeapAlloc, 'HeapAlloc',\
               HeapFree, 'HeapFree'

        import msvcrt,\
               printf, 'printf',\
               scanf, 'scanf',\
               getch, '_getch'