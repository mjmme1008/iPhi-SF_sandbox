USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_contact_log_delete]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_contact_log_delete]
AS
begin
	--tasks to delete from the maping tables and salesforce
	select TaskId, SfId from sf_map_contact_log
	where SfId is not null
	and not exists (select 1 from tcf.dbo.acct_task 		a1
								left outer join tcf.dbo.party		s1 on a1.acct_id=s1.party_id				--individual (contact)
								left outer join tcf.dbo.organization	s2 on a1.acct_id=s2.party_id			--org (account)
								left outer join tcf.dbo.account	s4 on a1.acct_id=s4.acct_id						--account (fund)
								left outer join tcf.dbo.grantee	s7 on a1.acct_id=s7.grantee_id					--distribution (grant)
								left outer join tcf.dbo.contribution	s8 on a1.acct_id=s8.contrib_id			--contribution (gift)
								where coalesce(a1.private_c,'') <> 49
								and a1.task_id = sf_map_contact_log.TaskId)

end
GO
