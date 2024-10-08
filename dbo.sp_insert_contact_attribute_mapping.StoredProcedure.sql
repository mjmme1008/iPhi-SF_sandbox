USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_contact_attribute_mapping]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_insert_contact_attribute_mapping]
AS
begin

	select cast(pi.id as varchar(20)) as id 
	from tcf.dbo.party_identifier pi,
	tcf.dbo.spcl_identifier si,
	tcf.dbo.party p,
	tcf.dbo.individual i
	where pi.spcl_identifier_id = si.spcl_identifier_id 
	and p.party_id = pi.party_id
	and p.party_id = i.party_id
	and not exists (select 1 from sf_map_contact_attributes map1 where map1.Id = cast(pi.id as varchar(20)) )

	UNION

	select
	'FOI' + cast(pi.id as varchar(15)) as id
	from tcf.dbo.party_ifield pi,
	tcf.dbo.party p,
	tcf.dbo.individual i
	where p.party_id = pi.party_id
	and p.party_id = i.party_id
	and not exists (select 1 from sf_map_contact_attributes map1 where map1.Id = 'FOI' + cast(pi.id as varchar(20)) )
	order by 1

end

GO
