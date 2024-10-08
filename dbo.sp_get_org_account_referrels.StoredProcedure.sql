USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_org_account_referrels]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[sp_get_org_account_referrels]
AS
begin

	SELECT Org.party_id as ExtSysId__c,
	(SELECT SfId from sf_map_contact where sf_map_contact.PartyId = sf_map_org_account.PcPartyId) as npe01__One2OneContact__c,
	(SELECT sfid from sf_map_org_account where sf_map_org_account.PartyId = Party.referrer_id) as ReferringAccount__c,
	(SELECT sfid from sf_map_contact where sf_map_contact.PartyId = Party.referrer_id) as ReferringContact__c,
	sf_map_org_account.SfId,
	'Org Account Ref Update' as sf_object
	from tcf.dbo.organization Org,
	tcf.dbo.party Party,
	sf_control_table,
	sf_map_org_account
	where Org.party_id = Party.party_id
	and ((dbo.fn_stampdatetime(Org.stamp) >= sf_control_table.last_load_date	
	and dbo.fn_stampdatetime(Org.stamp) <= sf_control_table.start_load_date)
	or (dbo.fn_stampdatetime(Party.stamp) >= sf_control_table.last_load_date	
	and dbo.fn_stampdatetime(Party.stamp) <= sf_control_table.start_load_date)
	OR exists (select 1 from tcf.dbo.Remove_dups_audit rda 
				where rda.party_id_leave = party.party_id
				and rda.process_d >= sf_control_table.last_load_date
				and rda.process_d <= sf_control_table.start_load_date))	
	and sf_control_table.source_object = 'IPHISync'
	and Org.party_id = sf_map_org_account.PartyId 
	and Party.referrer_id is not null
	order by 1

end

GO
