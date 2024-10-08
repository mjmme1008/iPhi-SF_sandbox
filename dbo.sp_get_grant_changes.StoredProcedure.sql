SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[sp_get_grant_changes]
AS
begin

    select 
    cast(g.grantee_id as varchar(20)) as ExtSysId__c, 	
	(select SfId from sf_map_org_account where sf_map_org_account.PartyId = coalesce(g.applicant_id,t.party_id,g.party_id)) as OrganizationAccount__c,
	(select sname from tcf..party where party_id = coalesce(g.applicant_id,t.party_id,g.party_id)) as GranteeName__c,
	addr.street as GranteeAddress__c,
	coalesce(g.approve_amt,(select sum(ct.pmt_amount) from tcf..cash_trans ct inner join tcf..trans_action ta on ct.tran_id=ta.tran_id where ta.parent_obj_id=g.grantee_id)) as GrantAmount__c,
	cast(coalesce(g.approve_d,g.board_meeting_d,g.signature_d,g.rcv_d,dbo.Fn_stampdatetime(g.stamp)) as date) as GrantDate__c,
	left(cast(g.grantee_id as varchar(20)) +'  '+ (select t.description from tcf..grant_type_c t where code = g.grant_type_c),80) as Name,
	cast(g.applic_id as varchar(20)) as ApplicationId__c,
	g.contact_person_t as ContactName__c,
	(select gp.name from tcf.dbo.grant_prog_c gp where gp.code = g.grant_prog_c) as ProjectCode__c,
	coalesce((select rtrim(s.name) from tcf.dbo.appl_status_c s where s.code = a.appl_status_c) ,	
            (select rtrim(s.name) from tcf.dbo.grantee_status_c s where s.code = g.grantee_status_c)) as GrantStatus__c,
	g.grant_purpose as ProjectTitle__c,
	left(g.grant_purpose,256) as ProjectTitleShort__c,
	cast(g.rcv_d as date) as ReceivedDate__c,
	g.request_amt as RequestAmount__c,
	(select sf_map_contact.SfId from sf_map_contact where sf_map_contact.PartyId = rec_id.party_id ) as Recommender,
	(select sname from tcf..party where party.party_id = a.staff_id) as Staff,
	coalesce((select SfId from sf_map_user where sf_map_user.PartyId = coalesce(a.staff_id,recommender_ddg.officer_party_id,account_ddg.officer_party_id)),'0054P000009tKZEQA2') as OwnerId,
	'Grant Upsert' as sf_object
	FROM sf_control_table,
	sf_map_grants, 
	tcf.dbo.grantee g
	left outer join tcf.dbo.applicant a on a.applic_id = g.applic_id
	left outer join (select distinct parent_obj_id,party_id, acct_id from tcf.dbo.trans_action where trans_type_c in (701,702) and trans_status_c <> 7) t on g.grantee_id = t.parent_obj_id
	left outer join tcf.dbo.address addr on g.default_pmt_addr_id = addr_id
	left outer join (select acct_id as grant_id, party_id from tcf.dbo.interested_party ip where ip.acct_role_c = 402 ) rec_id on g.grantee_id = rec_id.grant_id
	-- left outer join (select acct_id, min(party_id) party_id from tcf.dbo.interested_party ip where ip.acct_role_c = 191 and iparty_status_c = 1 group by acct_id) rm on t.acct_id = rm.acct_id
	left outer join tcf.dbo.ddg account_ddg on coalesce(g.applicant_id,t.party_id,g.party_id) = account_ddg.party_id
	left outer join tcf.dbo.ddg recommender_ddg on recommender_ddg.party_id = rec_id.party_id
	where sf_control_table.source_object = 'IPHISync'
  	and cast(g.grantee_id as varchar(20)) = sf_map_grants.Id
	 and ((dbo.Fn_stampdatetime(g.stamp) >= sf_control_table.last_load_date
	 and dbo.Fn_stampdatetime(g.stamp) <= sf_control_table.start_load_date)
	 OR exists (select 1 from tcf.dbo.Remove_dups_audit rda 
	 			where rda.party_id_leave = g.grant_id
	 			and rda.process_d >= sf_control_table.last_load_date
	 			and rda.process_d <= sf_control_table.start_load_date))
	order by 1, 3
end
GO
