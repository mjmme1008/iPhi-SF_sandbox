SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_get_gift_allocation_changes]
AS
begin

	select 
    cast(ta.tran_id as varchar(20)) as ExtSysId__c, 	
	coalesce(ct.pmt_amount,t.trade_total_a) as Amount,
	'Gift' as GiftNonGift__c,
	0.00 as NonGiftAmount__c,
	(select SFId from sf_map_fund where sf_map_fund.AcctId = ta.acct_id) as npsp__General_Accounting_Unit__c,
	-- ta.tran_id as npsp__Opportunity__c,
	 (select SfId from sf_map_gifts where sf_map_gifts.TranId = ta.tran_id) as npsp__Opportunity__c,	
    'Gift Allocation Upsert' as sf_object
	FROM tcf.dbo.trans_action ta
	left join tcf.dbo.cash_trans ct on ta.tran_id = ct.tran_id
	left join tcf.dbo.trade t on ta.tran_id = t.tran_id,
	tcf.dbo.trans_type_c tt,
	tcf.dbo.contribution c,
    tcf.dbo.account a,
	sf_control_table,
	sf_map_gifts_allocations
	WHERE ta.trans_type_c = tt.code 
    	and ta.parent_obj_id = c.contrib_id
   	and ta.trans_status_c <> 7 --exclude cancels 
 	and ta.trans_type_c in ( 601, 602) 
    and ta.acct_id = a.acct_id
--code	name
--601	Cash Contrib    
--602	Sec Contrib     
--611	Multi-Acct Contr
--612	Complex Contrib 
--613	Bulk Cash Contr 
--621	DAG Contrib     
--622	Volunt. Contrib 
--699	Recurring Contri
--901	Contrib Adm Fee 
	and dbo.Fn_stampdatetime(ta.stamp) >= sf_control_table.last_load_date
	and dbo.Fn_stampdatetime(ta.stamp) <= sf_control_table.start_load_date
	and sf_control_table.source_object = 'IPHISync'
	and ta.tran_id = sf_map_gifts_allocations.TranId
    -- temporary until figure out how to load allocations for closed funds
    and a.acct_status_c = 1     --(1=open, 2=closed, 4=immobilized)
	order by 1

end
GO
