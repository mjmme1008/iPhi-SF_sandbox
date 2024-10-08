USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_campaigns_delete]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_campaigns_delete]
AS
begin
	--campaigns to delete from the maping tables and salesforce
	select EventId, SfId from sf_map_campaigns
	where SfId is not null
	and not exists (select 1 from tcf.dbo.event e 
								where e.event_nm not like 'E-%'
								and e.event_id = sf_map_campaigns.EventId)

end
GO
