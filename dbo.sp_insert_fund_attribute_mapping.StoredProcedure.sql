USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_fund_attribute_mapping]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_insert_fund_attribute_mapping]
AS
begin

	select
	'FOI' + cast(pi.id as varchar(15)) as id
	from tcf.dbo.dfund_ifield pi,
	tcf.dbo.account a,
	tcf.dbo.dfund f
	where a.acct_id = pi.dfund_id
	and f.dfund_id = a.acct_id
	and not exists (select 1 from sf_map_fund_attributes map1 where map1.Id = 'FOI' + cast(pi.id as varchar(20)) )
	order by 1

end

GO
