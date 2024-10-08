USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_addresses_to_delete]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_addresses_to_delete]
AS
begin
	--addresses to delete from the maping tables and salesforce
	select AddressId, SfId from sf_map_Address
	where SfId is not null
	and not exists (select 1 from tcf.dbo.address addr
								where addr.addr_id = sf_map_Address.AddressId)

end
GO
