USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_contact_mapping]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_insert_contact_mapping]
AS
begin

	select Ind.party_id
	from tcf.dbo.individual Ind
	--, sf_control_table
	where 
	--convert(datetime,substring(stamp,1,8) + ' ' + substring(stamp,9,2) + ':' + + substring(stamp,11,2) + ':' + substring(stamp,13,2) + ':000') >= sf_control_table.last_load_date
	--and len(stamp) = 14
	--and sf_control_table.source_object = 'IPHISync'
	not exists (select 1 from sf_map_contact map1 where map1.PartyId = Ind.party_id)
	order by 1

end
GO
