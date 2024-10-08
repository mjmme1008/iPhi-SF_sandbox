USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_affiliations_delete]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_affiliations_delete]
AS
begin
	--gifts to delete from the maping tables and salesforce
	select Id, SfId from sf_map_affiliations
	where SfId is not null
	and not exists (select 1 from tcf.dbo.party_relation pr, 
									tcf.dbo.organization org, 
									sf_map_org_account
									where pr.rel_typ_c in (62,115,1001) --primary contact, exe director, grant admin
									and pr.parent_id = org.party_id
									and org.party_id = sf_map_org_account.PartyId 
									and cast(pr.parent_id as varchar(20)) + '-' + cast(pr.child_id as varchar(20)) + '-' + cast(pr.rel_typ_c as varchar(10)) = sf_map_affiliations.Id)

end
GO
