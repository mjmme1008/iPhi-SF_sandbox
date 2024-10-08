USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_org_account_mapping]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_insert_org_account_mapping]
AS
begin

	select org.party_id 
	from tcf.dbo.organization org, sf_control_table
	where sf_control_table.source_object = 'IPHISync'
	and not exists (select 1 from sf_map_org_account map1 where map1.PartyId = org.party_id)
	order by 1

end

GO
