USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_grant_attribute_mapping]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_insert_grant_attribute_mapping]
AS
begin

	select
	'FOI' + cast(g.grantee_id as varchar(15)) as id
	from tcf.dbo.grantee g
	where g.ifield_c is not null
	--and not exists (select 1 from sf_map_fund_attributes map1 where map1.Id = 'FOI' + cast(g.grantee_id as varchar(20)) )
	and not exists (select 1 from sf_map_grant_attributes map1 where map1.Id = 'FOI' + cast(g.grantee_id as varchar(20)) )
	order by 1

end
GO
