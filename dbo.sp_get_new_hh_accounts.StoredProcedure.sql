SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[sp_get_new_hh_accounts]
AS
begin

	SELECT sf_map_hh_account.HhId as ExtSysId__c,
	CASE WHEN coalesce(hh_staging.CombinedName,hh_staging.CombinedId) = '' THEN rtrim(hh_staging.CombinedId) ELSE coalesce(hh_staging.CombinedName,hh_staging.CombinedId) END as Name,
	--'' as Name,
	'HH_Account' as RecordTypeId,
	(SELECT SfId from sf_map_contact where sf_map_contact.PartyId = hh_staging.PartyId1) as npe01__One2OneContact__c,
	hh_staging.CombinedName as CombinedName__c,
	hh_staging.CombinedSalutation as CombinedSalution__c,
	--(SELECT name from tcf.dbo.tax_status_c ts where Org.tax_status_c = ts.code) as TaxStatus__c,
	--Org.incorp_d as DateInc__c,
	--Org.annual_budget as Budget__c,
	--Org.tax_status_d as TaxStatusDate__c,
	'Yes' as Active__c,
	--Party.tax_id as TaxId__c,
	--(SELECT sfid from sf_map_org_account where sf_map_org_account.PartyId = Party.referrer_id) as ReferringAccount__c,
	--(SELECT sfid from sf_map_contact where sf_map_contact.PartyId = Party.referrer_id) as ReferringContact__c,
	--Party.f1099_f as Create1099__c,
	--Party.memo as Description,
	--Party.show_on_web_f as ShowOnDonorPortal__c,
	--Party.exclude_f as ExcludeFromAnnualReport__c,
	--(SELECT gs.name from tcf.dbo.grantee_status_c gs where Party.grantee_status = gs.code) as GranteeStatus__c,
	--Party.mrkt_mail_f as SendMarketingMail__c,
	--CASE WHEN Party.receipts_option_c = 0 THEN 'No Receipt' ELSE CASE WHEN Party.receipts_option_c = 1 THEN 'Email' ELSE 'Letter' END END as ReceiptOption__c,
	--Party.anonymous_contributor_f as Anonymous__c,
	--FimsP.website,
	coalesce((select sfid from sf_map_user where partyid = (select ddg.officer_party_id from tcf.dbo.ddg as ddg where ddg.party_id = hh_staging.PartyId1)),'0054P000009tKZEQA2') as OwnerId,	--FimsP.Fax,
	--FimsP.WorkPhone,
	--substring(FimsP.WorkExt,1,10) as fdnp_crm__PhoneExt__c,
	' ' as npo02__SYSTEM_CUSTOM_NAMING__c,
	sf_map_hh_account.SfId,
	'HH Account Insert' as sf_object
	from hh_staging,
	sf_control_table,
	sf_map_hh_account
	where hh_staging.PartyId1 = sf_map_hh_account.PartyId
	and sf_control_table.source_object = 'IPHISync'
	and sf_map_hh_account.SfId is null
	order by 1

end

GO
