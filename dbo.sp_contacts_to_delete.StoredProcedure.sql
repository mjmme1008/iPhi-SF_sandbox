USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_contacts_to_delete]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_contacts_to_delete]
AS
begin
	--contacts to delete from the maping tables and salesforce
	select PartyId, SfId from sf_map_contact
	where SfId is not null
	and not exists (select 1 from tcf.dbo.individual ind, 
									tcf.dbo.party party
								where party.party_id = sf_map_contact.PartyId)

end
GO
