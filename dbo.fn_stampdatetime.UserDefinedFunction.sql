USE [SFdb_sandbox]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_stampdatetime]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_stampdatetime] (@stamp char(16))  

RETURNS datetime  

AS 

BEGIN 

declare @stamptime char(6)
DECLARE @strtime char(8)
DECLARE @stampdate datetime  

if @stamp is null
	set @stampdate=null

if len(rtrim(@stamp))<16 and ISDATE(left(@stamp,8))=1 
	set @stamptime = right(rtrim(@stamp),6)
else
	set @stamptime = left(right(rtrim(@stamp),9),6)

set @strtime = left(@stamptime,2)+':'+substring(@stamptime,3,2)+':'+substring(@stamptime,5,2)

if len(rtrim(@stamp))<16 and ISDATE(left(@stamp,8))=1 
	set @stampdate = convert(datetime,left(@stamp,8)+' '+@strtime)
else 
	set @stampdate = dateadd(d,CONVERT(int,substring(@stamp,5,3)-1),'01/01/'+LEFT(@stamp,4)+' '+@strtime)  
		
    RETURN @stampdate  

END 

--select convert(datetime,'20070830 00:07:58')

--select CONVERT(time,'00:07:58')
GO
