SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[sp_get_contact_log_changes]
AS
begin

	select
    a1.task_source_c,
    a1.task_id as ExtSysId__c,
	coalesce(case when a1.userid = 'jaguar1' OR a1.userid = '6942' then '0054P000009tKZEQA2' else 
        (select sfid from sf_map_user where sf_map_user.PartyId = a1.userid) end ,'0054P000009tKZEQA2') as OwnerId,
	coalesce((select sfid from sf_map_user where sf_map_user.PartyId =  a1.creator_id),'0054P000009tKZEQA2') as CreatedById,
	cast(a1.create_d as date) as CreatedDate,
	a1.task_nm as Subject,
	tt.name as Type,
	a1.task_note as Description,
	cast(coalesce(CASE WHEN (select s.name from tcf.dbo.task_status_c s 
        where s.code = a1.task_status_c) = 'Completed' THEN a1.completed_on 
        ELSE a1.task_d END,a1.contact_d) as date) as ActivityDate,
	(select p.name from tcf.dbo.task_priority_c p where p.code = a1.task_priority_c) as Priority,
	case when tt.entity = 'Contact' THEN 'Completed' ELSE       --automatically set comments to completed
        (select s.name from tcf.dbo.task_status_c s where s.code = a1.task_status_c) END as Status,
	CASE WHEN a1.task_remind_f = 'Y' THEN 'true' ELSE 'false' END as IsReminderSet,
	(select sfid from sf_map_contact where sf_map_contact.PartyId = s1.party_id) as WhoId, --contact
 	case when a1.task_source_c =  2 then (select sfid from sf_map_org_account where sf_map_org_account.PartyId = a1.acct_id)        --Account, Opportunity
        else case when a1.task_source_c = 4 then (select sfid from sf_map_fund where sf_map_Fund.AcctId = a1.acct_id) 
        else case when a1.task_source_c = 8 then (select sfid from sf_map_gifts where tranId = a1.acct_id) end end end as WhatId,
	s7.grantee_id as RelatedToGrant__c, 
	(select sfid from sf_map_fund where sf_map_fund.AcctId = s4.acct_id) as RelatedToFund__c,
	'Contact Log Upsert' as sf_object
	from sf_control_table,
	sf_map_contact_log,
	tcf.dbo.acct_task 		a1 left outer join 
	tcf.dbo.task_type_c tt on a1.task_type_c = tt.code
	left outer join tcf.dbo.party		    s1 on a1.acct_id=s1.party_id			--individual (contact)
	left outer join tcf.dbo.organization	s2 on a1.acct_id=s2.party_id			--org (account)
--	left outer join tcf.dbo.application	s3 on a1.acct_id=s3.party_id			--application (grant)
	left outer join tcf.dbo.account	        s4 on a1.acct_id=s4.acct_id				--account (fund)
	left outer join tcf.dbo.grantee	        s7 on a1.acct_id=s7.grantee_id			--distribution (grant)
	left outer join tcf.dbo.contribution	s8 on a1.acct_id=s8.contrib_id			--contribution (opportunity)
    left outer join tcf.dbo.ddc_header      s11 on a1.acct_id=s11.id                  --ddc (opportunity)
--    left outer join tcf.dbo.trans_action      s12 on a1.tran_id=s12.tran_id                  --I/A grant (grant to Org? opportunity to fund?) 
    where 
	sf_control_table.source_object = 'IPHISync'
--    and a1.task_source_c in (11)
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
