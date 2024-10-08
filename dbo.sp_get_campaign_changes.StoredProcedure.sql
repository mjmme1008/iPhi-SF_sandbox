USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_campaign_changes]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[sp_get_campaign_changes]
AS
begin

	select 
	e.event_id as ExtSysId__c,
	substring(e.event_nm,1,80) as Name,
	coalesce((select sfid from sf_map_user where sf_map_user.PartyId = coalesce(e.staff_id,userid)),'0054P000009tKZEQA2') as OwnerId,
	'Event' as RecordTypeId,
	substring(coalesce(e.event_desc,''),1,5000) + char(10)  + substring(coalesce(e.event_note,''),1,5000) + char(10) + 'Target Audience: ' + e.target_aud as Description,
	'Event' as Type,
	CASE WHEN (e.end_d is not null AND e.end_d <= CURRENT_TIMESTAMP) OR e.start_d <= CURRENT_TIMESTAMP THEN 'Completed' ELSE 'In Progress' END as Status,
	cast(e.start_d as date) as StartDate, 
	cast(e.end_d as date) as EndDate,
	'Upsert Campaigns' as sf_object
	from tcf.dbo.event e,
	sf_map_campaigns,
	sf_control_table
	where e.event_nm not like 'E-%'
	and e.event_id = sf_map_campaigns.EventId
	and dbo.Fn_stampdatetime(e.stamp) >= sf_control_table.last_load_date
	and dbo.Fn_stampdatetime(e.stamp) <= sf_control_table.start_load_date
	and sf_control_table.source_object = 'IPHISync'
	order by 1

end

GO
