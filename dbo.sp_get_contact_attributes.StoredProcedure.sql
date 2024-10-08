SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[sp_get_contact_attributes]
AS
begin

	select 
	cast(pi.id as varchar(20)) as ExtSysId__c,
	(select sfid from sf_map_contact where sf_map_contact.PartyId = i.party_id) as contact__c, 
	(select sfid from sf_map_hh_account where sf_map_hh_account.PartyId = i.party_id) as account__c, 
	si.name as category__c, 
	null as Type__c,
	null as Sub_Type__c,
	null as SubType2__c,
	cast(pi.start_d as date) as start_date__c, 
	cast(pi.end_d as date) as end_date__c,
	'false' as Default__c,
	'Upsert Contact_attribute__c' as sf_object
	from sf_control_table,
	tcf.dbo.party_identifier pi,
	tcf.dbo.spcl_identifier si,
	tcf.dbo.party p,
	tcf.dbo.individual i,
	sf_map_contact_attributes
	where pi.spcl_identifier_id = si.spcl_identifier_id 
	and p.party_id = pi.party_id
	and p.party_id = i.party_id
	and cast(pi.id as varchar(20)) = sf_map_contact_attributes.Id
	and isnull(pi.end_d,getdate()) >= getdate()
	and ((dbo.fn_stampdatetime(pi.stamp) >= sf_control_table.last_load_date
	and dbo.fn_stampdatetime(pi.stamp) <= sf_control_table.start_load_date)
	or (dbo.fn_stampdatetime(si.stamp) >= sf_control_table.last_load_date
	and dbo.fn_stampdatetime(si.stamp) <= sf_control_table.start_load_date)
	OR exists (select 1 from tcf.dbo.Remove_dups_audit rda 
				where rda.party_id_leave = p.party_id
				and rda.process_d >= sf_control_table.last_load_date
				and rda.process_d <= sf_control_table.start_load_date))

	UNION

	select 
	'FOI' + cast(pi.id as varchar(15)) as ExtSysId__c,
	(select sfid from sf_map_contact where sf_map_contact.PartyId = i.party_id) as contact__c,
	(select sfid from sf_map_hh_account where sf_map_hh_account.PartyId = i.party_id) as account__c, 
	'Field of Interest' as category__c, 
	coalesce((select it3.name from tcf.dbo.ifield_tree_c it, 
									tcf.dbo.ifield_tree_c it2, 
									tcf.dbo.ifield_tree_c it3 
							where it.code = pi.ifield_c 
							and it.parent_id = it2.code
							and it2.parent_id = it3.code),				
	coalesce((select it2.name from tcf.dbo.ifield_tree_c it, 
									tcf.dbo.ifield_tree_c it2 
							where it.code = pi.ifield_c 
							and it.parent_id = it2.code),
	(select it.name from tcf.dbo.ifield_tree_c it
					where it.code = pi.ifield_c )))	as Type__c,

	CASE WHEN (select it3.name from tcf.dbo.ifield_tree_c it, 
									tcf.dbo.ifield_tree_c it2, 
									tcf.dbo.ifield_tree_c it3 
							where it.code = pi.ifield_c 
							and it.parent_id = it2.code
							and it2.parent_id = it3.code) is null then

	CASE WHEN (select it2.name from tcf.dbo.ifield_tree_c it, 
									tcf.dbo.ifield_tree_c it2
							where it.code = pi.ifield_c 
							and it.parent_id = it2.code) is null THEN null else
																	(select it.name from tcf.dbo.ifield_tree_c it
																					where it.code = pi.ifield_c ) end else
																	(select it2.name from tcf.dbo.ifield_tree_c it, 
																							tcf.dbo.ifield_tree_c it2 
																					where it.code = pi.ifield_c 
																				and it.parent_id = it2.code) end as Sub_Type__c,


	CASE WHEN (select it3.name from tcf.dbo.ifield_tree_c it, 
									tcf.dbo.ifield_tree_c it2, 
									tcf.dbo.ifield_tree_c it3 
							where it.code = pi.ifield_c 
							and it.parent_id = it2.code
							and it2.parent_id = it3.code) is null then null else (select it.name from tcf.dbo.ifield_tree_c it where it.code = pi.ifield_c ) end as SubType2__c,
	null as start_date__c, 
	null as end_date__c,
	CASE WHEN pi.default_f = 1 THEN 'true' ELSE 'false' END as Default__c,
	'Upsert contact_attribute__c FOI' as sf_object
	from sf_control_table,
	tcf.dbo.party_ifield pi,
	tcf.dbo.party p,
	tcf.dbo.individual i,
	sf_map_contact_attributes
	where p.party_id = pi.party_id
	and p.party_id = i.party_id
	and 'FOI' + cast(pi.id as varchar(15)) = sf_map_contact_attributes.Id
	and ((dbo.fn_stampdatetime(pi.stamp) >= sf_control_table.last_load_date
	and dbo.fn_stampdatetime(pi.stamp) <= sf_control_table.start_load_date)
	OR exists (select 1 from tcf.dbo.Remove_dups_audit rda 
				where rda.party_id_leave = p.party_id
				and rda.process_d >= sf_control_table.last_load_date
				and rda.process_d <= sf_control_table.start_load_date))
 
	order by 1

end

GO
