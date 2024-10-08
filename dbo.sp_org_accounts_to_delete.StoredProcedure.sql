USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_org_accounts_to_delete]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_org_accounts_to_delete]
AS
begin
	--org accounts to delete from the maping tables and salesforce
	select PartyId, SfId from sf_map_org_account
	where SfId is not null
	and not exists (select 1 from tcf.dbo.organization org, 
									tcf.dbo.party party
								where party.party_id = sf_map_org_account.PartyId)

end
GO
