USE [SFdb_sandbox]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_stampdate]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_stampdate] (@stamp char(16))  

RETURNS datetime  

AS 

BEGIN 

DECLARE @stampdate datetime  

if len(rtrim(@stamp))<16 and ISDATE(left(@stamp,8))=1 
	set @stampdate = convert(date,left(@stamp,8))
else 
	set @stampdate = dateadd(d,CONVERT(int,substring(@stamp,5,3)-1),'01/01/'+LEFT(@stamp,4))  
		
    RETURN @stampdate  

END 

GO
