USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_grant_attributes]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_get_grant_attributes]
AS
begin

	select 
	'FOI' + cast(g.grantee_id as varchar(15)) as ExtSysId__c,
	(select sfid from sf_map_grants where sf_map_grants.Id = g.grantee_id) as grant__c, 
	'Field of Interest' as category__c, 
	coalesce((select it3.name from tcf.dbo.ifield_tree_c it, 
									tcf.dbo.ifield_tree_c it2, 
									tcf.dbo.ifield_tree_c it3 
							where it.code = g.ifield_c 
							and it.parent_id = it2.code
							and it2.parent_id = it3.code),				
	coalesce((select it2.name from tcf.dbo.ifield_tree_c it, 
									tcf.dbo.ifield_tree_c it2 
							where it.code = g.ifield_c 
							and it.parent_id = it2.code),
	(select it.name from tcf.dbo.ifield_tree_c it
					where it.code = g.ifield_c )))	as Type__c,

	CASE WHEN (select it3.name from tcf.dbo.ifield_tree_c it, 
									tcf.dbo.ifield_tree_c it2, 
									tcf.dbo.ifield_tree_c it3 
							where it.code = g.ifield_c 
							and it.parent_id = it2.code
							and it2.parent_id = it3.code) is null then

	CASE WHEN (select it2.name from tcf.dbo.ifield_tree_c it, 
									tcf.dbo.ifield_tree_c it2
							where it.code = g.ifield_c 
							and it.parent_id = it2.code) is null THEN null else
																	(select it.name from tcf.dbo.ifield_tree_c it
																					where it.code = g.ifield_c ) end else
																	(select it2.name from tcf.dbo.ifield_tree_c it, 
																							tcf.dbo.ifield_tree_c it2 
																					where it.code = g.ifield_c 
																				and it.parent_id = it2.code) end as Sub_Type__c,


	CASE WHEN (select it3.name from tcf.dbo.ifield_tree_c it, 
									tcf.dbo.ifield_tree_c it2, 
									tcf.dbo.ifield_tree_c it3 
							where it.code = g.ifield_c 
							and it.parent_id = it2.code
							and it2.parent_id = it3.code) is null then null else (select it.name from tcf.dbo.ifield_tree_c it where it.code = g.ifield_c ) end as SubType2__c,
	null as start_date__c, 
	null as end_date__c,
	'true' Default__c,
	'Upsert grant_attribute__c FOI' as sf_object
	from tcf.dbo.grantee g,
	sf_map_grant_attributes
	where g.ifield_c is not null
	and 'FOI' + cast(g.grantee_id as varchar(15)) = sf_map_grant_attributes.Id
	--and dbo.Fn_stampdatetime(pi.stamp) >= sf_control_table.last_load_date
	--and dbo.Fn_stampdatetime(pi.stamp) <= sf_control_table.start_load_date
	order by 1


end

GO
