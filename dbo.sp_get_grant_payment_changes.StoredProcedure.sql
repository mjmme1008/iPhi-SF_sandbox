SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_get_grant_payment_changes]
AS
begin

	
    select
    cast(ta.tran_id as varchar(20)) as ExtSysId__c, 	
	(select SfId from sf_map_fund where sf_map_fund.AcctId = ta.acct_id) as Fund__c,
	ta.parent_obj_id as Grant__c,
	ct.pmt_amount as PaymentAmount__c,
	cast(coalesce(ta.effective_d,ct.pmt_d) as date) as PaymentDate__c,
	(select name from tcf.dbo.trans_status_c ts where ts.code = ta.trans_status_c) as PayStatus__c,
	CASE WHEN (select d.anonym_grant_f from tcf.dbo.dfund d where d.dfund_id = ta.acct_id) = 'Y' THEN 'true' ELSE 'false' END as AnonymousFund__c,
	'Grant Payment Upsert' as sf_object
	from 
	tcf.dbo.trans_action ta, 
	tcf.dbo.cash_trans ct, 
	tcf.dbo.grantee g,
	sf_control_table,
	sf_map_grant_payments
	where 
    trans_type_c in (701,702)
	and ta.tran_id = ct.tran_id
	and ta.parent_obj_id = g.grantee_id
	and sf_control_table.source_object = 'IPHISync'
	and cast(ta.tran_id as varchar(20)) = sf_map_grant_payments.Id
  	and dbo.Fn_stampdatetime(ta.stamp) >= sf_control_table.last_load_date
	and dbo.Fn_stampdatetime(ta.stamp) <= sf_control_table.start_load_date
	order by 1, 3

end
GO
