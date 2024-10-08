USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_hh_primary_contact]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[sp_get_hh_primary_contact]
AS
begin

	SELECT sf_map_hh_account.HhId as ExtSysId__c,
	(SELECT SfId from sf_map_contact where sf_map_contact.PartyId = hh_staging.PartyId1) as npe01__One2OneContact__c,
	sf_map_hh_account.SfId,
	'HH PC Update' as sf_object
	from hh_staging,
	sf_control_table,
	sf_map_hh_account,
	tcf.dbo.party party
	where hh_staging.PartyId1 = sf_map_hh_account.PartyId
	and sf_map_hh_account.PartyId = party.party_id
	and ((dbo.fn_stampdatetime(party.stamp) >= sf_control_table.last_load_date
	and dbo.fn_stampdatetime(party.stamp) <= sf_control_table.start_load_date)
	OR exists (select 1 from tcf.dbo.Remove_dups_audit rda 
				where rda.party_id_leave = party.party_id
				and rda.process_d >= sf_control_table.last_load_date
				and rda.process_d <= sf_control_table.start_load_date))		
	and sf_control_table.source_object = 'IPHISync'
	order by 1

end

GO
