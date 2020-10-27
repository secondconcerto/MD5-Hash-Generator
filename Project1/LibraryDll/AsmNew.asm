.586
.xmm

.MODEL FLAT, STDCALL

.DATA
var DD 067452301h, 0efcdab89h, 098badcfeh, 010325476h
temp_1 DD 0

OPTION CASEMAP:NONE

INCLUDE C:/masm32/include/windows.inc

;Specify the per-calculated shift amounts:
S11 = 7
S12 = 12
S13 = 17
S14 = 22
S21 = 5
S22 = 9
S23 = 14
S24 = 20
S31 = 4
S32 = 11
S33 = 16
S34 = 23
S41 = 6
S42 = 10
S43 = 15
S44 = 21


;Define macros to implement auxiliary functions for each of digest rounds:
ROUND1 macro a,b,c,d,k,s,i

	mov	edi,b
	mov	ebp,b
	and	edi,c
	not	ebp
	and	ebp,d
	or	edi,ebp
	lea	a,dword ptr [a+edi+i]
	add	a,dword ptr [esi+k*4]
	rol	a,s
	add	a,b

endm ROUND1



ROUND2 macro a,b,c,d,k,s,i

	mov	edi,d
	mov	ebp,d
	and	edi,b
	not	ebp
	and	ebp,c
	or	edi,ebp
	lea	a,dword ptr [a+edi+i]
	add	a,dword ptr [esi+k*4]
	rol	a,s
	add	a,b

endm ROUND2



ROUND3 macro a,b,c,d,k,s,i

	mov	ebp,b
	xor	ebp,c
	xor	ebp,d
	lea	a,dword ptr [a+ebp+i]
	add	a,dword ptr [esi+k*4]
	rol	a,s
	add	a,b

endm ROUND3



ROUND4 macro a,b,c,d,k,s,i

	mov	ebp,d
	not	ebp
	or	ebp,b
	xor	ebp,c
	lea	a,dword ptr [a+ebp+i]
	add	a,dword ptr [esi+k*4]
	rol	a,s
	add	a,b

endm 

.CODE
_MD5 proc

	pushad
	mov	esi,dword ptr [esp+04h+8*4] ; esi = MD buffer
	;Initialize A,B,C,D buffers:
	movups xmm1, [var] ;move array with buffers to xmm register
	movups [esi], xmm1 ;move xmm register do esi register
	mov	eax, dword ptr [esp+0Ch+8*4] ; eax = length of input message
	push eax ; push register out onto the stack 
	xor	edx,edx ; set edx to 0
	mov	ecx,64 
	div	ecx
	inc	eax
	pop	edx
	sub	esp,64
	mov	ebx,esp
	mov	esi,dword ptr [esp+08h+24*4]
	xchg	eax,edx

_n0:

	mov	edi,ebx
	dec	edx
	jne	_n1
	test	eax,eax
	js	_nD
	mov	byte ptr [ebx+eax],80h
	jmp	_nC

_nD:

	xor	eax,eax
	dec	eax

_nC:

	mov	ecx,64
	sub	ecx,eax
	add	edi,eax
	push	eax
	xor	eax,eax
	inc	edi
	dec	ecx
	rep	stosb
	pop	eax
	test	eax,eax
	js	_nB
	cmp	eax,56
	jnb	_nE

_nB:

    push	eax
	mov	eax,dword ptr [esp+0Ch+25*4]
	push	edx
	xor	edx,edx
	mov	ecx,8
	mul	ecx
	mov	dword ptr [ebx+56],eax
	mov	dword ptr [ebx+60],edx
	pop	edx
	pop	eax
	jmp	_n1

_nE:

	inc	edx

_n1:

	test	eax,eax
	js	_nA
	cmp	eax,64
	jnb	_n2
	jmp	_n10

_nA:

	xor	eax,eax

_n10:

	mov	ecx,eax
	jmp	_n3

_n2:

	mov	ecx,64

_n3:

	mov	edi,ebx
	rep	movsb
	push	eax
	push	edx
	push	ebx
	push	esi
	lea	esi,dword ptr [esp+10h]
	mov	edi,dword ptr [esp+4+28*4]
	push	edi
	mov	eax,dword ptr [edi]
	mov	ebx,dword ptr [edi+04h]
	mov	ecx,dword ptr [edi+08h]
	mov	edx,dword ptr [edi+0Ch]



	ROUND1	eax, ebx, ecx, edx, 0, S11, 0d76aa478h

	ROUND1	edx, eax, ebx, ecx, 1, S12, 0e8c7b756h

	ROUND1	ecx, edx, eax, ebx, 2, S13, 0242070dbh

	ROUND1	ebx, ecx, edx, eax, 3, S14, 0c1bdceeeh

	ROUND1	eax, ebx, ecx, edx, 4, S11, 0f57c0fafh

	ROUND1	edx, eax, ebx, ecx, 5, S12, 04787c62ah

	ROUND1	ecx, edx, eax, ebx, 6, S13, 0a8304613h

	ROUND1	ebx, ecx, edx, eax, 7, S14, 0fd469501h

	ROUND1	eax, ebx, ecx, edx, 8, S11, 0698098d8h

	ROUND1	edx, eax, ebx, ecx, 9, S12, 08b44f7afh

	ROUND1	ecx, edx, eax, ebx, 10, S13, 0ffff5bb1h

	ROUND1	ebx, ecx, edx, eax, 11, S14, 0895cd7beh

	ROUND1	eax, ebx, ecx, edx, 12, S11, 06b901122h

	ROUND1	edx, eax, ebx, ecx, 13, S12, 0fd987193h

	ROUND1	ecx, edx, eax, ebx, 14, S13, 0a679438eh

	ROUND1	ebx, ecx, edx, eax, 15, S14, 049b40821h



	ROUND2	eax, ebx, ecx, edx, 1, S21, 0f61e2562h

	ROUND2	edx, eax, ebx, ecx, 6, S22, 0c040b340h

	ROUND2	ecx, edx, eax, ebx,11, S23, 0265e5a51h

	ROUND2	ebx, ecx, edx, eax, 0, S24, 0e9b6c7aah

	ROUND2	eax, ebx, ecx, edx, 5, S21, 0d62f105dh

	ROUND2	edx, eax, ebx, ecx,10, S22, 002441453h

	ROUND2	ecx, edx, eax, ebx,15, S23, 0d8a1e681h

	ROUND2	ebx, ecx, edx, eax, 4, S24, 0e7d3fbc8h

	ROUND2	eax, ebx, ecx, edx, 9, S21, 021e1cde6h

	ROUND2	edx, eax, ebx, ecx,14, S22, 0c33707d6h

	ROUND2	ecx, edx, eax, ebx, 3, S23, 0f4d50d87h

	ROUND2	ebx, ecx, edx, eax, 8, S24, 0455a14edh

	ROUND2	eax, ebx, ecx, edx,13, S21, 0a9e3e905h

	ROUND2	edx, eax, ebx, ecx, 2, S22, 0fcefa3f8h

	ROUND2	ecx, edx, eax, ebx, 7, S23, 0676f02d9h

	ROUND2	ebx, ecx, edx, eax,12, S24, 08d2a4c8ah



	ROUND3	eax, ebx, ecx, edx, 5, S31, 0fffa3942h

	ROUND3	edx, eax, ebx, ecx, 8, S32, 08771f681h

	ROUND3	ecx, edx, eax, ebx,11, S33, 06d9d6122h

	ROUND3	ebx, ecx, edx, eax,14, S34, 0fde5380ch

	ROUND3	eax, ebx, ecx, edx, 1, S31, 0a4beea44h

	ROUND3	edx, eax, ebx, ecx, 4, S32, 04bdecfa9h

	ROUND3	ecx, edx, eax, ebx, 7, S33, 0f6bb4b60h

	ROUND3	ebx, ecx, edx, eax,10, S34, 0bebfbc70h

	ROUND3	eax, ebx, ecx, edx,13, S31, 0289b7ec6h

	ROUND3	edx, eax, ebx, ecx, 0, S32, 0eaa127fah

	ROUND3	ecx, edx, eax, ebx, 3, S33, 0d4ef3085h

	ROUND3	ebx, ecx, edx, eax, 6, S34, 004881d05h

	ROUND3	eax, ebx, ecx, edx, 9, S31, 0d9d4d039h

	ROUND3	edx, eax, ebx, ecx,12, S32, 0e6db99e5h

	ROUND3	ecx, edx, eax, ebx,15, S33, 01fa27cf8h

	ROUND3	ebx, ecx, edx, eax, 2, S34, 0c4ac5665h



	ROUND4	eax, ebx, ecx, edx, 0, S41, 0f4292244h

	ROUND4	edx, eax, ebx, ecx, 7, S42, 0432aff97h

	ROUND4	ecx, edx, eax, ebx,14, S43, 0ab9423a7h

	ROUND4	ebx, ecx, edx, eax, 5, S44, 0fc93a039h

	ROUND4	eax, ebx, ecx, edx,12, S41, 0655b59c3h

	ROUND4	edx, eax, ebx, ecx, 3, S42, 08f0ccc92h

	ROUND4	ecx, edx, eax, ebx,10, S43, 0ffeff47dh

	ROUND4	ebx, ecx, edx, eax, 1, S44, 085845dd1h

	ROUND4	eax, ebx, ecx, edx, 8, S41, 06fa87e4fh

	ROUND4	edx, eax, ebx, ecx,15, S42, 0fe2ce6e0h

	ROUND4	ecx, edx, eax, ebx, 6, S43, 0a3014314h

	ROUND4	ebx, ecx, edx, eax,13, S44, 04e0811a1h

	ROUND4	eax, ebx, ecx, edx, 4, S41, 0f7537e82h

	ROUND4	edx, eax, ebx, ecx,11, S42, 0bd3af235h

	ROUND4	ecx, edx, eax, ebx, 2, S43, 02ad7d2bbh

	ROUND4	ebx, ecx, edx, eax, 9, S44, 0eb86d391h



	pop	edi
	
	movups xmm0, dword ptr [edi]
	mov [temp_1], eax
	movups xmm1, [temp_1]
	
	mov [temp_1], ebx 
	movups xmm2, [temp_1]
	pslldq xmm2, 4

	
	mov [temp_1], ecx 
	movups xmm3, [temp_1]
	pslldq xmm3, 8

	
	mov [temp_1], edx 
	movups xmm4, [temp_1]
	pslldq xmm4, 12

	PADDQ   xmm1, xmm2
	PADDQ    xmm1, xmm3
	PADDQ    xmm1, xmm4

	PADDQ    xmm0, xmm1
	movups dword ptr [edi], xmm0
	
	;add	dword ptr [edi],eax
	;;add	dword ptr [edi+04h],ebx
	;add	dword ptr [edi+08h],ecx
	;add	dword ptr [edi+0Ch],edx
	
	pop	esi
	pop	ebx
	pop	edx
	pop	eax
	sub	eax,64
	test	edx,edx
	jne	_n0
	add	esp,64
	popad
	ret	12


_MD5 endp
END