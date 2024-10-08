SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[sp_get_affiliation_changes]
AS
begin
	--get org relationship for the individual if an org name is populated for the individual.
	select cast(pr.parent_id as varchar(20)) + '-' + cast(pr.child_id as varchar(20)) + '-' + cast(pr.rel_typ_c as varchar(10)) as ExtSysId__c, 	
	(select SFId from sf_map_contact where sf_map_contact.Partyid = pr.child_id) as npe5__Contact__c, --individual
	(select SFId from sf_map_org_account where sf_map_org_account.PartyId = pr.parent_id) as npe5__Organization__c, --organization
	(select rt.name  from tcf.dbo.relation_type_c rt where rt.code = pr.rel_typ_c ) as npe5__Role__c,
	pr.title as title__c,
	--coalesce(p1.Address1,'') + char(13) + coalesce(p1.Address2,'') + char(13) + coalesce(p1.City,'') + ' ' + coalesce(p1.State,'') + ' ' + coalesce(p1.Zip,'') as AffiliationAddress__c,
	cast(pr.start_d as date) as npe5__StartDate__c,
	cast(pr.end_d as date) as npe5__EndDate__c,
	'' as npe5__Description,
	'Upsert affiliations' as sf_object
	from tcf.dbo.party_relation pr,
	tcf.dbo.organization org, 
	sf_map_org_account, 
	sf_control_table,
	sf_map_affiliations
	where --pr.rel_typ_c in (62,115,1001) --primary contact, exe director, grant admin
	--and 
	pr.parent_id = org.party_id
	and pr.child_id not in (select party_id from tcf..party where party_typ_c = 2)			--ITS3428 - exclude org-to-org relationships
	and ((case when isnull(pr.stamp,'')<>'' then dbo.fn_stampdatetime(pr.stamp) else pr.start_d end >= sf_control_table.last_load_date
	and case when isnull(pr.stamp,'')<>'' then dbo.fn_stampdatetime(pr.stamp) else pr.start_d end <= sf_control_table.start_load_date)
	OR exists (select 1 from tcf.dbo.Remove_dups_audit rda 
				where rda.party_id_leave = pr.parent_id
				and rda.process_d >= sf_control_table.last_load_date
				and rda.process_d <= sf_control_table.start_load_date))
	and sf_control_table.source_object = 'IPHISync'
	and org.party_id = sf_map_org_account.PartyId
	and cast(pr.parent_id as varchar(20)) + '-' + cast(pr.child_id as varchar(20)) + '-' + cast(pr.rel_typ_c as varchar(10)) = sf_map_affiliations.Id
	order by 1

end

GO
