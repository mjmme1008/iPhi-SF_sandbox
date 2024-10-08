USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_campaign_mapping]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_insert_campaign_mapping]
AS
begin

	select e.event_id
	from tcf.dbo.event e 
	where e.event_nm not like 'E-%'
	and not exists (select 1 from sf_map_campaigns map1 where map1.EventId = e.event_id )
	order by 1

end

GO
