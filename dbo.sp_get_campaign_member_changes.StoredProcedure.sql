USE [SFdb_sandbox2]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_campaign_member_changes]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter procedure [dbo].[sp_get_campaign_member_changes]
AS
begin

	select 
	ea.event_attnd_id as ExtSysId__c,
	ea.event_id as CampaignId,
	sf_map_contact.SfId as ContactId,
	ea.comment as Description,
	'false' as IsHouseholdMailing__c,
	--CASE WHEN ea.attendee_f = 1 OR ea.registrant_f = 1 OR ea.paid_f = 1 OR ea.responder_f = 1 THEN 'true' ELSE 'false' END  as HasResponded,
	--CASE WHEN ea.responder_f = 1 THEN 'Responded' ELSE 'Confirmed' END as Status,
	'false' as HasResponded,
	'Added to Invitation List' as Status,
	cast(e.start_d as date) as StartDate, 
	cast(e.end_d as date) as EndDate,
	'Upsert Campaign Members' as sf_object
	from tcf.dbo.event e, tcf.dbo.event_attendee ea, sf_map_contact, sf_map_campaign_members
	where e.event_id = ea.event_id
	and e.event_nm not like 'E-%' 
	and ea.party_id = sf_map_contact.PartyId
	and sf_map_contact.SfId is not null
	and ea.event_attnd_id = sf_map_campaign_members.EventAttndId
	--ITS #3333
	and ea.party_id is not null
	and sf_map_campaign_members.SfId is null
	--and sf_map_contact.sfid='00v4P000024TxxfQAC'
	order by 1

end
GO

--USE [SFdb_sandbox2]	--prod
--GO
--/****** Object:  StoredProcedure [dbo].[sp_get_campaign_member_changes]    Script Date: 1/19/2024 9:35:38 AM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--ALTER procedure [dbo].[sp_get_campaign_member_changes]
--AS
--begin

--	select 
--	ea.event_attnd_id as ExtSysId__c,
--	ea.event_id as CampaignId,
--	sf_map_contact.SfId as ContactId,
--	ea.comment as Description,
--	'false' as IsHouseholdMailing__c,
--	--CASE WHEN ea.attendee_f = 1 OR ea.registrant_f = 1 OR ea.paid_f = 1 OR ea.responder_f = 1 THEN 'true' ELSE 'false' END  as HasResponded,
--	CASE WHEN ea.responder_f = 1 THEN 'Responded' ELSE 'Confirmed' END as Status,
--	--'Added to Invitation List' as Status,
--	'false' as HasResponded,
--	cast(e.start_d as date) as StartDate, 
--	cast(e.end_d as date) as EndDate,
--	'Upsert Campaign Members' as sf_object
--	from tcf.dbo.event e, tcf.dbo.event_attendee ea, sf_map_contact, sf_map_campaign_members
--	where e.event_id = ea.event_id
--	and e.event_nm not like 'E-%' 
--	and ea.party_id = sf_map_contact.PartyId
--	and sf_map_contact.SfId is not null
--	and ea.event_attnd_id = sf_map_campaign_members.EventAttndId
--	--ITS #3333
--	and ea.party_id is not null
--	and sf_map_campaign_members.SfId is null
--	--and sf_map_contact.sfid='00v4P000024TxxfQAC'
--	and ea.event_id <> 432308
--	order by 1

--end