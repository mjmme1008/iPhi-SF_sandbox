USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_fund_mapping]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_insert_fund_mapping]
AS
begin

	select acct.acct_id,
	substring(acct.acct_nm,1,200) as fund_name
	from tcf.dbo.account acct, sf_control_table
	where sf_control_table.source_object = 'IPHISync'
	and acct.acct_type_c <> 1
	and acct.acct_status_c <> 3
	and not exists (select 1 from sf_map_fund map1 where map1.AcctId = acct.acct_id)
	order by 1

end

GO
