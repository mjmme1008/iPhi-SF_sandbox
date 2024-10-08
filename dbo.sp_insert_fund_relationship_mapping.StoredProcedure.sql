USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_fund_relationship_mapping]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_insert_fund_relationship_mapping]
AS
begin

	select ip.ip_id
	from tcf.dbo.interested_party ip, tcf.dbo.account acct,
	tcf.dbo.acct_role_c ar
	where  ip.acct_role_c = ar.code
	and acct.acct_id = ip.acct_id
	and acct.acct_type_c <> 1
	--and ar.entity in ('dfund')
	and not exists (select 1 from sf_map_fund_relationship map1 where map1.IpId = ip.ip_id)

end

GO
