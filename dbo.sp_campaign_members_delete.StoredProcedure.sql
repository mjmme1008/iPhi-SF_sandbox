USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_campaign_members_delete]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_campaign_members_delete]
AS
begin
	--campaigns to delete from the maping tables and salesforce
	select EventAttndId, SfId from sf_map_campaign_members
	where SfId is not null
	and not exists (select 1 	from tcf.dbo.event e, tcf.dbo.event_attendee ea, sf_map_contact 
								where e.event_id = ea.event_id
								and e.event_nm not like 'E-%' 
								and ea.party_id = sf_map_contact.PartyId
								and ea.event_attnd_id = sf_map_campaign_members.EventAttndId)

end
GO
