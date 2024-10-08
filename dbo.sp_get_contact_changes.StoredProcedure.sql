SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[sp_get_contact_changes]
AS
begin

	select ind.party_id as ExtSysId__c,
	ind.first_nm as FirstName,
	CASE WHEN coalesce(ltrim(rtrim(ind.last_nm)),'') = '' THEN 'NoLastName' ELSE ltrim(rtrim(ind.last_nm)) END as LastName,
	ind.middle_nm as MiddleName,
	--ind.TitleCode,
	ind.title as Salutation,
	ind.Suffix as Suffix,
	(select name from tcf.dbo.marital_c m where ind.marital_c = m.code) as MaritalStatus__c,
	(select name from tcf.dbo.occ_c o where ind.occ_c = o.code) as Occupation__c,
	null as EstimatedIncome__c,
	--ind.income_q as EstimatedIncome__c,
	null as Wealth__c,
	--(select name from tcf.dbo.wealth_c w where ind.wealth_c = w.code) as Wealth__c,
	(select name from tcf.dbo.influence_c i where ind.influence_c = i.code) as Rank__c,
	null as NetWorth__c,
	--ind.networth_a as NetWorth__c,
	(select name from tcf.dbo.ethnic_c e where ind.ethnic_c = e.code) as Ethnicity__c,
	(select name from tcf.dbo.party_status_c ps where party.party_status_c = ps.code) as Status__c,
	null as PortalLoginId__c,
	--party.loginid as PortalLoginId__c,
	(select name from tcf.dbo.salut_rule_c s where party.salut_rule_c = s.code) as PreferredSalutation__c,
	(select name from tcf.dbo.referral_c r where party.referral_c = r.code) as ReferralSource__c,
	(select SfId from sf_map_org_account where PartyId = party.referrer_id) as ReferringAccount__c,
	(select SfId from sf_map_contact where PartyId = party.referrer_id) as ReferringContact__c,
	CASE WHEN party.f1099_f = 'Y' THEN 'true' ELSE 'false' END as Create1099__c,
	(select SfId from sf_map_org_account where PartyId = party.sec_referrer_id) as SecReferringAccount__c,
	(select SfId from sf_map_contact where PartyId = party.sec_referrer_id) as SecReferringContact__c,
	CASE WHEN party.receipts_option_c = 1 THEN 'Email' ELSE CASE WHEN party.receipts_option_c = 2 THEN 'Letter' ELSE 'No Receipt' END END as ReceiptOption__c,
	substring((Select top 1 c.comms_string FROM tcf.dbo.comms c WHERE c.comms_typ_c = '15' and c.primary_f = 1 and party.party_id = c.party_id order by c.stamp desc),1,40) as AssistantPhone,
	substring((Select top 1 c.comms_string FROM tcf.dbo.comms c WHERE c.comms_typ_c = '6' and c.primary_f = 1 and party.party_id = c.party_id order by c.stamp desc),1,40) as AssistantEmail,    --need API field for email
	substring((Select top 1 c.comms_comment FROM tcf.dbo.comms c WHERE c.comms_typ_c in ('15','6') and c.primary_f = 1 and party.party_id = c.party_id order by c.comms_typ_c desc),1,40) as AssistantName,    --need API field for email
	substring((Select top 1 c.comms_string FROM tcf.dbo.comms c WHERE c.comms_typ_c = '2' and c.primary_f = 1 and party.party_id = c.party_id order by c.stamp desc),1,40) as npe01__WorkPhone__c,
	--FimsC.WorkExt,
	substring((Select top 1 c.comms_string FROM tcf.dbo.comms c WHERE c.comms_typ_c = '4' and c.primary_f = 1 and party.party_id = c.party_id order by c.stamp desc),1,40) as HomePhone,
	--FimsC.Fax,
	substring((Select top 1 c.comms_string FROM tcf.dbo.comms c WHERE c.comms_typ_c = '5' and c.primary_f = 1 and party.party_id = c.party_id order by c.stamp desc),1,40) as MobilePhone,
	substring((Select top 1 c.comms_string FROM tcf.dbo.comms c WHERE c.comms_typ_c in ('3','11','31') and c.primary_f = 1 and party.party_id = c.party_id order by c.stamp desc),1,40) as OtherPhone,
	party.nickname as Nickname__c,
	dbo.dbf_format_email ((Select top 1 c.comms_string FROM tcf.dbo.comms c WHERE c.comms_typ_c = '30' and c.primary_f = 1 and party.party_id = c.party_id order by c.stamp desc)) as npe01__HomeEmail__c,
	dbo.dbf_format_email ((Select top 1 c.comms_string FROM tcf.dbo.comms c WHERE c.comms_typ_c = '17' and c.primary_f = 1 and party.party_id = c.party_id order by c.stamp desc)) as npe01__WorkEmail__c,
	dbo.dbf_format_email ((Select top 1 c.comms_string FROM tcf.dbo.comms c WHERE c.comms_typ_c = '13' and c.primary_f = 1 and party.party_id = c.party_id order by c.stamp desc)) as npe01__AlternateEmail__c,
	CASE WHEN ind.gender_f = 'M' THEN 'Male' ELSE CASE WHEN ind.gender_f = 'F' THEN 'Female' ELSE CASE WHEN ind.gender_f = 'O' THEN 'Other' ELSE 'Unknown' END END END as Gender__c,
	coalesce((select sfid from sf_map_user where partyid = (select ddg.officer_party_id from tcf.dbo.ddg as ddg where ddg.party_id = party.party_id)),'0054P000009tKZEQA2') as OwnerId,	--FimsP.Fax,
	party.memo as Description,
	null as Birthdate,
	--cast(ind.birth_d as date) as Birthdate,
	CASE WHEN party_status_c = 5 THEN 'True' ELSE 'False' END as npsp__Deceased__c,
	cast(ind.death_d as date) as DateDeceased__c,
	CASE WHEN party.mrkt_mail_f = 1 THEN 0 ELSE 1 END as npsp__Do_Not_Contact__c,
	CASE WHEN party.mrkt_mail_f = 1 THEN 0 ELSE 1 END as DoNotCall,
	CASE WHEN party.anonymous_contributor_f = 'Y' THEN 'true' ELSE 'false' END as DonationsAnonymous__c,
	CASE WHEN len((Select top 1 c.comms_string FROM tcf.dbo.comms c WHERE c.comms_typ_c = '4' and c.primary_f = 1 and party.party_id = c.party_id order by c.stamp desc)) > 0 THEN 'Home'
		ELSE CASE WHEN len((Select top 1 c.comms_string FROM tcf.dbo.comms c WHERE c.comms_typ_c = '2' and c.primary_f = 1 and party.party_id = c.party_id order by c.stamp desc)) > 0 THEN 'Work'
		ELSE CASE WHEN len((Select top 1 c.comms_string FROM tcf.dbo.comms c WHERE c.comms_typ_c = '5' and c.primary_f = 1 and party.party_id = c.party_id order by c.stamp desc)) > 0 THEN 'Mobile'
		ELSE CASE WHEN len((Select top 1 c.comms_string FROM tcf.dbo.comms c WHERE c.comms_typ_c in ('3','11','31') and c.primary_f = 1 and party.party_id = c.party_id order by c.stamp desc)) > 0 THEN 'Other'
		END END END END as npe01__PreferredPhone__c, --Need to determine how to populate this.
	CASE WHEN len((Select top 1 c.comms_string FROM tcf.dbo.comms c WHERE c.comms_typ_c = '30' and c.primary_f = 1 and party.party_id = c.party_id order by c.stamp desc)) > 0 THEN 'Personal' 
		ELSE CASE WHEN len((Select top 1 c.comms_string FROM tcf.dbo.comms c WHERE c.comms_typ_c = '17' and c.primary_f = 1 and party.party_id = c.party_id order by c.stamp desc)) > 0 THEN 'Work' 
			ELSE CASE WHEN len((Select top 1 c.comms_string FROM tcf.dbo.comms c WHERE c.comms_typ_c = '13' and c.primary_f = 1 and party.party_id = c.party_id order by c.stamp desc)) > 0 THEN 'Alternate'
--11/13/20: in case email was deleted
			ELSE NULL END END END as npe01__Preferred_Email__c,
	CASE WHEN party_status_c in (0,1,3) THEN 'true' ELSE 'false' END as Active, 
	--FimsC.solname as fdnp_crm__Solicitor__c, 
	--FimsC.StaffName as fdnp_crm__StaffCode__c,
	--FimsC.dondescr as fdnp_crm__DonorClass__c,
	--FimsC.soudescr as fdnp_crm__Source__c,
	sf_map_contact.SfId,
	sf_map_hh_account.SfId as AccountId,
	'Contact Upsert' as sf_object
	from tcf.dbo.individual ind, 
	sf_control_table,
	sf_map_contact, 
	sf_map_hh_account,
	tcf.dbo.party party
	left outer join (select max(dbo.fn_stampdatetime(tcf.dbo.comms.stamp)) as stamp, 
						tcf.dbo.comms.party_id 
						from tcf.dbo.comms
						group by tcf.dbo.comms.party_id  ) as derived_comms on derived_comms.party_id = party.party_id
	where party.party_id = ind.party_id
	and ((dbo.fn_stampdatetime(party.stamp) >= sf_control_table.last_load_date
	and dbo.fn_stampdatetime(party.stamp) <= sf_control_table.start_load_date)
	or (dbo.fn_stampdatetime(ind.stamp) >= sf_control_table.last_load_date
	and dbo.fn_stampdatetime(ind.stamp) <= sf_control_table.start_load_date)
	or (derived_comms.stamp >= sf_control_table.last_load_date
	and derived_comms.stamp <= sf_control_table.start_load_date)
	OR exists (select 1 from tcf.dbo.Remove_dups_audit rda 
				where rda.party_id_leave = party.party_id
				and rda.process_d >= sf_control_table.last_load_date
				and rda.process_d <= sf_control_table.start_load_date)
	OR exists (select 1 from tcf.dbo.ddg 
				where ddg.party_id = party.party_id
				and dbo.fn_stampdatetime(ddg.stamp) >= sf_control_table.last_load_date
				and dbo.fn_stampdatetime(ddg.stamp) <= sf_control_table.start_load_date))
	and ind.party_id = sf_map_contact.PartyId
	and sf_map_hh_account.PartyId = sf_map_contact.PartyId

	order by 1

end
GO
