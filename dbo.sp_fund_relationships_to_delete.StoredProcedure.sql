USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_fund_relationships_to_delete]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[sp_fund_relationships_to_delete]
AS
begin
	--fund relationships to delete from the maping tables and salesforce
	select sf_map_fund_relationship.IpId, SfId 
	from sf_map_fund_relationship
	where SfId is not null
	and not exists (select 1 	from tcf.dbo.interested_party ip, tcf.dbo.acct_role_c ar
								where ip.acct_role_c = ar.code
								--and ar.entity in ('dfund')
								and ip.ip_id = sf_map_fund_relationship.IpId)

end
GO
