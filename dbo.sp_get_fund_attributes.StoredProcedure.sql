SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[sp_get_fund_attributes]
AS
begin

	select 
	'FOI' + cast(pi.id as varchar(15)) as ExtSysId__c,
	(select sfid from sf_map_fund where sf_map_fund.AcctId = f.dfund_id) as fund__c, 
	'Field of Interest' as category__c, 
	coalesce((select it3.name from tcf.dbo.ifield_tree_c it, 
									tcf.dbo.ifield_tree_c it2, 
									tcf.dbo.ifield_tree_c it3 
							where it.code = pi.ifield_c 
							and it.parent_id = it2.code
							and it2.parent_id = it3.code),				
	coalesce((select it2.name from tcf.dbo.ifield_tree_c it, 
									tcf.dbo.ifield_tree_c it2 
							where it.code = pi.ifield_c 
							and it.parent_id = it2.code),
	(select it.name from tcf.dbo.ifield_tree_c it
					where it.code = pi.ifield_c )))	as Type__c,

	CASE WHEN (select it3.name from tcf.dbo.ifield_tree_c it, 
									tcf.dbo.ifield_tree_c it2, 
									tcf.dbo.ifield_tree_c it3 
							where it.code = pi.ifield_c 
							and it.parent_id = it2.code
							and it2.parent_id = it3.code) is null then

	CASE WHEN (select it2.name from tcf.dbo.ifield_tree_c it, 
									tcf.dbo.ifield_tree_c it2
							where it.code = pi.ifield_c 
							and it.parent_id = it2.code) is null THEN null else
																	(select it.name from tcf.dbo.ifield_tree_c it
																					where it.code = pi.ifield_c ) end else
																	(select it2.name from tcf.dbo.ifield_tree_c it, 
																							tcf.dbo.ifield_tree_c it2 
																					where it.code = pi.ifield_c 
																				and it.parent_id = it2.code) end as Sub_Type__c,


	CASE WHEN (select it3.name from tcf.dbo.ifield_tree_c it, 
									tcf.dbo.ifield_tree_c it2, 
									tcf.dbo.ifield_tree_c it3 
							where it.code = pi.ifield_c 
							and it.parent_id = it2.code
							and it2.parent_id = it3.code) is null then null else (select it.name from tcf.dbo.ifield_tree_c it where it.code = pi.ifield_c ) end as SubType2__c,
	null as start_date__c, 
	null as end_date__c,
	CASE WHEN pi.default_f = 1 THEN 'true' ELSE 'false' END as Default__c,
	'Upsert fund_attribute__c FOI' as sf_object
	from sf_control_table,
	tcf.dbo.dfund_ifield pi,
	tcf.dbo.account a,
	tcf.dbo.dfund f,
	sf_map_fund_attributes
	where a.acct_id = pi.dfund_id
	and f.dfund_id = a.acct_id
    and a.acct_type_c <> 1      --Not an Account
	and 'FOI' + cast(pi.id as varchar(15)) = sf_map_fund_attributes.Id
	and dbo.fn_stampdatetime(pi.stamp) >= sf_control_table.last_load_date
	and dbo.fn_stampdatetime(pi.stamp) <= sf_control_table.start_load_date

	order by 1


end
GO
