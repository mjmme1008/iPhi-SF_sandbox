SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[sp_get_fund_relationship_changes]
AS
begin

	select ip.ip_id as ExtSysId__c, 	
	(select SfId from sf_map_org_account where sf_map_org_account.PartyId = ip.party_id) as Account__c,
	(select sfid from sf_map_contact where sf_map_contact.PartyId = ip.party_id) as Contact__c,
	ip.acct_id as FundId__c,
	ar.name as FundRelationship__c,
	(select ips.name from tcf.dbo.iparty_status_c ips where ips.code = ip.iparty_status_c) as Status__c,
	(select d.name from tcf.dbo.report_delivery_c d where d.code = ip.report_delivery_c) as DeliveryMethod__c,
	(select r.name from tcf.dbo.report_set_c r where r.code = ip.report_set_c) as ReportSet__c,
	ip.comment as Comment__c,
	CASE WHEN ip.generic_f = 'R' THEN 'Read Only' ELSE CASE WHEN ip.generic_f = 'W' THEN 'Full Access' ELSE 'No Access' END END as PortalAccessLevel__c,
	(select SfId from sf_map_address where sf_map_address.AddressId = ip.addr_id) as PreferredMailingAddress__c, --What address id should we get if addr_id is not populated?
	--added primary_f logic per ITS5338
	coalesce((select c.comms_string from tcf.dbo.comms c where c.comms_id = ip.email_id),(select top 1 c.comms_string from tcf.dbo.comms c,tcf.dbo.comms_type_c ct where ct.code = 30 and ct.code = c.comms_typ_c and c.primary_f = 1 and c.party_id = ip.party_id order by c.comms_id desc)) as PreferredEmail__c,
	(select sfid from sf_map_fund where sf_map_fund.AcctId = ip.acct_id) as Fund__c,
	--'' as fdnp_crm__SuggestGrants__c,
	sf_map_fund_relationship.SfId,
	'Fund Relationship insert' as sf_object
	from tcf.dbo.interested_party ip,
	tcf.dbo.acct_role_c ar, 
	sf_map_fund_relationship, 
	tcf.dbo.account acct, 
	sf_control_table
	where ip.acct_role_c = ar.code
	--and ar.entity in ('dfund')
	and ip.ip_id = sf_map_fund_relationship.IpId
	and acct.acct_id = ip.acct_id
	and acct.acct_type_c <> 1
	and ((dbo.fn_stampdatetime(ip.stamp) >= sf_control_table.last_load_date
	and dbo.fn_stampdatetime(ip.stamp) <= sf_control_table.start_load_date)
	OR exists (select 1 from tcf.dbo.Remove_dups_audit rda 
				where rda.party_id_leave = ip.party_id
				and rda.process_d >= sf_control_table.last_load_date
				and rda.process_d <= sf_control_table.start_load_date))
	and sf_control_table.source_object = 'IPHISync'
    and acct.acct_type_c <> 1       --Not an Account


	order by 1

end
GO
