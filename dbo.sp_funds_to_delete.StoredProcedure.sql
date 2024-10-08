USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_funds_to_delete]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_funds_to_delete]
AS
begin
	--funds to delete from the maping tables and salesforce
	select AcctId, SfId from sf_map_fund
	where SfId is not null
	and not exists (select 1 from tcf.dbo.account acct
								where acct.acct_id = sf_map_fund.AcctId
								and acct.acct_type_c <> 1)

end
GO
