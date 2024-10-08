SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[sp_insert_grant_mapping]
AS
begin

	select cast(g.grantee_id as varchar(20)) as Id
	FROM sf_control_table, 
	tcf.dbo.grantee g
	left outer join tcf.dbo.applicant a on a.applic_id = g.applic_id
	where sf_control_table.source_object = 'IPHISync'
	and not exists (select 1 from sf_map_grants map1 where map1.Id = cast(g.grantee_id as varchar(20)))

	order by 1

end

GO
