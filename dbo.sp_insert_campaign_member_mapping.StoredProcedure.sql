USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_campaign_member_mapping]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_insert_campaign_member_mapping]
AS
begin

	select ea.event_attnd_id
	from tcf.dbo.event e, tcf.dbo.event_attendee ea, sf_map_contact 
	where e.event_id = ea.event_id
	and e.event_nm not like 'E-%' 
	and ea.party_id = sf_map_contact.PartyId
	and not exists (select 1 from sf_map_campaign_members map1 where map1.EventAttndId = ea.event_attnd_id )
	order by 1

end

GO
