USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_address_mapping]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_insert_address_mapping]
AS
begin

	select addr.addr_id as AddressId
	from tcf.dbo.address addr, sf_control_table
	where sf_control_table.source_object = 'IPHISync'
	and not exists (select 1 from sf_map_address map1 where map1.AddressId = addr.addr_id)
	order by 1

end


GO
