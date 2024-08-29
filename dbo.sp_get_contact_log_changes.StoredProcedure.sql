USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_contact_log_changes]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_get_contact_log_changes]
AS
begin

	select a1.task_id as ExtSysId__c,
	coalesce(case when a1.userid = 'jaguar1' OR a1.userid = '6942' then '0054P000009tKZEQA2' else (select sfid from sf_map_user where sf_map_user.PartyId = a1.userid) end ,'0054P000009tKZEQA2') as OwnerId,
	coalesce((select sfid from sf_map_user where sf_map_user.PartyId =  a1.creator_id),'0054P000009tKZEQA2') as CreatedById,
	cast(a1.create_d as date) as CreatedDate,
	a1.task_nm as Subject,
	(select tt.name from tcf.dbo.task_type_c tt where tt.code = a1.task_type_c) as Type,
	a1.task_note as Description,
	cast(coalesce(CASE WHEN (select s.name from tcf.dbo.task_status_c s where s.code = a1.task_status_c) = 'Completed' THEN a1.completed_on ELSE a1.task_d END,a1.contact_d) as date) as ActivityDate,
	(select p.name from tcf.dbo.task_priority_c p where p.code = a1.task_priority_c) as Priority,
	(select s.name from tcf.dbo.task_status_c s where s.code = a1.task_status_c) as Status,
	CASE WHEN a1.task_remind_f = 'Y' THEN 'true' ELSE 'false' END as IsReminderSet,
	(select sfid from sf_map_contact where sf_map_contact.PartyId = s1.party_id) as WhoId, --contact
	coalesce(s2.party_id,(select ta.tran_id from tcf.dbo.trans_action ta where ta.parent_obj_id = s8.contrib_id) ) as WhatId, --Account, Opportunity
	(select sfid from sf_map_fund where sf_map_fund.AcctId = s4.acct_id) as RelatedToFund__c,
	s7.grantee_id as RelatedToGrant__c,
	'Contact Log Upsert' as sf_object
	from sf_control_table,
	sf_map_contact_log,
	tcf.dbo.acct_task 		a1
	left outer join tcf.dbo.party		s1 on a1.acct_id=s1.party_id				--individual (contact)
	left outer join tcf.dbo.organization	s2 on a1.acct_id=s2.party_id			--org (account)
	left outer join tcf.dbo.account	s4 on a1.acct_id=s4.acct_id						--account (fund)
	left outer join tcf.dbo.grantee	s7 on a1.acct_id=s7.grantee_id					--distribution (grant)
	left outer join tcf.dbo.contribution	s8 on a1.acct_id=s8.contrib_id			--contribution (gift)
	where coalesce(a1.private_c,'') <> 49
	and sf_control_table.source_object = 'IPHISync'
	and a1.task_id = sf_map_contact_log.TaskId
	and ((dbo.Fn_stampdatetime(a1.stamp) >= sf_control_table.last_load_date
	and dbo.Fn_stampdatetime(a1.stamp) <= sf_control_table.start_load_date)
	OR exists (select 1 from tcf.dbo.Remove_dups_audit rda 
				where rda.party_id_leave = s1.party_id
				and rda.process_d >= sf_control_table.last_load_date
				and rda.process_d <= sf_control_table.start_load_date))
	order by 1

end

GO
