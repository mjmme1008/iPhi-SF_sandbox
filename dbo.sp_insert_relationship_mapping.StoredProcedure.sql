USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_relationship_mapping]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_insert_relationship_mapping]
AS
begin

	select p.rp_id
	from
	tcf.dbo.individual i,
	tcf.dbo.individual i2,
	tcf.dbo.party_relation p
	inner join tcf.dbo.relation_type_c r1 on p.rel_typ_c = r1.code
	where i.party_id = p.parent_id
	and i2.party_id = p.child_id
	and not exists (select 1 from sf_map_relationships map1 where map1.RpId = p.rp_id )
	order by 1

end

GO
