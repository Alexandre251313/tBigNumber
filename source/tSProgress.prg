#IFDEF PROTHEUS
	#DEFINE __PROTHEUS__
	#include "protheus.ch"
#ELSE
	#IFDEF __HARBOUR__
		#include "hbClass.ch"
	#ENDIF
#ENDIF
#include "tBigNumber.ch"
/*
	Class		: tSProgress
	Autor       : Marinaldo de Jesus [http://www.blacktdn.com.br]
	Data        : 29/12/2013
	Descricao   : Instancia um novo objeto do tipo tSProgress
	Sintaxe     : tSProgress():New(cProgress,cToken) -> self
*/
Class tSProgress

#IFNDEF __PROTHEUS__	
	PROTECTED:
#ENDIF	
	
	DATA aProgress	AS ARRAY INIT Array(0) HIDDEN
	
	DATA nMax		AS NUMERIC INIT 0      HIDDEN
	DATA nProgress	AS NUMERIC INIT 0      HIDDEN
	
	DATA lShuttle  AS LOGICAL INIT .F.    HIDDEN
	
#IFNDEF __PROTHEUS__
	EXPORTED:
#ENDIF

	Method New(cProgress,cToken)  CONSTRUCTOR
	Method ClassName()
	Method SetProgress(cProgress,cToken)

	Method Eval(cMethod,uPar01)
	Method Progress()
	Method Increment(cAlign)
	Method Decrement(cAlign)
	Method Shuttle(cAlign)

	Method GetnMax()
	Method GetnProgress()

EndClass

#IFDEF __PROTHEUS__
	User Function tSProgress(cProgress,cToken)
	Return(tSProgress():New(@cProgress,@cToken))
#ENDIF

Method New(cProgress,cToken) Class tSProgress
	self:SetProgress(@cProgress,@cToken)
Return(self)

Method ClassName() Class tSProgress
Return("TSPROGRESS")

Method SetProgress(cProgress,cToken) Class tSProgress
	Local lMacro
	DEFAULT cProgress	:= "-;\;|;/"
	DEFAULT cToken		:= ";"	
	lMacro := (SubStr(cProgress,1,1)=="&")
	IF (lMacro)
		cProgress		:= SubStr(cProgress,2)
		cProgress		:= &(cProgress)
	EndIF
	self:aProgress		:= _StrToKArr(@cProgress,@cToken)
	self:nMax			:= Len(self:aProgress)
	self:nProgress		:= 0
Return(self)

Method Eval(cMethod,uPar01) Class tSProgress
	Local cEval
	DEFAULT cMethod := "PROGRESS"
	DO CASE
	CASE (cMethod=="PROGRESS")
		cEval := self:Progress()
	CASE (cMethod=="INCREMENT")
		cEval := self:Increment(@uPar01)
	CASE (cMethod=="DECREMENT")
		cEval := self:Decrement(@uPar01)
	CASE (cMethod=="SHUTTLE")	
		cEval := self:Shuttle(@uPar01)
	OTHERWISE
		cEval := self:Progress()	
	ENDCASE
Return(cEval)

Method Progress() Class tSProgress
Return(self:aProgress[IF(++self:nProgress>self:nMax,self:nProgress:=1,self:nProgress)])

Method Increment(cAlign) Class tSProgress
	Local cPADFunc  := "PAD"
	Local cProgress := ""
	Local nProgress
	IF (++self:nProgress>self:nMax)
		self:nProgress := 1
	EndIF
	For nProgress := 1 To self:nProgress
		cProgress += self:aProgress[nProgress]
	Next nProgress
	DEFAULT cAlign := "R" //L,C,R
	cPADFunc += cAlign
Return(&cPADFunc.(cProgress,self:nMax))

Method Decrement(cAlign) Class tSProgress
	Local cPADFunc  := "PAD"
	Local cProgress := ""
	Local nProgress
	IF (--self:nProgress<=0)
		self:nProgress := self:nMax
	EndIF
	For nProgress := self:nMax To self:nProgress STEP (-1)
		cProgress += self:aProgress[nProgress]
	Next nProgress
	DEFAULT cAlign := "L" //L,C,R
	cPADFunc += cAlign
Return(&cPADFunc.(cProgress,self:nMax))

Method Shuttle(cAlign) Class tSProgress
	Local cEval
	IF (.NOT.(self:lShuttle).and.(self:nProgress==self:nMax))
		self:lShuttle := .T.
	ElseIF (self:lShuttle.and.(self:nProgress==self:nMax))
		self:lShuttle := .F.
	EndIF	
	IF (self:lShuttle)
		cEval := "DECREMENT" 
	Else
		cEval := "INCREMENT"
	EndIF
Return(self:Eval(cEval,@cAlign))	

Method GetnMax() Class tSProgress
Return(self:nMax)

Method GetnProgress() Class tSProgress
Return(self:nProgress)

Static Function _StrToKArr(cStr,cToken)
	Local cDToken
	DEFAULT cStr   := ""
	DEFAULT cToken := ";"
	cDToken := (cToken+cToken)
	While (cDToken$cStr)
		cStr := StrTran(cStr,cDToken,cToken+" "+cToken)
	End While
#IFDEF PROTHEUS
Return(StrToKArr(cStr,cToken))
#ELSE
Return(hb_aTokens(cStr,cToken))
#ENDIF