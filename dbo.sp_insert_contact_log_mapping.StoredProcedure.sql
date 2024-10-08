SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[sp_insert_contact_log_mapping]
AS
begin

	select a1.task_id 
	from sf_control_table,
	tcf.dbo.acct_task 		a1
	left outer join tcf.dbo.party		s1 on a1.acct_id=s1.party_id				--individual (contact)
	left outer join tcf.dbo.organization	s2 on a1.acct_id=s2.party_id			--org (account)
	left outer join tcf.dbo.account	s4 on a1.acct_id=s4.acct_id						--account (fund)
	left outer join tcf.dbo.grantee	s7 on a1.acct_id=s7.grantee_id					--distribution (grant)
	left outer join tcf.dbo.contribution	s8 on a1.acct_id=s8.contrib_id			--contribution (gift)
	where 
	--coalesce(a1.private_c,'') <> 49	--excluding comments with privacy level
	--and 
	sf_control_table.source_object = 'IPHISync'
	and not exists (select 1 from sf_map_contact_log map1 where map1.TaskId = a1.task_id )
	order by 1

end
GO
