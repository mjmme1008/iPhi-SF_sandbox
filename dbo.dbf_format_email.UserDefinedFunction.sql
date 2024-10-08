USE [SFdb_sandbox]
GO
/****** Object:  UserDefinedFunction [dbo].[dbf_format_email]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[dbf_format_email]

      (@Email VarChar(80))

RETURNS VarChar(80) AS

 

BEGIN

declare @Valid int = 0

 

SET @Email = Coalesce(RTrim(LTrim(@Email)), '')

 

IF CharIndex('@',@Email) = 0

   SET @Email = ''

 

IF CharIndex(';',@Email) > 0

   SET @Email = SUBSTRING(@Email,1,CharIndex(';',@Email)-1)

 

IF CharIndex(Char(32),@Email) > 0

   SET @Email = REPLACE(@Email,Char(32),'')

-- fix per ticket #3176
IF CharIndex(Char(160),@Email) > 0

   SET @Email = REPLACE(@Email,Char(160),'')
 

IF CharIndex('mailto:',@Email) > 0

   SET @Email = Substring(@Email, (CharIndex('mailto:',@Email) + 7),(LEN(@Email) - CharIndex('mailto:',@Email)))

 

IF @Email IS NOT NULL  

   SET @Email = LOWER(@Email) 

   

   IF @Email like '[a-z,0-9,_,-]%@[a-z,0-9,_,-]%.[a-z][a-z]%' 

   AND @Email NOT like '%@%@%' 

   AND CHARINDEX('.@',@Email) = 0 

   AND CHARINDEX('..',@Email) = 0 

   AND CHARINDEX(',',@Email) = 0 

   AND RIGHT(@Email,1) between 'a' AND 'z' 

      SET @Valid=1

   ELSE

      SET @Email = ''

     

RETURN (@Email)

 

END
GO
