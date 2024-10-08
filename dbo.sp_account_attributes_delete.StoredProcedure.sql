USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_account_attributes_delete]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_account_attributes_delete]
AS
begin
	--account attributes to delete from the maping tables and salesforce
	select Id, SfId from sf_map_account_attributes
	where SfId is not null
	and not exists (select 1 	from tcf.dbo.party_identifier pi,
								tcf.dbo.spcl_identifier si,
								tcf.dbo.party p,
								tcf.dbo.organization o
								where pi.spcl_identifier_id = si.spcl_identifier_id 
								and p.party_id = pi.party_id
								and p.party_id = o.party_id
								and cast(pi.id as varchar(20)) = sf_map_account_attributes.Id)
	and not exists (select 1 from tcf.dbo.party_ifield pi,
							tcf.dbo.party p,
							tcf.dbo.organization o
							where p.party_id = pi.party_id
							and p.party_id = o.party_id
							and 'FOI' + cast(pi.id as varchar(15)) = sf_map_account_attributes.Id)
	order by 1

end
GO
