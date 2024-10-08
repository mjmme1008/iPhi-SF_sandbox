USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_contact_attributes_delete]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[sp_contact_attributes_delete]
AS
begin
	--contact attributes to delete from the maping tables and salesforce
	select Id, SfId from sf_map_contact_attributes
	where SfId is not null
	and not exists (select 1 from tcf.dbo.party_identifier pi,
								tcf.dbo.spcl_identifier si,
								tcf.dbo.party p,
								tcf.dbo.individual i
								where pi.spcl_identifier_id = si.spcl_identifier_id 
								and p.party_id = pi.party_id
								and p.party_id = i.party_id
									and isnull(pi.end_d,getdate()) >= getdate()
								and cast(pi.id as varchar(20)) = sf_map_contact_attributes.Id)

	and not exists (select 1 from tcf.dbo.party_ifield pi,
								tcf.dbo.party p,
								tcf.dbo.individual i
								where p.party_id = pi.party_id
								and p.party_id = i.party_id
								and 'FOI' + cast(pi.id as varchar(20)) = sf_map_contact_attributes.Id)
	order by 1

end

GO
