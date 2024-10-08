USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_org_account_changes]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[sp_get_org_account_changes]
AS
begin
	
	SELECT
	Org.party_id as ExtSysId__c,
	CASE WHEN Org.legal_nm = '' THEN 'Blank Name' ELSE Org.legal_nm END as Name,
	'Organization' as RecordTypeId,
	(SELECT SfId from sf_map_contact where sf_map_contact.PartyId = sf_map_org_account.PcPartyId) as npe01__One2OneContact__c,
	(SELECT name from tcf.dbo.tax_status_c ts where Org.tax_status_c = ts.code) as TaxStatus__c,
	cast(Org.incorp_d as date) as DateInc__c,
	cast(party.grant_approve_start_d as date) as GranteeApprovedStartDate__c,
	cast(party.grant_approve_end_d as date) as GranteeApprovedEndDate__c,
	--party.grantee_status as GranteeStatus__c, Need a case statement for codes
	Org.annual_budget as Budget__c,
	cast(Org.tax_status_d as date) as TaxStatusDate__c,
	(SELECT name from tcf.dbo.party_status_c ps where ps.code = Party.party_status_c) as Active__c,
	-- #3373 - data value too large max length=15
	left( Party.tax_id, 15) as TaxId__c,
	(SELECT sfid from sf_map_org_account where sf_map_org_account.PartyId = Party.referrer_id) as ReferringAccount__c,
	(SELECT sfid from sf_map_contact where sf_map_contact.PartyId = Party.referrer_id) as ReferringContact__c,
	CASE WHEN Party.f1099_f = 'Y' THEN 'true' ELSE 'false' END as Create1099__c,
	Org.fiscal_year_c as FiscalYear__c,
	Party.memo as Description,
	CASE WHEN Party.show_on_web_f = 'Y' THEN 'true' ELSE 'false' END as ShowOnDonorPortal__c,
	CASE WHEN Party.exclude_f = 'Y' THEN 'true' ELSE 'false' END as ExcludeFromAnnualReport__c,
	(SELECT gs.name from tcf.dbo.grantee_status_c gs where Party.grantee_status = gs.code) as GranteeStatus__c,
	CASE WHEN Party.mrkt_mail_f = 1 THEN 'true' ELSE 'false' END as SendMarketingMail__c,
	CASE WHEN Party.receipts_option_c = 0 THEN 'No Receipt' ELSE CASE WHEN Party.receipts_option_c = 1 THEN 'Email' ELSE 'Letter' END END as ReceiptOption__c,
	CASE WHEN Party.anonymous_contributor_f = 'Y' THEN 'true' ELSE 'false' END as Anonymous__c,
	--FimsP.AnnualName as CombinedName__c,
	--FimsP.Salutation as CombinedSalution__c,
		substring((Select top 1 c.comms_string FROM tcf.dbo.comms c WHERE c.comms_typ_c = '18' and party.party_id = c.party_id order by c.stamp desc),1,40) as Website, --FimsP.website,
	coalesce((select sfid from sf_map_user where partyid = (select ddg.officer_party_id from tcf.dbo.ddg as ddg where ddg.party_id = Org.party_id)),'0054P000009tKZEQA2') as OwnerId,
	substring((Select top 1 c.comms_string FROM tcf.dbo.comms c WHERE c.comms_typ_c = '9' and party.party_id = c.party_id order by c.stamp desc),1,40) as Fax, --FimsP.Fax,
	substring((Select top 1 c.comms_string FROM tcf.dbo.comms c WHERE c.comms_typ_c = '1' and party.party_id = c.party_id order by c.stamp desc),1,40) as Phone,--FimsP.WorkPhone,
	--substring(FimsP.WorkExt,1,10) as fdnp_crm__PhoneExt__c,
	'' as npo02__SYSTEM_CUSTOM_NAMING__c,
	sf_map_org_account.SfId,
	'Org Account Upsert' as sf_object
	from tcf.dbo.organization Org,
	tcf.dbo.party Party

	left outer join (select max(dbo.fn_stampdatetime(tcf.dbo.comms.stamp)) as stamp, 
						tcf.dbo.comms.party_id 
						from tcf.dbo.comms
						group by tcf.dbo.comms.party_id  ) as derived_comms on derived_comms.party_id = party.party_id,

	--left outer join tcf.dbo.Remove_dups_audit rda on rda.party_id_leave = party.party_id,
	sf_control_table,
	sf_map_org_account
	where Org.party_id = Party.party_id
	--ITS #2906 pesky period (.) in organization.stamp for party -1
	and ((dbo.fn_stampdatetime(replace(Org.stamp,'.','')) >= sf_control_table.last_load_date	
	and dbo.fn_stampdatetime(replace(Org.stamp,'.','')) <= sf_control_table.start_load_date)
	or  (dbo.fn_stampdatetime(Party.stamp) >= sf_control_table.last_load_date	
	and dbo.fn_stampdatetime(Party.stamp) <= sf_control_table.start_load_date)
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
	--or (rda.process_d >= sf_control_table.last_load_date
	--and rda.process_d <= sf_control_table.start_load_date))
	and sf_control_table.source_object = 'IPHISync' 
	and Org.party_id = sf_map_org_account.PartyId 


end

GO
