SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_insert_affilations_mapping]
AS
begin

	select cast(pr.parent_id as varchar(20)) + '-' + cast(pr.child_id as varchar(20)) + '-' + cast(pr.rel_typ_c as varchar(10)) as Id
	from tcf.dbo.party_relation pr, 
	tcf.dbo.organization org, 
	sf_map_org_account, 
	sf_control_table
	where pr.parent_id = org.party_id
	and child_id not in (select party_id from tcf..party where party_typ_c = 2)			--ITS3428 - exclude org-to-org relationships
	and sf_control_table.source_object = 'IPHISync'
	and org.party_id = sf_map_org_account.PartyId
	and not exists (select 1 from sf_map_affiliations map1 where map1.Id = cast(pr.parent_id as varchar(20)) + '-' + cast(pr.child_id as varchar(20)) + '-' + cast(pr.rel_typ_c as varchar(10)))
	order by 1

end
GO
