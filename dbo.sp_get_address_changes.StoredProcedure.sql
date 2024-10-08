SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[sp_get_address_changes]
AS
begin

	select 
	a.addr_id as ExtSysId__c,
	CASE WHEN (select sf_map_hh_account.partyid from sf_map_hh_account where sf_map_hh_account.partyid = a.party_id) > 0 THEN 'HouseholdAddress' ELSE 'OrganizationAddress' END as RecordTypeId,
	a.street as npsp__MailingStreet__c,
	a.street2 as npsp__MailingStreet2__c,
	a.street3 as MailingStreet3__c,
	a.city as npsp__MaillingCity__c,
	(select rtrim(s.name) + ' - ' + s.description from tcf.dbo.state_c s where a.state_c = s.code) as MailingState__c,
	a.postalcode as npsp__MailingPostalCode__c,
	(select c.name from tcf.dbo.cntry_c c where a.cntry_c = c.code) as MailingCountry__c,
	(select c.name from tcf.dbo.county_c c where a.county_c = c.code) as npsp__County_Name__c,
	cast(a.start_d as date) as npsp__Latest_Start_Date__c,
	cast(a.end_d as date) as npsp__Latest_End_Date__c,
	(select ad.name from tcf.dbo.address_subtype_c ad where a.addr_subtype_c = ad.code) as npsp__address_type__c,
	--coalesce((select sfid from fims_sf_map_user where fims_sf_map_user.userid = FimsA.UserId),(select sfid from fims_sf_map_user where fims_sf_map_user.userid = 'SFNPO')) as OwnerId,
	CASE WHEN a.season_start_mon = 1 AND a.season_end_mon = 12 THEN null ELSE CASE WHEN a.season_start_mon > 0 THEN '1' END END as npsp__Seasonal_Start_Day__c,
	CASE WHEN a.season_start_mon = 1 AND a.season_end_mon = 12 THEN null ELSE a.season_start_mon END as npsp__Seasonal_Start_Month__c,
	CASE WHEN a.season_start_mon = 1 AND a.season_end_mon = 12 THEN null ELSE CASE WHEN a.season_end_mon in (1,3,5,7,8,10,12) THEN '31' ELSE CASE WHEN a.season_end_mon in (4,6,9,11) THEN '30' ELSE CASE WHEN a.season_end_mon = 2 THEN '28' END END END END as npsp__Seasonal_End_Day__c,
	CASE WHEN a.season_start_mon = 1 AND a.season_end_mon = 12 THEN null ELSE a.season_end_mon END as npsp__Seasonal_End_Month__c,
	default_addr_f as npsp__default_Address__c,
	coalesce(sf_map_hh_account.sfid,sf_map_org_account.SfId) as npsp__Household_Account__c,
	sf_map_address.SfId,
	'Address Upsert' as sf_object
	from sf_control_table,
	sf_map_address,
	tcf.dbo.address a
	left outer join sf_map_org_account on a.party_id = sf_map_org_account.partyid
	left outer join sf_map_hh_account on a.party_id = sf_map_hh_account.partyid
	where 
	((dbo.fn_stampdatetime(a.stamp) >= sf_control_table.last_load_date 
	and dbo.fn_stampdatetime(a.stamp) <= sf_control_table.start_load_date)
	OR exists (select 1 from tcf.dbo.Remove_dups_audit rda 
				where rda.party_id_leave = a.party_id
				and rda.process_d >= sf_control_table.last_load_date
				and rda.process_d <= sf_control_table.start_load_date))
	and 
	sf_control_table.source_object = 'IPHISync'
	and a.addr_id = sf_map_address.AddressId
	--and a.party_id=42075
	order by 1

end
GO
