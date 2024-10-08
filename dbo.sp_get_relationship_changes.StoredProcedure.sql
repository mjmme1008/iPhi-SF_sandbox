USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_relationship_changes]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[sp_get_relationship_changes]
AS
begin

	select p.rp_id as ExtSysId__c,
	(select SfId from sf_map_contact where PartyId = i.party_id)  as npe4__Contact__c,
	(select SfId from sf_map_contact where PartyId = i2.party_id) as npe4__RelatedContact__c,
	r1.name as npe4__Type__c,
	--FimsPR.AssocDescr as npe4__Description__c,
	CASE WHEN (r1.name = 'Spouse' or r1.name = 'Spouse - deceased') and (i.death_d is not null OR i2.death_d is not null) THEN 'Former' ELSE 'Current' END as npe4__status__c,
	(select top 1 pr.rp_id from tcf.dbo.party_relation pr where pr.child_id = i.party_id and pr.parent_id = i2.party_id) as npe4__ReciprocalRelationship__c,
	'Contact Relationship upsert' as sf_object
	from
	sf_control_table,
	tcf.dbo.individual i,
	tcf.dbo.individual i2,
	sf_map_relationships,
	tcf.dbo.party_relation p
	inner join tcf.dbo.relation_type_c r1 on p.rel_typ_c = r1.code
	where i.party_id = p.parent_id
	and i2.party_id = p.child_id
	and p.rp_id = sf_map_relationships.RpId
	and ((case when isnull(p.stamp,'')<>'' then dbo.fn_stampdatetime(p.stamp) else p.start_d end >= sf_control_table.last_load_date
	and case when isnull(p.stamp,'')<>'' then dbo.fn_stampdatetime(p.stamp) else p.start_d end <= sf_control_table.start_load_date)
	OR exists (select 1 from tcf.dbo.Remove_dups_audit rda 
				where rda.party_id_leave = p.parent_id
				and rda.process_d >= sf_control_table.last_load_date
				and rda.process_d <= sf_control_table.start_load_date)
	OR exists (select 1 from tcf.dbo.Remove_dups_audit rda 
				where rda.party_id_leave = p.child_id
				and rda.process_d >= sf_control_table.last_load_date
				and rda.process_d <= sf_control_table.start_load_date))
	order by 1

end

GO
